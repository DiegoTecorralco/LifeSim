import 'package:flutter_test/flutter_test.dart';
import 'package:lifesim/features/simulation/domain/simulation_engine.dart';
import 'package:lifesim/features/simulation/domain/simulation_variable.dart';

void main() {
  const engine = SimulationEngine();

  const ingreso = SimulationVariable(
    id: '1',
    name: 'Ingreso',
    unit: 'MXN',
    minValue: 10000,
    maxValue: 15000,
    value: 12000,
  );

  const gasto = SimulationVariable(
    id: '2',
    name: 'Gastos',
    unit: 'MXN',
    minValue: 6000,
    maxValue: 9000,
    value: 7000,
    sign: -1,
  );

  group('SimulationEngine', () {
    test('calcula el valor base con los valores exactos del escenario', () {
      final result = engine.run(variables: [ingreso, gasto], seed: 1);

      expect(result.baseValue, 5000); // 12000 - 7000
    });

    test('el resultado queda dentro de los límites posibles', () {
      final result = engine.run(
        variables: [ingreso, gasto],
        iterations: 5000,
        seed: 1,
      );

      // mínimo posible: 10000 - 9000 = 1000 | máximo posible: 15000 - 6000 = 9000
      expect(result.total.min, greaterThanOrEqualTo(1000));
      expect(result.total.max, lessThanOrEqualTo(9000));
      expect(result.total.min, lessThanOrEqualTo(result.total.median));
      expect(result.total.median, lessThanOrEqualTo(result.total.max));
      expect(result.total.p10, lessThanOrEqualTo(result.total.p90));
    });

    test('con la misma semilla produce el mismo resultado', () {
      final a = engine.run(variables: [ingreso, gasto], seed: 42);
      final b = engine.run(variables: [ingreso, gasto], seed: 42);

      expect(a.toMap(), b.toMap());
    });

    test('el promedio se acerca al valor teórico (distribución triangular)', () {
      const variable = SimulationVariable(
        id: 'x',
        name: 'X',
        minValue: 0,
        maxValue: 10,
        value: 5,
      );

      final result = engine.run(
        variables: [variable],
        iterations: 10000,
        seed: 7,
      );

      // media triangular = (min + max + moda) / 3 = 5
      expect(result.total.mean, closeTo(5, 0.2));
    });

    test('una variable con min == max es constante', () {
      const fija = SimulationVariable(
        id: 'f',
        name: 'Fija',
        minValue: 500,
        maxValue: 500,
        value: 500,
      );

      final result = engine.run(variables: [fija], iterations: 100, seed: 1);

      expect(result.total.min, 500);
      expect(result.total.max, 500);
      expect(result.total.stdDev, 0);
      expect(result.histogram.length, 1);
    });

    test('el histograma cuenta todas las iteraciones', () {
      final result = engine.run(
        variables: [ingreso, gasto],
        iterations: 2000,
        bins: 8,
        seed: 3,
      );

      final total = result.histogram.fold<int>(0, (s, b) => s + b.count);

      expect(result.histogram.length, 8);
      expect(total, 2000);
    });

    test('devuelve estadísticas por cada variable', () {
      final result = engine.run(variables: [ingreso, gasto], seed: 1);

      expect(result.variables.length, 2);
      expect(result.variables.first.name, 'Ingreso');
      expect(result.variables.first.stats.min, greaterThanOrEqualTo(10000));
      expect(result.variables.first.stats.max, lessThanOrEqualTo(15000));
    });

    test('rechaza una lista de variables vacía', () {
      expect(
        () => engine.run(variables: []),
        throwsA(isA<SimulationException>()),
      );
    });

    test('rechaza un número de iteraciones inválido', () {
      expect(
        () => engine.run(variables: [ingreso], iterations: 0),
        throwsA(isA<SimulationException>()),
      );
    });

    test('rechaza un valor fuera del rango', () {
      const fuera = SimulationVariable(
        id: 'o',
        name: 'Fuera',
        minValue: 0,
        maxValue: 10,
        value: 20,
      );

      expect(
        () => engine.run(variables: [fuera]),
        throwsA(isA<SimulationException>()),
      );
    });

    test('rechaza un mínimo mayor que el máximo', () {
      const invertida = SimulationVariable(
        id: 'i',
        name: 'Invertida',
        minValue: 10,
        maxValue: 0,
        value: 5,
      );

      expect(
        () => engine.run(variables: [invertida]),
        throwsA(isA<SimulationException>()),
      );
    });
  });

  group('SimulationVariable.fromMap', () {
    test('convierte los datos que vienen de Supabase', () {
      final variable = SimulationVariable.fromMap(
        {
          'id': 'abc',
          'name': 'Ingreso',
          'unit': 'MXN',
          'min_value': 10000,
          'max_value': '15000',
        },
        value: '12000',
      );

      expect(variable.id, 'abc');
      expect(variable.minValue, 10000);
      expect(variable.maxValue, 15000);
      expect(variable.value, 12000);
      expect(variable.sign, 1);
    });
  });
}