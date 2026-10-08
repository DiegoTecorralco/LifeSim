import 'package:flutter_test/flutter_test.dart';

import 'package:lifesim/main.dart';

void main() {
  testWidgets('LifeSim inicia correctamente', (WidgetTester tester) async {
    await tester.pumpWidget(const LifeSimApp());

    expect(find.text('LifeSim'), findsOneWidget);
  });
}