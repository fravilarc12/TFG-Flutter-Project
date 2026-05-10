import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:travel_planner_app/src/core/constants/app_colors.dart';

void main() {
  group('Pruebas de Componentes UI (Widget Tests)', () {
    testWidgets(
        'Un botón estándar se renderiza correctamente con la paleta de la app',
        (WidgetTester tester) async {
      // 1. Arrange: Montamos un entorno de prueba aislado con nuestro botón
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ElevatedButton(
              onPressed: () {},
              style:
                  ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
              child: const Text('Iniciar Sesión'),
            ),
          ),
        ),
      );

      // 2. Assert: Comprobamos que el botón existe en el árbol de widgets
      expect(find.text('Iniciar Sesión'), findsOneWidget);
      expect(find.byType(ElevatedButton), findsOneWidget);

      // Comprobamos que solo hay un botón en la pantalla
      expect(find.byType(ElevatedButton), findsNWidgets(1));
    });
  });
}
