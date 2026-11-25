import 'package:supabase_flutter/supabase_flutter.dart';

/// Variables de una decisión junto con los valores que un escenario
/// les asignó (tabla scenario_variables).
class ScenarioData {
  /// Filas de la tabla `variables`.
  final List<Map<String, dynamic>> variables;

  /// variable_id -> value configurado en el escenario.
  final Map<String, Object?> values;

  const ScenarioData({required this.variables, required this.values});

  /// Variables a las que el escenario todavía no les asigna un valor.
  List<Map<String, dynamic>> get missing => variables
      .where((v) => values[v['id'].toString()] == null)
      .toList();

  /// Se puede simular si hay variables y todas tienen valor.
  bool get isReady => variables.isNotEmpty && missing.isEmpty;
}

/// Lee de Supabase lo que necesita la simulación.
class SimulationRepository {
  final SupabaseClient _client;

  SimulationRepository([SupabaseClient? client])
      : _client = client ?? Supabase.instance.client;

  Future<List<Map<String, dynamic>>> loadScenarios(Object decisionId) async {
    final response = await _client
        .from('scenarios')
        .select('id, decision_id, name, description, created_at')
        .eq('decision_id', decisionId)
        .order('created_at', ascending: true);

    return List<Map<String, dynamic>>.from(response);
  }

  Future<ScenarioData> loadScenarioData({
    required Object decisionId,
    required Object scenarioId,
  }) async {
    final variablesResponse = await _client
        .from('variables')
        .select('id, name, unit, min_value, max_value')
        .eq('decision_id', decisionId)
        .order('created_at', ascending: true);

    final savedResponse = await _client
        .from('scenario_variables')
        .select('variable_id, value')
        .eq('scenario_id', scenarioId);

    final values = <String, Object?>{
      for (final row in List<Map<String, dynamic>>.from(savedResponse))
        row['variable_id'].toString(): row['value'],
    };

    return ScenarioData(
      variables: List<Map<String, dynamic>>.from(variablesResponse),
      values: values,
    );
  }

  /// Guarda una simulación en la tabla `simulations` y devuelve la fila
  /// creada (id y fecha de registro).
  Future<Map<String, dynamic>> saveSimulation({
    required Object scenarioId,
    required int iterations,
    required Map<String, dynamic> result,
  }) async {
    final response = await _client
        .from('simulations')
        .insert({
          'scenario_id': scenarioId,
          'iterations': iterations,
          'result': result,
        })
        .select('id, created_at')
        .single();

    return Map<String, dynamic>.from(response);
  }
}