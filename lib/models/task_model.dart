// lib/models/task_model.dart
import 'package:hive/hive.dart';

part 'task_model.g.dart';

@HiveType(typeId: 1)
class TaskModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  String titulo;

  @HiveField(2)
  String descripcion;

  @HiveField(3)
  String idAgenda;

  @HiveField(4)
  DateTime fechaHoraEntrega;

  @HiveField(5)
  int minutosAvisoAnticipado;

  @HiveField(6)
  int nivelPrioridad; // 1: Muy baja, 2: Baja, 3: Media, 4: Alta, 5: Muy alta

  @HiveField(7)
  int minutosEstimadosRealizacion;

  @HiveField(8)
  bool estaCompletada;

  TaskModel({
    required this.id,
    required this.titulo,
    this.descripcion = '',
    required this.idAgenda,
    required this.fechaHoraEntrega,
    this.minutosAvisoAnticipado = 10,
    required this.nivelPrioridad,
    this.minutosEstimadosRealizacion = 30,
    this.estaCompletada = false,
  });
}