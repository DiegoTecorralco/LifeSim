
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ScenariosPage extends StatefulWidget {
  final Map<String, dynamic> decision;

  const ScenariosPage({
    super.key,
    required this.decision,
  });

  @override
  State<ScenariosPage> createState() => _ScenariosPageState();
}

class _ScenariosPageState extends State<ScenariosPage> {
  late Future<List<Map<String, dynamic>>> _scenariosFuture;

  final List<String> _scenarioTypes = [
    'Conservador',
    'Esperado',
    'Desfavorable',
    'Personalizado',
  ];

  @override
  void initState() {
    super.initState();
    _scenariosFuture = _loadScenarios();
  }

  // CONSULTAR ESCENARIOS
  Future<List<Map<String, dynamic>>> _loadScenarios() async {
    final response = await Supabase.instance.client
        .from('scenarios')
        .select('id, decision_id, name, description, created_at')
        .eq('decision_id', widget.decision['id'])
        .order('created_at', ascending: true);

    return List<Map<String, dynamic>>.from(response);
  }

  // ACTUALIZAR LISTA
  void _refreshScenarios() {
    setState(() {
      _scenariosFuture = _loadScenarios();
    });
  }

  // CREAR ESCENARIO
  Future<void> _addScenario() async {
    final values = await _showScenarioDialog();

    if (values == null || !mounted) return;

    try {
      final user = Supabase.instance.client.auth.currentUser;

      if (user == null) {
        throw Exception('Debes iniciar sesión.');
      }

      await Supabase.instance.client.from('scenarios').insert({
        'decision_id': widget.decision['id'],
        'name': values['name'],
        'description': values['description'],
      });

      if (!mounted) return;

      _refreshScenarios();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Escenario creado correctamente.'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No se pudo crear el escenario: $error'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // FORMULARIO PARA CREAR ESCENARIO
  Future<Map<String, dynamic>?> _showScenarioDialog() async {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();

    String selectedType = 'Conservador';

    try {
      return await showDialog<Map<String, dynamic>>(
        context: context,
        builder: (dialogContext) {
          return StatefulBuilder(
            builder: (context, setDialogState) {
              return AlertDialog(
                title: const Text('Crear escenario'),
                content: SingleChildScrollView(
                  child: Form(
                    key: formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        DropdownButtonFormField<String>(
                          initialValue: selectedType,
                          decoration: const InputDecoration(
                            labelText: 'Tipo de escenario',
                            border: OutlineInputBorder(),
                          ),
                          items: _scenarioTypes.map((type) {
                            return DropdownMenuItem<String>(
                              value: type,
                              child: Text(type),
                            );
                          }).toList(),
                          onChanged: (value) {
                            if (value == null) return;

                            setDialogState(() {
                              selectedType = value;

                              if (value != 'Personalizado') {
                                nameController.text = value;
                              } else {
                                nameController.clear();
                              }
                            });
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: nameController,
                          enabled: selectedType == 'Personalizado',
                          decoration: const InputDecoration(
                            labelText: 'Nombre del escenario',
                            hintText: 'Ej. Crecimiento acelerado',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Ingresa el nombre del escenario';
                            }

                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: descriptionController,
                          maxLines: 3,
                          decoration: const InputDecoration(
                            labelText: 'Descripción',
                            hintText: 'Describe las condiciones del escenario',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Ingresa una descripción';
                            }

                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(dialogContext);
                    },
                    child: const Text('Cancelar'),
                  ),
                  FilledButton(
                    onPressed: () {
                      if (!formKey.currentState!.validate()) return;

                      Navigator.pop(dialogContext, {
                        'name': selectedType == 'Personalizado'
                            ? nameController.text.trim()
                            : selectedType,
                        'description':
                            descriptionController.text.trim(),
                      });
                    },
                    child: const Text('Crear escenario'),
                  ),
                ],
              );
            },
          );
        },
      );
    } finally {
      nameController.dispose();
      descriptionController.dispose();
    }
  }

  // CONFIGURAR CONDICIONES DEL ESCENARIO
  Future<void> _configureScenario(
    Map<String, dynamic> scenario,
  ) async {
    final client = Supabase.instance.client;

    final controllers = <String, TextEditingController>{};

    try {
      // CONSULTAR VARIABLES DE LA DECISIÓN
      final variablesResponse = await client
          .from('variables')
          .select('id, name, unit, min_value, max_value')
          .eq('decision_id', widget.decision['id'])
          .order('created_at', ascending: true);

      final variables =
          List<Map<String, dynamic>>.from(variablesResponse);

      if (!mounted) return;

      if (variables.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Primero debes agregar variables a esta decisión.',
            ),
          ),
        );
        return;
      }

      // CONSULTAR CONDICIONES EXISTENTES
      final savedResponse = await client
          .from('scenario_variables')
          .select('id, variable_id, value')
          .eq('scenario_id', scenario['id']);

      final savedValues =
          List<Map<String, dynamic>>.from(savedResponse);

      // PREPARAR CONTROLADORES
      for (final variable in variables) {
        final variableId = variable['id'].toString();

        final existing = savedValues.where(
          (item) =>
              item['variable_id'].toString() == variableId,
        );

        controllers[variableId] = TextEditingController(
          text: existing.isNotEmpty
              ? existing.first['value'].toString()
              : '',
        );
      }

      final formKey = GlobalKey<FormState>();

      if (!mounted) return;

      await showDialog<void>(
        context: context,
        builder: (dialogContext) {
          return AlertDialog(
            title: Text(
              'Configurar: ${scenario['name']}',
            ),
            content: SizedBox(
              width: 450,
              child: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Define los valores de las variables para este escenario.',
                      ),
                      const SizedBox(height: 20),

                      ...variables.map((variable) {
                        final id = variable['id'].toString();
                        final controller = controllers[id]!;

                        final min = double.tryParse(
                          variable['min_value'].toString(),
                        );

                        final max = double.tryParse(
                          variable['max_value'].toString(),
                        );

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: TextFormField(
                            controller: controller,
                            keyboardType:
                                const TextInputType.numberWithOptions(
                              decimal: true,
                              signed: true,
                            ),
                            decoration: InputDecoration(
                              labelText:
                                  variable['name']?.toString() ??
                                      'Variable',
                              helperText:
                                  'Unidad: ${variable['unit'] ?? '-'}\n'
                                  'Mínimo: ${min ?? '-'} | '
                                  'Máximo: ${max ?? '-'}',
                              border: const OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (value == null ||
                                  value.trim().isEmpty) {
                                return 'Ingresa un valor';
                              }

                              final number =
                                  double.tryParse(value.trim());

                              if (number == null) {
                                return 'Ingresa un número válido';
                              }

                              if (min != null && number < min) {
                                return 'No puede ser menor que $min';
                              }

                              if (max != null && number > max) {
                                return 'No puede ser mayor que $max';
                              }

                              return null;
                            },
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(dialogContext);
                },
                child: const Text('Cancelar'),
              ),
              FilledButton.icon(
                icon: const Icon(Icons.save),
                label: const Text('Guardar condiciones'),
                onPressed: () async {
                  if (!formKey.currentState!.validate()) {
                    return;
                  }

                  try {
                    // GUARDAR O ACTUALIZAR CADA VALOR
                    for (final variable in variables) {
                      final variableId =
                          variable['id'].toString();

                      final value = double.parse(
                        controllers[variableId]!.text.trim(),
                      );

                      final existing = savedValues.where(
                        (item) =>
                            item['variable_id'].toString() ==
                            variableId,
                      );

                      if (existing.isNotEmpty) {
                        await client
                            .from('scenario_variables')
                            .update({
                              'value': value,
                            })
                            .eq('scenario_id', scenario['id'])
                            .eq('variable_id', variable['id']);
                      } else {
                        await client
                            .from('scenario_variables')
                            .insert({
                              'scenario_id': scenario['id'],
                              'variable_id': variable['id'],
                              'value': value,
                            });
                      }
                    }

                    if (!dialogContext.mounted) return;

                    Navigator.pop(dialogContext);
                  } catch (error) {
                    if (!dialogContext.mounted) return;

                    ScaffoldMessenger.of(dialogContext).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Error al guardar las condiciones: $error',
                        ),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
              ),
            ],
          );
        },
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Configuración cerrada.'),
        ),
      );
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'No se pudieron cargar las condiciones: $error',
          ),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      for (final controller in controllers.values) {
        controller.dispose();
      }
    }
  }

  // ICONO SEGÚN EL TIPO
  IconData _getScenarioIcon(String name) {
    switch (name) {
      case 'Conservador':
        return Icons.shield_outlined;
      case 'Esperado':
        return Icons.check_circle_outline;
      case 'Desfavorable':
        return Icons.warning_amber_outlined;
      default:
        return Icons.tune;
    }
  }

  // COLOR SEGÚN EL TIPO
  Color _getScenarioColor(String name) {
    switch (name) {
      case 'Conservador':
        return Colors.blue;
      case 'Esperado':
        return Colors.green;
      case 'Desfavorable':
        return Colors.orange;
      default:
        return Colors.deepPurple;
    }
  }

  @override
  Widget build(BuildContext context) {
    final decisionTitle =
        widget.decision['title']?.toString() ?? 'Decisión';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Escenarios'),
        actions: [
          IconButton(
            tooltip: 'Actualizar',
            icon: const Icon(Icons.refresh),
            onPressed: _refreshScenarios,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addScenario,
        icon: const Icon(Icons.add),
        label: const Text('Crear escenario'),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
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
                  'Crea diferentes posibilidades para analizar tu decisión.',
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Escenarios registrados',
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: FutureBuilder<List<Map<String, dynamic>>>(
                    future: _scenariosFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState ==
                          ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }

                      if (snapshot.hasError) {
                        return Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.error_outline,
                                color: Colors.red,
                                size: 40,
                              ),
                              const SizedBox(height: 12),
                              const Text(
                                'No se pudieron cargar los escenarios.',
                              ),
                              Text(
                                '${snapshot.error}',
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 12),
                              FilledButton(
                                onPressed: _refreshScenarios,
                                child: const Text('Reintentar'),
                              ),
                            ],
                          ),
                        );
                      }

                      final scenarios = snapshot.data ?? [];

                      if (scenarios.isEmpty) {
                        return const Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.account_tree_outlined,
                                size: 55,
                                color: Colors.grey,
                              ),
                              SizedBox(height: 12),
                              Text(
                                'Todavía no hay escenarios',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                'Crea tu primer escenario para esta decisión.',
                                style: TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                        );
                      }

                      return ListView.builder(
                        itemCount: scenarios.length,
                        itemBuilder: (context, index) {
                          final scenario = scenarios[index];

                          final name =
                              scenario['name']?.toString() ??
                                  'Sin nombre';

                          final color = _getScenarioColor(name);

                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: ListTile(
                              contentPadding: const EdgeInsets.all(12),
                              leading: CircleAvatar(
                                backgroundColor: color.withValues(
                                  alpha: 0.12,
                                ),
                                child: Icon(
                                  _getScenarioIcon(name),
                                  color: color,
                                ),
                              ),
                              title: Text(
                                name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Padding(
                                padding: const EdgeInsets.only(top: 6),
                                child: Text(
                                  scenario['description']?.toString() ??
                                      'Sin descripción',
                                ),
                              ),
                              trailing: FilledButton.tonalIcon(
                                onPressed: () {
                                  _configureScenario(scenario);
                                },
                                icon: const Icon(Icons.tune),
                                label: const Text('Configurar'),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

