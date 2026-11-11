// lib/config/theme/app_text_styles.dart
import 'package:flutter/material.dart';
import 'app_colors.dart';

abstract class AppTextStyles {
  // Tipografía estilo escritura a mano legible (imprenta humana)
  static const String familiaFuente = 'SegoePrint';

  // Encabezados
  static const TextStyle headingLg = TextStyle(
    fontFamily: familiaFuente,
    fontSize: 22,
    fontWeight: FontWeight.bold,
    color: AppColors.textoOscuro,
    letterSpacing: -0.3,
  );

  static const TextStyle headingMd = TextStyle(
    fontFamily: familiaFuente,
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: AppColors.textoOscuro,
  );

  static const TextStyle headingSm = TextStyle(
    fontFamily: familiaFuente,
    fontSize: 15,
    fontWeight: FontWeight.bold,
    color: AppColors.textoOscuro,
  );

  // Cuerpo
  static const TextStyle bodyLg = TextStyle(
    fontFamily: familiaFuente,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.textoOscuro,
  );

  static const TextStyle bodyMd = TextStyle(
    fontFamily: familiaFuente,
    fontSize: 13,
    fontWeight: FontWeight.normal,
    color: AppColors.textoOscuro,
  );

  static const TextStyle bodySm = TextStyle(
    fontFamily: familiaFuente,
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: AppColors.textoSecundario,
  );

  // Etiquetas y leyendas
  static const TextStyle caption = TextStyle(
    fontFamily: familiaFuente,
    fontSize: 11,
    fontWeight: FontWeight.w600,
    color: AppColors.textoSecundario,
  );

  static const TextStyle button = TextStyle(
    fontFamily: familiaFuente,
    fontSize: 14,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );
}
