// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TaskModelAdapter extends TypeAdapter<TaskModel> {
  @override
  final int typeId = 1;

  @override
  TaskModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TaskModel(
      id: fields[0] as String,
      titulo: fields[1] as String,
      descripcion: fields[2] as String,
      idAgenda: fields[3] as String,
      fechaHoraEntrega: fields[4] as DateTime,
      minutosAvisoAnticipado: fields[5] as int,
      nivelPrioridad: fields[6] as int,
      minutosEstimadosRealizacion: fields[7] as int,
      estaCompletada: fields[8] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, TaskModel obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.titulo)
      ..writeByte(2)
      ..write(obj.descripcion)
      ..writeByte(3)
      ..write(obj.idAgenda)
      ..writeByte(4)
      ..write(obj.fechaHoraEntrega)
      ..writeByte(5)
      ..write(obj.minutosAvisoAnticipado)
      ..writeByte(6)
      ..write(obj.nivelPrioridad)
      ..writeByte(7)
      ..write(obj.minutosEstimadosRealizacion)
      ..writeByte(8)
      ..write(obj.estaCompletada);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TaskModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
