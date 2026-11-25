/// Variable estructurada que recibe el motor de simulación.
///
/// Es una clase Dart pura: no depende de Flutter ni de Supabase.
class SimulationVariable {
  final String id;
  final String name;
  final String unit;

  /// Rango permitido de la variable (columnas min_value / max_value).
  final double minValue;
  final double maxValue;

  /// Valor configurado en el escenario (tabla scenario_variables.value).
  /// Es el valor más probable dentro del rango.
  final double value;

  /// Cómo influye la variable en el resultado:
  ///  1  = suma (por ejemplo, ingresos)
  /// -1  = resta (por ejemplo, gastos o costo de la decisión)
  final double sign;

  const SimulationVariable({
    required this.id,
    required this.name,
    required this.minValue,
    required this.maxValue,
    required this.value,
    this.unit = '',
    this.sign = 1,
  });

  /// Construye la variable a partir de una fila de la tabla `variables`
  /// de Supabase y el valor que el escenario le asignó.
  factory SimulationVariable.fromMap(
    Map<String, dynamic> variable, {
    required Object? value,
    double sign = 1,
  }) {
    return SimulationVariable(
      id: variable['id'].toString(),
      name: variable['name']?.toString() ?? 'Sin nombre',
      unit: variable['unit']?.toString() ?? '',
      minValue: _toDouble(variable['min_value']),
      maxValue: _toDouble(variable['max_value']),
      value: _toDouble(value),
      sign: sign,
    );
  }

  /// Datos de la variable tal como se usaron en la simulación.
  Map<String, dynamic> toMap() => {
        'variable_id': id,
        'name': name,
        'unit': unit,
        'min_value': minValue,
        'max_value': maxValue,
        'value': value,
        'sign': sign,
      };

  static double _toDouble(Object? raw) {
    if (raw is num) return raw.toDouble();
    return double.parse(raw.toString().trim());
  }
}