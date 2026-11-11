// lib/config/theme/app_spacing.dart
import 'package:flutter/material.dart';

abstract class AppSpacing {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 20.0;
  static const double xxl = 28.0;

  // Insets comunes
  static const EdgeInsets paddingScreen = EdgeInsets.symmetric(horizontal: 14, vertical: 12);
  static const EdgeInsets paddingCard = EdgeInsets.all(12);
  static const EdgeInsets paddingCardSm = EdgeInsets.symmetric(horizontal: 10, vertical: 8);

  // Espaciadores SizedBox constantes
  static const SizedBox gapXs = SizedBox(height: xs, width: xs);
  static const SizedBox gapSm = SizedBox(height: sm, width: sm);
  static const SizedBox gapMd = SizedBox(height: md, width: md);
  static const SizedBox gapLg = SizedBox(height: lg, width: lg);
  static const SizedBox gapXl = SizedBox(height: xl, width: xl);

  // Radios de bordes estándar
  static const BorderRadius radiusSm = BorderRadius.all(Radius.circular(8));
  static const BorderRadius radiusMd = BorderRadius.all(Radius.circular(12));
  static const BorderRadius radiusLg = BorderRadius.all(Radius.circular(16));
}

