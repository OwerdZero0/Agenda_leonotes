// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'agenda_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AgendaModelAdapter extends TypeAdapter<AgendaModel> {
  @override
  final int typeId = 0;

  @override
  AgendaModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AgendaModel(
      id: fields[0] as String,
      nombre: fields[1] as String,
      colorHexadecimal: fields[2] as int,
    );
  }

  @override
  void write(BinaryWriter writer, AgendaModel obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.nombre)
      ..writeByte(2)
      ..write(obj.colorHexadecimal);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AgendaModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
