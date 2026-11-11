// lib/config/theme/app_theme.dart
import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_text_styles.dart';

abstract class AppTheme {
  static ThemeData get temaClaro => ThemeData(
        useMaterial3: true,
        fontFamily: AppTextStyles.familiaFuente,
        scaffoldBackgroundColor: AppColors.portadaLibreta,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.botonOscuro,
          primary: AppColors.botonOscuro,
          secondary: AppColors.lineaMargenHoja,
          surface: AppColors.hojaLibreta,
        ),
        textTheme: const TextTheme(
          headlineLarge: AppTextStyles.headingLg,
          headlineMedium: AppTextStyles.headingMd,
          titleMedium: AppTextStyles.headingSm,
          bodyLarge: AppTextStyles.bodyLg,
          bodyMedium: AppTextStyles.bodyMd,
          bodySmall: AppTextStyles.bodySm,
          labelSmall: AppTextStyles.caption,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.botonOscuro,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            textStyle: AppTextStyles.button,
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.black12),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.black12),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.botonOscuro, width: 1.5),
          ),
        ),
      );
}
