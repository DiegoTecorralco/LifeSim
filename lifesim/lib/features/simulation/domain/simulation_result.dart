/// Estadísticas de una serie de valores simulados.
class DistributionStats {
  final double min;
  final double max;
  final double mean;
  final double median;
  final double stdDev;
  final double p10;
  final double p25;
  final double p75;
  final double p90;

  const DistributionStats({
    required this.min,
    required this.max,
    required this.mean,
    required this.median,
    required this.stdDev,
    required this.p10,
    required this.p25,
    required this.p75,
    required this.p90,
  });

  Map<String, dynamic> toMap() => {
        'min': min,
        'max': max,
        'mean': mean,
        'median': median,
        'std_dev': stdDev,
        'p10': p10,
        'p25': p25,
        'p75': p75,
        'p90': p90,
      };
}

/// Resultado de una variable individual dentro de la simulación.
class VariableResult {
  final String variableId;
  final String name;
  final String unit;
  final DistributionStats stats;

  const VariableResult({
    required this.variableId,
    required this.name,
    required this.unit,
    required this.stats,
  });

  Map<String, dynamic> toMap() => {
        'variable_id': variableId,
        'name': name,
        'unit': unit,
        'stats': stats.toMap(),
      };
}

/// Intervalo del histograma (útil para graficar la distribución).
class HistogramBin {
  final double from;
  final double to;
  final int count;

  const HistogramBin({
    required this.from,
    required this.to,
    required this.count,
  });

  Map<String, dynamic> toMap() => {'from': from, 'to': to, 'count': count};
}

/// Resultado completo de una simulación.
class SimulationResult {
  /// Número de simulaciones (iteraciones) ejecutadas.
  final int iterations;

  /// Semilla usada (null si fue aleatoria).
  final int? seed;

  /// Resultado "sin azar": usando los valores exactos del escenario.
  final double baseValue;

  /// Estadísticas del resultado total de todas las iteraciones.
  final DistributionStats total;

  /// Estadísticas por variable.
  final List<VariableResult> variables;

  /// Distribución del resultado total.
  final List<HistogramBin> histogram;

  const SimulationResult({
    required this.iterations,
    required this.seed,
    required this.baseValue,
    required this.total,
    required this.variables,
    required this.histogram,
  });

  /// Formato listo para guardarse (por ejemplo, en simulations.result).
  Map<String, dynamic> toMap() => {
        'iterations': iterations,
        'seed': seed,
        'base_value': baseValue,
        'total': total.toMap(),
        'variables': variables.map((v) => v.toMap()).toList(),
        'histogram': histogram.map((b) => b.toMap()).toList(),
      };
}