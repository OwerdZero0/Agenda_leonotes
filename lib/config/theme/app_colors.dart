import 'package:flutter/material.dart';

class AppColors {
  // Fondos y estructura de la libreta
  static const Color portadaLibreta = Color(0xFFD3B68A);    // Beige/mostaza de la cubierta
  static const Color hojaLibreta = Color(0xFFFAFAFA);       // Hoja interior
  static const Color argollasLibreta = Color(0xFF2C2C2C);   // Argollas oscuras del lomo
  static const Color lineaMargenHoja = Color(0xFFE2EFE9);   // Línea tenue vertical de la hoja

  // Componentes e interfaz
  static const Color botonOscuro = Color(0xFF22252A);       // Botones negros/carbón
  static const Color textoOscuro = Color(0xFF1E1E1E);       // Texto principal
  static const Color textoSecundario = Color(0xFF757575);   // Texto atenuado
  static const Color bordeTarjeta = Color(0xFF3B5664);      // Bordes de tarjetas de agendas

  // Estado completado
  static const Color tareaCompletada = Color(0xFF6B9071);   // Verde para tareas listas

  // Los 5 niveles de prioridad solicitados
  static const Color prioridadMuyBaja = Color(0xFF81D4FA);  // Azul claro
  static const Color prioridadBaja = Color(0xFF1976D2);     // Azul fuerte
  static const Color prioridadMedia = Color(0xFFFBC02D);    // Amarillo
  static const Color prioridadAlta = Color(0xFFFB8C00);     // Naranja
  static const Color prioridadMuyAlta = Color(0xFFE53935);  // Rojo

  // Retorna el color según el nivel de prioridad (del 1 al 5)
  static Color obtenerColorPrioridad(int nivelPrioridad) {
    switch (nivelPrioridad) {
      case 1:
        return prioridadMuyBaja;
      case 2:
        return prioridadBaja;
      case 3:
        return prioridadMedia;
      case 4:
        return prioridadAlta;
      case 5:
        return prioridadMuyAlta;
      default:
        return prioridadBaja;
    }
  }
}