import 'dart:math';

import 'simulation_result.dart';
import 'simulation_variable.dart';

/// Error de validación del motor (datos de entrada incorrectos).
class SimulationException implements Exception {
  final String message;
  const SimulationException(this.message);

  @override
  String toString() => 'SimulationException: $message';
}

/// Motor de simulación (Monte Carlo).
///
/// Es independiente de la interfaz: solo usa `dart:math`.
///
/// Funcionamiento:
///  1. Recibe variables estructuradas (rango [min, max] y valor del escenario).
///  2. En cada iteración sortea un valor para cada variable usando una
///     distribución triangular: el valor del escenario es el más probable
///     y los extremos son min y max.
///  3. Combina las variables: resultado = suma(signo * valor).
///  4. Calcula estadísticas (mínimo, máximo, promedio, mediana,
///     percentiles) y un histograma de la distribución.
class SimulationEngine {
  const SimulationEngine();

  SimulationResult run({
    required List<SimulationVariable> variables,
    int iterations = 1000,
    int bins = 10,
    int? seed,
  }) {
    _validate(variables, iterations, bins);

    final random = Random(seed);
    final totals = List<double>.filled(iterations, 0);
    final samples = [
      for (var j = 0; j < variables.length; j++)
        List<double>.filled(iterations, 0),
    ];

    for (var i = 0; i < iterations; i++) {
      var total = 0.0;
      for (var j = 0; j < variables.length; j++) {
        final variable = variables[j];
        final sampled = _sample(variable, random);
        samples[j][i] = sampled;
        total += variable.sign * sampled;
      }
      totals[i] = total;
    }

    final baseValue = variables.fold<double>(
      0,
      (sum, v) => sum + v.sign * v.value,
    );

    return SimulationResult(
      iterations: iterations,
      seed: seed,
      baseValue: baseValue,
      total: _stats(totals),
      variables: [
        for (var j = 0; j < variables.length; j++)
          VariableResult(
            variableId: variables[j].id,
            name: variables[j].name,
            unit: variables[j].unit,
            stats: _stats(samples[j]),
          ),
      ],
      histogram: _histogram(totals, bins),
    );
  }

  // ---------------------------------------------------------------------------
  // Validación
  // ---------------------------------------------------------------------------

  void _validate(List<SimulationVariable> variables, int iterations, int bins) {
    if (variables.isEmpty) {
      throw const SimulationException(
        'La decisión no tiene variables para simular.',
      );
    }
    if (iterations <= 0) {
      throw const SimulationException(
        'El número de simulaciones debe ser mayor a 0.',
      );
    }
    if (bins <= 0) {
      throw const SimulationException(
        'El número de intervalos debe ser mayor a 0.',
      );
    }

    for (final v in variables) {
      final numbers = [v.minValue, v.maxValue, v.value, v.sign];
      if (numbers.any((n) => n.isNaN || n.isInfinite)) {
        throw SimulationException(
          'La variable "${v.name}" tiene valores no numéricos.',
        );
      }
      if (v.minValue > v.maxValue) {
        throw SimulationException(
          'La variable "${v.name}" tiene el mínimo mayor que el máximo.',
        );
      }
      if (v.value < v.minValue || v.value > v.maxValue) {
        throw SimulationException(
          'El valor de "${v.name}" (${v.value}) está fuera de su rango '
          '[${v.minValue}, ${v.maxValue}].',
        );
      }
    }
  }

  // ---------------------------------------------------------------------------
  // Muestreo: distribución triangular (min, moda = value, max)
  // ---------------------------------------------------------------------------

  double _sample(SimulationVariable v, Random random) {
    final a = v.minValue;
    final b = v.maxValue;
    final c = v.value;

    if (a == b) return a;

    final u = random.nextDouble();
    final fc = (c - a) / (b - a);

    if (u < fc) {
      return a + sqrt(u * (b - a) * (c - a));
    }
    return b - sqrt((1 - u) * (b - a) * (b - c));
  }

  // ---------------------------------------------------------------------------
  // Estadísticas
  // ---------------------------------------------------------------------------

  DistributionStats _stats(List<double> values) {
    final sorted = [...values]..sort();
    final n = sorted.length;

    final mean = sorted.fold<double>(0, (s, x) => s + x) / n;
    final variance =
        sorted.fold<double>(0, (s, x) => s + (x - mean) * (x - mean)) / n;

    return DistributionStats(
      min: sorted.first,
      max: sorted.last,
      mean: mean,
      median: _percentile(sorted, 50),
      stdDev: sqrt(variance),
      p10: _percentile(sorted, 10),
      p25: _percentile(sorted, 25),
      p75: _percentile(sorted, 75),
      p90: _percentile(sorted, 90),
    );
  }

  /// Percentil con interpolación lineal. [sorted] debe estar ordenada.
  double _percentile(List<double> sorted, double p) {
    if (sorted.length == 1) return sorted.first;

    final rank = p / 100 * (sorted.length - 1);
    final lower = rank.floor();
    final upper = rank.ceil();

    if (lower == upper) return sorted[lower];

    final weight = rank - lower;
    return sorted[lower] + (sorted[upper] - sorted[lower]) * weight;
  }

  List<HistogramBin> _histogram(List<double> values, int bins) {
    final minV = values.reduce(min);
    final maxV = values.reduce(max);

    // Todos los valores iguales: un solo intervalo.
    if (minV == maxV) {
      return [HistogramBin(from: minV, to: maxV, count: values.length)];
    }

    final width = (maxV - minV) / bins;
    final counts = List<int>.filled(bins, 0);

    for (final x in values) {
      var index = ((x - minV) / width).floor();
      if (index >= bins) index = bins - 1; // el máximo entra en el último
      counts[index]++;
    }

    return [
      for (var i = 0; i < bins; i++)
        HistogramBin(
          from: minV + i * width,
          to: minV + (i + 1) * width,
          count: counts[i],
        ),
    ];
  }
}