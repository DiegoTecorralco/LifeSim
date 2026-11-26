import 'package:flutter/material.dart';

import '../../data/simulation_repository.dart';
import '../../domain/simulation_engine.dart';
import '../../domain/simulation_result.dart';
import '../../domain/simulation_variable.dart';
import '../widgets/distribution_chart.dart';
import '../widgets/result_range_chart.dart';
import '../widgets/variable_contribution_chart.dart';

class SimulationPage extends StatefulWidget {
  final Map<String, dynamic> decision;

  /// Escenario que aparece seleccionado al abrir la pantalla (opcional).
  final String? initialScenarioId;

  const SimulationPage({
    super.key,
    required this.decision,
    this.initialScenarioId,
  });

  @override
  State<SimulationPage> createState() => _SimulationPageState();
}

class _SimulationPageState extends State<SimulationPage> {
  final _repository = SimulationRepository();
  final _engine = const SimulationEngine();

  List<Map<String, dynamic>> _scenarios = [];
  String? _scenarioId;
  ScenarioData? _data;

  /// variable_id -> 1 (suma) o -1 (resta)
  final Map<String, double> _signs = {};
  int _iterations = 1000;

  bool _loading = true;
  bool _running = false;
  String? _error;
  SimulationResult? _result;
  DateTime? _finishedAt;

  // GUARDADO
  List<SimulationVariable> _lastVariables = [];
  String? _resultScenarioId;
  bool _saving = false;
  DateTime? _savedAt;

  @override
  void initState() {
    super.initState();
    _init();
  }

  // CARGAR ESCENARIOS DE LA DECISIÓN
  Future<void> _init() async {
    try {
      final scenarios = await _repository.loadScenarios(
        widget.decision['id'],
      );

      if (!mounted) return;

      if (scenarios.isEmpty) {
        setState(() {
          _scenarios = scenarios;
          _loading = false;
        });
        return;
      }

      final preselected = scenarios.any(
        (s) => s['id'].toString() == widget.initialScenarioId,
      );

      setState(() {
        _scenarios = scenarios;
        _scenarioId =
            preselected ? widget.initialScenarioId : scenarios.first['id'].toString();
      });

      await _loadScenarioData();
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = 'No se pudieron cargar los escenarios: $error';
        _loading = false;
      });
    }
  }

  // CARGAR VARIABLES Y VALORES DEL ESCENARIO SELECCIONADO
  Future<void> _loadScenarioData() async {
    final scenarioId = _scenarioId;
    if (scenarioId == null) return;

    setState(() {
      _loading = true;
      _error = null;
      _result = null;
    });

    try {
      final data = await _repository.loadScenarioData(
        decisionId: widget.decision['id'],
        scenarioId: scenarioId,
      );

      if (!mounted || _scenarioId != scenarioId) return;

      setState(() {
        _data = data;
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = 'No se pudieron cargar las variables: $error';
        _loading = false;
      });
    }
  }

  // EJECUTAR SIMULACIÓN
  Future<void> _runSimulation() async {
    final data = _data;
    if (data == null || !data.isReady) return;

    setState(() {
      _running = true;
      _result = null;
      _savedAt = null;
      _error = null;
    });

    // Pequeña pausa para que se vea el indicador de progreso.
    await Future<void>.delayed(const Duration(milliseconds: 300));

    try {
      final variables = [
        for (final variable in data.variables)
          SimulationVariable.fromMap(
            variable,
            value: data.values[variable['id'].toString()],
            sign: _signs[variable['id'].toString()] ?? 1,
          ),
      ];

      final result = _engine.run(
        variables: variables,
        iterations: _iterations,
      );

      if (!mounted) return;

      setState(() {
        _result = result;
        _lastVariables = variables;
        _resultScenarioId = _scenarioId;
        _finishedAt = DateTime.now();
        _running = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Simulación completada.'),
          backgroundColor: Colors.green,
        ),
      );
    } on SimulationException catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error.message;
        _running = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = 'No se pudo ejecutar la simulación: $error';
        _running = false;
      });
    }
  }

  // GUARDAR SIMULACIÓN
  Future<void> _saveSimulation() async {
    final result = _result;
    final scenarioId = _resultScenarioId;

    if (result == null ||
        scenarioId == null ||
        _saving ||
        _savedAt != null) {
      return;
    }

    setState(() {
      _saving = true;
      _error = null;
    });

    try {
      // Resultado + variables usadas (el escenario puede cambiar después).
      final payload = {
        ...result.toMap(),
        'inputs': [for (final v in _lastVariables) v.toMap()],
      };

      final saved = await _repository.saveSimulation(
        scenarioId: scenarioId,
        iterations: result.iterations,
        result: payload,
      );

      if (!mounted) return;

      final createdAt =
          DateTime.tryParse('${saved['created_at']}')?.toLocal() ??
              DateTime.now();

      setState(() {
        _savedAt = createdAt;
        _saving = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Simulación guardada correctamente.'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        _error = 'No se pudo guardar la simulación: $error';
      });
    }
  }

  String _formatDate(DateTime d) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(d.day)}/${two(d.month)}/${d.year} ${two(d.hour)}:${two(d.minute)}';
  }

  // FORMATO DE NÚMEROS: 12,345.67
  String _fmt(double value) {
    final fixed = value.toStringAsFixed(2);
    final parts = fixed.split('.');
    final negative = parts[0].startsWith('-');
    final digits = negative ? parts[0].substring(1) : parts[0];

    final buffer = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      if (i > 0 && (digits.length - i) % 3 == 0) buffer.write(',');
      buffer.write(digits[i]);
    }

    return '${negative ? '-' : ''}$buffer.${parts[1]}';
  }

  String _formatTime(DateTime time) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(time.hour)}:${two(time.minute)}:${two(time.second)}';
  }

  @override
  Widget build(BuildContext context) {
    final decisionTitle = widget.decision['title']?.toString() ?? 'Decisión';

    return Scaffold(
      appBar: AppBar(title: const Text('Ejecutar simulación')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Text(
                decisionTitle,
                style: const TextStyle(
                  fontSize: 23,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Selecciona un escenario y ejecuta la simulación para '
                'analizar sus posibles resultados.',
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 24),
              ..._buildContent(),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildContent() {
    if (_loading && _data == null && _scenarios.isEmpty && _error == null) {
      return const [
        Padding(
          padding: EdgeInsets.all(40),
          child: Center(child: CircularProgressIndicator()),
        ),
      ];
    }

    if (_scenarios.isEmpty) {
      return [
        if (_error != null) _errorBanner(_error!),
        const Padding(
          padding: EdgeInsets.all(30),
          child: Column(
            children: [
              Icon(Icons.account_tree_outlined, size: 55, color: Colors.grey),
              SizedBox(height: 12),
              Text(
                'Esta decisión no tiene escenarios',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              Text(
                'Crea un escenario para poder simular.',
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      ];
    }

    final data = _data;

    return [
      // 1. SELECCIONAR ESCENARIO
      const Text(
        '1. Escenario',
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
      const SizedBox(height: 12),
      DropdownButtonFormField<String>(
        key: ValueKey(_scenarioId),
        initialValue: _scenarioId,
        decoration: const InputDecoration(labelText: 'Escenario'),
        items: [
          for (final scenario in _scenarios)
            DropdownMenuItem<String>(
              value: scenario['id'].toString(),
              child: Text(scenario['name']?.toString() ?? 'Sin nombre'),
            ),
        ],
        onChanged: _running
            ? null
            : (value) {
                if (value == null || value == _scenarioId) return;
                setState(() => _scenarioId = value);
                _loadScenarioData();
              },
      ),
      const SizedBox(height: 24),

      // 2. VARIABLES
      const Text(
        '2. Variables del escenario',
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
      const SizedBox(height: 4),
      const Text(
        'Indica si cada variable suma o resta al resultado '
        '(por ejemplo, un ingreso suma y un gasto resta).',
        style: TextStyle(color: Colors.grey),
      ),
      const SizedBox(height: 8),
      if (_loading)
        const Padding(
          padding: EdgeInsets.all(24),
          child: Center(child: CircularProgressIndicator()),
        )
      else if (data != null) ..._buildVariables(data),

      if (_error != null) ...[
        const SizedBox(height: 12),
        _errorBanner(_error!),
      ],

      // 3. EJECUTAR
      if (!_loading && data != null && data.isReady) ...[
        const SizedBox(height: 24),
        const Text(
          '3. Ejecutar',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 16,
          runSpacing: 12,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            const Text('Número de simulaciones:'),
            SegmentedButton<int>(
              segments: const [
                ButtonSegment(value: 1000, label: Text('1,000')),
                ButtonSegment(value: 5000, label: Text('5,000')),
                ButtonSegment(value: 10000, label: Text('10,000')),
              ],
              selected: {_iterations},
              onSelectionChanged: _running
                  ? null
                  : (selection) {
                      setState(() => _iterations = selection.first);
                    },
            ),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 48,
          child: FilledButton.icon(
            onPressed: _running ? null : _runSimulation,
            icon: _running
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.play_arrow),
            label: Text(
              _running ? 'Simulando...' : 'Ejecutar simulación',
            ),
          ),
        ),
      ],

      // RESULTADO
      if (_result != null) ..._buildResult(_result!),
      const SizedBox(height: 30),
    ];
  }

  List<Widget> _buildVariables(ScenarioData data) {
    if (data.variables.isEmpty) {
      return [
        _warningBanner(
          'Esta decisión no tiene variables. Agrégalas desde la pantalla '
          'de variables antes de simular.',
        ),
      ];
    }

    return [
      if (data.missing.isNotEmpty)
        _warningBanner(
          'Faltan valores para: '
          '${data.missing.map((v) => v['name']).join(', ')}. '
          'Usa el botón "Configurar" del escenario para asignarlos.',
        ),
      for (final variable in data.variables) _variableTile(variable, data),
    ];
  }

  Widget _variableTile(Map<String, dynamic> variable, ScenarioData data) {
    final id = variable['id'].toString();
    final value = data.values[id];
    final unit = variable['unit']?.toString() ?? '';

    return Card(
      margin: const EdgeInsets.only(top: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Wrap(
          spacing: 16,
          runSpacing: 12,
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  variable['name']?.toString() ?? 'Sin nombre',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  value == null
                      ? 'Sin valor configurado'
                      : 'Valor: $value $unit\n'
                          'Rango: ${variable['min_value']} - ${variable['max_value']}',
                  style: TextStyle(
                    color: value == null ? Colors.orange : Colors.grey,
                  ),
                ),
              ],
            ),
            SegmentedButton<double>(
              segments: const [
                ButtonSegment(value: 1.0, label: Text('Suma')),
                ButtonSegment(value: -1.0, label: Text('Resta')),
              ],
              selected: {_signs[id] ?? 1.0},
              onSelectionChanged: _running
                  ? null
                  : (selection) {
                      setState(() {
                        _signs[id] = selection.first;
                        _result = null;
                      });
                    },
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildResult(SimulationResult result) {
    final stats = result.total;

    return [
      const SizedBox(height: 28),
      Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.green.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.green),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Simulación completada: ${result.iterations} simulaciones'
                '${_finishedAt == null ? '' : ' a las ${_formatTime(_finishedAt!)}'}.',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 16),
      const Text(
        'Resultado',
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
      const SizedBox(height: 12),

      // RESULTADO PRINCIPAL
      Card(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Resultado estimado',
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 6),
              Text(
                _fmt(stats.mean),
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Es el promedio de ${result.iterations} simulaciones. '
                'En 8 de cada 10 casos el resultado queda entre '
                '${_fmt(stats.p10)} y ${_fmt(stats.p90)}. '
                'Los valores extremos simulados van de ${_fmt(stats.min)} '
                'a ${_fmt(stats.max)}.',
              ),
            ],
          ),
        ),
      ),
      const SizedBox(height: 12),
      Wrap(
        spacing: 12,
        runSpacing: 12,
        children: [
          _statCard('Promedio', stats.mean,
              hint: 'Valor central de todas las simulaciones'),
          _statCard('Mínimo', stats.min,
              hint: 'El valor más bajo simulado'),
          _statCard('Máximo', stats.max,
              hint: 'El valor más alto simulado'),
          _statCard('Mediana', stats.median,
              hint: 'La mitad quedó por debajo'),
          _statCard('Valor base', result.baseValue,
              hint: 'Con los valores exactos del escenario'),
          _statCard('Percentil 10', stats.p10,
              hint: 'El 10% quedó por debajo'),
          _statCard('Percentil 90', stats.p90,
              hint: 'El 10% quedó por encima'),
          _statCard('Desviación', stats.stdDev,
              hint: 'Qué tanto varían los resultados'),
        ],
      ),

      // GRÁFICAS
      const SizedBox(height: 28),
      const Text(
        'Gráficas',
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
      const SizedBox(height: 4),
      const Text(
        'Hechas con los datos de esta simulación.',
        style: TextStyle(color: Colors.grey),
      ),

      // 1. Distribución
      const SizedBox(height: 20),
      const Text(
        'Distribución de resultados',
        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
      ),
      const SizedBox(height: 4),
      const Text(
        'Cuántas simulaciones cayeron en cada rango de resultado. '
        'Pasa el cursor sobre una barra para ver el detalle.',
        style: TextStyle(color: Colors.grey),
      ),
      const SizedBox(height: 16),
      DistributionChart(
        bins: result.histogram,
        mean: stats.mean,
        format: _fmt,
      ),

      // 2. Rango de resultados
      const SizedBox(height: 28),
      const Text(
        'Rango de resultados',
        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
      ),
      const SizedBox(height: 4),
      const Text(
        'De los valores más bajos a los más altos simulados, con la zona '
        'donde cayó la mayoría de los casos.',
        style: TextStyle(color: Colors.grey),
      ),
      const SizedBox(height: 16),
      ResultRangeChart(
        min: stats.min,
        max: stats.max,
        p10: stats.p10,
        p90: stats.p90,
        median: stats.median,
        mean: stats.mean,
        baseValue: result.baseValue,
        format: _fmt,
      ),

      // 3. Aporte de cada variable
      if (_lastVariables.length == result.variables.length) ...[
        const SizedBox(height: 28),
        const Text(
          'Aporte de cada variable',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        const Text(
          'Cuánto suma o resta, en promedio, cada variable al resultado.',
          style: TextStyle(color: Colors.grey),
        ),
        const SizedBox(height: 16),
        VariableContributionChart(
          items: [
            for (var i = 0; i < _lastVariables.length; i++)
              ContributionItem(
                name: _lastVariables[i].name,
                value: _lastVariables[i].sign *
                    result.variables[i].stats.mean,
              ),
          ],
          format: _fmt,
        ),
        const SizedBox(height: 8),
        Text(
          'La suma de los aportes es ${_fmt(_contributionsTotal(result))}, '
          'igual al promedio del resultado.',
          style: const TextStyle(color: Colors.grey, fontSize: 12),
        ),
      ],
      const SizedBox(height: 12),
      const Text(
        'Estos valores son estimaciones basadas en las variables y rangos '
        'que definiste. No son una predicción garantizada.',
        style: TextStyle(color: Colors.grey, fontSize: 12),
      ),
      const SizedBox(height: 20),

      // GUARDAR
      if (_savedAt != null)
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.blue.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              const Icon(Icons.save, color: Colors.blue),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Simulación guardada el ${_formatDate(_savedAt!)}.',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        )
      else
        SizedBox(
          height: 48,
          child: FilledButton.tonalIcon(
            onPressed: _saving ? null : _saveSimulation,
            icon: _saving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.save_outlined),
            label: Text(_saving ? 'Guardando...' : 'Guardar simulación'),
          ),
        ),
    ];
  }

  /// Suma de los aportes (signo x promedio) de todas las variables.
  double _contributionsTotal(SimulationResult result) {
    var total = 0.0;
    for (var i = 0; i < _lastVariables.length; i++) {
      total += _lastVariables[i].sign * result.variables[i].stats.mean;
    }
    return total;
  }

  Widget _statCard(String label, double value, {String? hint}) {
    return SizedBox(
      width: 200,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(color: Colors.grey)),
              const SizedBox(height: 6),
              Text(
                _fmt(value),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (hint != null) ...[
                const SizedBox(height: 4),
                Text(
                  hint,
                  style: const TextStyle(color: Colors.grey, fontSize: 11),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _errorBanner(String message) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.red),
          const SizedBox(width: 10),
          Expanded(child: Text(message)),
        ],
      ),
    );
  }

  Widget _warningBanner(String message) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: Colors.orange),
          const SizedBox(width: 10),
          Expanded(child: Text(message)),
        ],
      ),
    );
  }
}