// lib/models/bloque_horario.dart
import 'package:flutter/material.dart';
import 'task_model.dart';

class BloqueHorarioInteligente {
  final TaskModel tarea;
  final TimeOfDay horaInicio;
  final TimeOfDay horaFin;

  BloqueHorarioInteligente({
    required this.tarea,
    required this.horaInicio,
    required this.horaFin,
  });
}

