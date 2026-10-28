import 'package:hive/hive.dart';

part 'agenda_model.g.dart';

@HiveType(typeId: 0)
class AgendaModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  String nombre;

  @HiveField(2)
  int colorHexadecimal;

  AgendaModel({
    required this.id,
    required this.nombre,
    required this.colorHexadecimal,
  });
}