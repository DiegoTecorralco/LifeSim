import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lifesim/features/simulation/domain/simulation_result.dart';
import 'package:lifesim/features/simulation/presentation/widgets/distribution_chart.dart';

Widget _wrap(Widget child) {
  return MaterialApp(
    home: Scaffold(
      body: Padding(padding: const EdgeInsets.all(16), child: child),
    ),
  );
}

String _fmt(double v) => v.toStringAsFixed(0);

void main() {
  const bins = [
    HistogramBin(from: 0, to: 10, count: 5),
    HistogramBin(from: 10, to: 20, count: 10),
  ];

  testWidgets('muestra el mínimo y el máximo del eje', (tester) async {
    await tester.pumpWidget(
      _wrap(DistributionChart(bins: bins, mean: 12, format: _fmt)),
    );

    expect(find.text('0'), findsOneWidget);
    expect(find.text('20'), findsOneWidget);
  });

  testWidgets('dibuja una barra por cada intervalo', (tester) async {
    await tester.pumpWidget(
      _wrap(DistributionChart(bins: bins, mean: 12, format: _fmt)),
    );

    expect(find.byType(Tooltip), findsNWidgets(2));
  });

  testWidgets('sin datos no dibuja nada', (tester) async {
    await tester.pumpWidget(
      _wrap(DistributionChart(bins: const [], mean: 0, format: _fmt)),
    );

    expect(find.byType(Tooltip), findsNothing);
  });
}