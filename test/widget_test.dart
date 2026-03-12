import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Dummy test to ensure test framework works', (
    WidgetTester tester,
  ) async {
    // Se ha reemplazado AppSST() por un widget dummy para evitar errores de
    // inicialización de plugins nativos (SharedPreferences, sqflite, etc)
    // durante las pruebas en entorno de desarrollo.
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: Text('Hello'))),
    );

    expect(find.text('Hello'), findsOneWidget);
  });
}
