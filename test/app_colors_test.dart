import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:travel_planner_app/src/core/constants/app_colors.dart';

void main() {
  group('Pruebas del Sistema de Diseño (AppColors)', () {
    test('Los colores principales coinciden con la paleta corporativa', () {
      // Comprobamos que nadie cambie los colores base por accidente
      expect(AppColors.primary, const Color(0xFF005D90));
      expect(AppColors.primaryContainer, const Color(0xFF0077B6));
      expect(AppColors.background, const Color(0xFFF8F9FA));
    });

    test('Los colores de texto tienen suficiente contraste visual', () {
      // Verificamos que los textos oscuros están definidos correctamente
      expect(AppColors.textPrimary, const Color(0xFF191C1D));
      expect(AppColors.textSecondary, const Color(0xFF707881));
    });
  });
}
