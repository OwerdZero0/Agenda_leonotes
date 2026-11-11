// lib/models/enums/nivel_prioridad.dart
import 'package:flutter/material.dart';
import '../../config/theme/app_colors.dart';

enum NivelPrioridad {
  muyBaja(1, 'Muy baja'),
  baja(2, 'Baja'),
  media(3, 'Media'),
  alta(4, 'Alta'),
  muyAlta(5, 'Muy alta');

  final int valor;
  final String etiqueta;

  const NivelPrioridad(this.valor, this.etiqueta);

  Color get color {
    switch (this) {
      case NivelPrioridad.muyBaja:
        return AppColors.prioridadMuyBaja;
      case NivelPrioridad.baja:
        return AppColors.prioridadBaja;
      case NivelPrioridad.media:
        return AppColors.prioridadMedia;
      case NivelPrioridad.alta:
        return AppColors.prioridadAlta;
      case NivelPrioridad.muyAlta:
        return AppColors.prioridadMuyAlta;
    }
  }

  static NivelPrioridad desdeValor(int valor) {
    for (final p in NivelPrioridad.values) {
      if (p.valor == valor) return p;
    }
    return NivelPrioridad.media;
  }
}

