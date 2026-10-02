import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Verifica renderizado de MaterialApp', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(child: Text('Gestión Financiera Personal')),
        ),
      ),
    );

    expect(find.text('Gestión Financiera Personal'), findsOneWidget);
  });
}
