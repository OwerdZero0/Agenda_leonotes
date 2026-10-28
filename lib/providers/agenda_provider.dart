import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/agenda_model.dart';
import '../models/task_model.dart';
import '../services/notification_service.dart';

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

class AgendaProvider extends ChangeNotifier {
  late Box<AgendaModel> _cajaAgendas;
  late Box<TaskModel> _cajaTareas;
  final NotificationService _servicioNotificaciones = NotificationService();

  String _terminoBusqueda = '';

  List<AgendaModel> get listaAgendas => _cajaAgendas.values.toList();
  List<TaskModel> get listaTareas => _cajaTareas.values.toList();

  String get terminoBusqueda => _terminoBusqueda;

  Future<void> inicializarProveedor() async {
    _cajaAgendas = Hive.box<AgendaModel>('caja_agendas');
    _cajaTareas = Hive.box<TaskModel>('caja_tareas');
    notifyListeners();
  }

  // --- BUSCADOR HOME ---
  void actualizarBusqueda(String valor) {
    _terminoBusqueda = valor.trim().toLowerCase();
    notifyListeners();
  }

  List<AgendaModel> get agendasFiltradas {
    if (_terminoBusqueda.isEmpty) return listaAgendas;
    return listaAgendas
        .where((agenda) => agenda.nombre.toLowerCase().contains(_terminoBusqueda))
        .toList();
  }

  List<TaskModel> get tareasFiltradasPorTitulo {
    if (_terminoBusqueda.isEmpty) return [];
    return listaTareas
        .where((tarea) => tarea.titulo.toLowerCase().contains(_terminoBusqueda))
        .toList();
  }

  // --- FILTROS DE TAREAS ---
  List<TaskModel> get tareasVencidas {
    final momentoActual = DateTime.now();
    return listaTareas.where((tarea) {
      return !tarea.estaCompletada && tarea.fechaHoraEntrega.isBefore(momentoActual);
    }).toList();
  }

  List<TaskModel> get tareasProximas {
    final momentoActual = DateTime.now();
    return listaTareas.where((tarea) {
      return !tarea.estaCompletada && tarea.fechaHoraEntrega.isAfter(momentoActual);
    }).toList();
  }

  List<TaskModel> obtenerTareasDeHoy() {
    final momentoActual = DateTime.now();
    return listaTareas.where((tarea) {
      return tarea.fechaHoraEntrega.year == momentoActual.year &&
          tarea.fechaHoraEntrega.month == momentoActual.month &&
          tarea.fechaHoraEntrega.day == momentoActual.day;
    }).toList();
  }

  List<TaskModel> obtenerTareasPorDia(DateTime fecha) {
    return listaTareas.where((tarea) {
      return tarea.fechaHoraEntrega.year == fecha.year &&
          tarea.fechaHoraEntrega.month == fecha.month &&
          tarea.fechaHoraEntrega.day == fecha.day;
    }).toList();
  }

  List<TaskModel> obtenerTareasPorAgenda(String idAgenda) {
    return listaTareas.where((tarea) => tarea.idAgenda == idAgenda).toList();
  }

  double calcularProgresoAgenda(String idAgenda) {
    final tareasAsociadas = obtenerTareasPorAgenda(idAgenda);
    if (tareasAsociadas.isEmpty) return 0.0;
    final completadas = tareasAsociadas.where((tarea) => tarea.estaCompletada).length;
    return completadas / tareasAsociadas.length;
  }

  // --- CRUD AGENDAS ---
  Future<void> agregarAgenda(AgendaModel nuevaAgenda) async {
    await _cajaAgendas.put(nuevaAgenda.id, nuevaAgenda);
    notifyListeners();
  }

  Future<void> eliminarAgenda(String idAgenda) async {
    // Eliminación en cascada de tareas asociadas
    final tareasAEliminar = listaTareas.where((tarea) => tarea.idAgenda == idAgenda).toList();
    for (var tarea in tareasAEliminar) {
      await _servicioNotificaciones.cancelarAlarma(tarea.id);
      await _cajaTareas.delete(tarea.id);
    }
    await _cajaAgendas.delete(idAgenda);
    notifyListeners();
  }

  // --- CRUD TAREAS ---
  Future<void> agregarTarea(TaskModel nuevaTarea) async {
    await _cajaTareas.put(nuevaTarea.id, nuevaTarea);
    await _servicioNotificaciones.programarAlarmaTarea(nuevaTarea);
    notifyListeners();
  }

  Future<void> actualizarTarea(TaskModel tareaModificada) async {
    await _cajaTareas.put(tareaModificada.id, tareaModificada);
    await _servicioNotificaciones.programarAlarmaTarea(tareaModificada);
    notifyListeners();
  }

  Future<void> conmutarEstadoCompletado(TaskModel tarea) async {
    tarea.estaCompletada = !tarea.estaCompletada;
    await tarea.save();
    // Reconfigura la alarma adaptándola al estado actual
    await _servicioNotificaciones.programarAlarmaTarea(tarea);
    notifyListeners();
  }

  Future<void> eliminarTarea(String idTarea) async {
    await _servicioNotificaciones.cancelarAlarma(idTarea);
    await _cajaTareas.delete(idTarea);
    notifyListeners();
  }

  // --- ALGORITMO DE HORARIO INTELIGENTE ---
  List<BloqueHorarioInteligente> calcularHorarioPorEnergia({
    required int porcentajeEnergia,
    required TimeOfDay horaInicioJornada,
    required TimeOfDay horaFinJornada,
  }) {
    List<int> prioridadesSeleccionadas;

    if (porcentajeEnergia >= 81) {
      prioridadesSeleccionadas = [5, 4];
    } else if (porcentajeEnergia >= 61) {
      prioridadesSeleccionadas = [4, 3];
    } else if (porcentajeEnergia >= 41) {
      prioridadesSeleccionadas = [3, 2];
    } else if (porcentajeEnergia >= 21) {
      prioridadesSeleccionadas = [2, 1];
    } else {
      prioridadesSeleccionadas = [1];
    }

    final tareasCandidatas = listaTareas.where((tarea) {
      return !tarea.estaCompletada && prioridadesSeleccionadas.contains(tarea.nivelPrioridad);
    }).toList();

    // Ordenar: primero mayor prioridad, luego fecha más cercana de entrega
    tareasCandidatas.sort((primera, segunda) {
      final comparacionPrioridad = segunda.nivelPrioridad.compareTo(primera.nivelPrioridad);
      if (comparacionPrioridad != 0) return comparacionPrioridad;
      return primera.fechaHoraEntrega.compareTo(segunda.fechaHoraEntrega);
    });

    final int minutosInicioTotal = (horaInicioJornada.hour * 60) + horaInicioJornada.minute;
    final int minutosFinTotal = (horaFinJornada.hour * 60) + horaFinJornada.minute;
    int minutosActuales = minutosInicioTotal;

    final List<BloqueHorarioInteligente> bloquesGenerados = [];

    for (var tarea in tareasCandidatas) {
      final int duracion = tarea.minutosEstimadosRealizacion;
      if (minutosActuales + duracion <= minutosFinTotal) {
        final horaInicioBloque = TimeOfDay(
          hour: minutosActuales ~/ 60,
          minute: minutosActuales % 60,
        );
        final horaFinBloque = TimeOfDay(
          hour: (minutosActuales + duracion) ~/ 60,
          minute: (minutosActuales + duracion) % 60,
        );

        bloquesGenerados.add(
          BloqueHorarioInteligente(
            tarea: tarea,
            horaInicio: horaInicioBloque,
            horaFin: horaFinBloque,
          ),
        );

        minutosActuales += duracion;
      }
    }

    return bloquesGenerados;
  }
}