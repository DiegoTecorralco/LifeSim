import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lifesim/features/simulation/presentation/widgets/result_range_chart.dart';
import 'package:lifesim/features/simulation/presentation/widgets/variable_contribution_chart.dart';

Widget _wrap(Widget child) {
  return MaterialApp(
    home: Scaffold(
      body: Padding(padding: const EdgeInsets.all(16), child: child),
    ),
  );
}

String _fmt(double v) => v.toStringAsFixed(0);

void main() {
  group('ResultRangeChart', () {
    testWidgets('muestra el rango y los valores del resultado', (tester) async {
      await tester.pumpWidget(
        _wrap(
          ResultRangeChart(
            min: 0,
            max: 100,
            p10: 10,
            p90: 90,
            median: 50,
            mean: 52,
            baseValue: 55,
            format: _fmt,
          ),
        ),
      );

      expect(find.text('0'), findsOneWidget);
      expect(find.text('100'), findsOneWidget);
      expect(find.text('Promedio: 52'), findsOneWidget);
      expect(find.text('Mediana: 50'), findsOneWidget);
      expect(find.text('Valor base: 55'), findsOneWidget);
    });

    testWidgets('no falla si todos los valores son iguales', (tester) async {
      await tester.pumpWidget(
        _wrap(
          ResultRangeChart(
            min: 500,
            max: 500,
            p10: 500,
            p90: 500,
            median: 500,
            mean: 500,
            baseValue: 500,
            format: _fmt,
          ),
        ),
      );

      expect(find.text('Promedio: 500'), findsOneWidget);
    });
  });

  group('VariableContributionChart', () {
    testWidgets('muestra cada variable con su aporte y signo', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const VariableContributionChart(
            items: [
              ContributionItem(name: 'Ingreso', value: 12000),
              ContributionItem(name: 'Gastos', value: -7000),
            ],
            format: _fmt,
          ),
        ),
      );

      expect(find.text('Ingreso'), findsOneWidget);
      expect(find.text('Gastos'), findsOneWidget);
      expect(find.text('+12000'), findsOneWidget);
      expect(find.text('-7000'), findsOneWidget);
    });

    testWidgets('sin datos no dibuja nada', (tester) async {
      await tester.pumpWidget(
        _wrap(const VariableContributionChart(items: [], format: _fmt)),
      );

      expect(find.text('Suma al resultado'), findsNothing);
    });
  });
}