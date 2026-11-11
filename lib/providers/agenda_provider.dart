import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/agenda_model.dart';
import '../models/bloque_horario.dart';
import '../models/task_model.dart';
import '../services/notification_service.dart';

export '../models/bloque_horario.dart';

class AgendaProvider extends ChangeNotifier {
  late Box<AgendaModel> _cajaAgendas;
  late Box<TaskModel> _cajaTareas;
  final NotificationService _servicioNotificaciones = NotificationService();

  String _terminoBusqueda = '';

  // Caché en memoria para evitar reconstrucciones costosas O(n) en cada acceso
  List<AgendaModel>? _cacheAgendas;
  List<TaskModel>? _cacheTareas;

  List<AgendaModel> get listaAgendas => _cacheAgendas ??= _cajaAgendas.values.toList();
  List<TaskModel> get listaTareas => _cacheTareas ??= _cajaTareas.values.toList();

  String get terminoBusqueda => _terminoBusqueda;

  void _invalidarCache({bool notificar = true}) {
    _cacheAgendas = null;
    _cacheTareas = null;
    if (notificar) notifyListeners();
  }

  Future<void> inicializarProveedor() async {
    try {
      _cajaAgendas = Hive.box<AgendaModel>('caja_agendas');
      _cajaTareas = Hive.box<TaskModel>('caja_tareas');
      _invalidarCache();
    } catch (e) {
      debugPrint('Error al inicializar AgendaProvider: $e');
    }
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
    try {
      await _cajaAgendas.put(nuevaAgenda.id, nuevaAgenda);
      _invalidarCache();
    } catch (e) {
      debugPrint('Error al agregar agenda: $e');
      rethrow;
    }
  }

  Future<void> eliminarAgenda(String idAgenda) async {
    try {
      // Eliminación en cascada de tareas asociadas
      final tareasAEliminar = listaTareas.where((tarea) => tarea.idAgenda == idAgenda).toList();
      for (var tarea in tareasAEliminar) {
        await _servicioNotificaciones.cancelarAlarma(tarea.id);
        await _cajaTareas.delete(tarea.id);
      }
      await _cajaAgendas.delete(idAgenda);
      _invalidarCache();
    } catch (e) {
      debugPrint('Error al eliminar agenda: $e');
      rethrow;
    }
  }

  // --- CRUD TAREAS ---
  Future<void> agregarTarea(TaskModel nuevaTarea) async {
    try {
      await _cajaTareas.put(nuevaTarea.id, nuevaTarea);
      await _servicioNotificaciones.programarAlarmaTarea(nuevaTarea);
      _invalidarCache();
    } catch (e) {
      debugPrint('Error al agregar tarea: $e');
      rethrow;
    }
  }

  Future<void> actualizarTarea(TaskModel tareaModificada) async {
    try {
      await _cajaTareas.put(tareaModificada.id, tareaModificada);
      await _servicioNotificaciones.programarAlarmaTarea(tareaModificada);
      _invalidarCache();
    } catch (e) {
      debugPrint('Error al actualizar tarea: $e');
      rethrow;
    }
  }

  Future<void> conmutarEstadoCompletado(TaskModel tarea) async {
    try {
      tarea.estaCompletada = !tarea.estaCompletada;
      await tarea.save();
      await _servicioNotificaciones.programarAlarmaTarea(tarea);
      _invalidarCache();
    } catch (e) {
      debugPrint('Error al conmutar estado de tarea: $e');
      rethrow;
    }
  }

  Future<void> eliminarTarea(String idTarea) async {
    try {
      await _servicioNotificaciones.cancelarAlarma(idTarea);
      await _cajaTareas.delete(idTarea);
      _invalidarCache();
    } catch (e) {
      debugPrint('Error al eliminar tarea: $e');
      rethrow;
    }
  }

  // --- ALGORITMO DE HORARIO INTELIGENTE ---
  List<BloqueHorarioInteligente> calcularHorarioPorEnergia({
    required int porcentajeEnergia,
    required TimeOfDay horaInicioJornada,
    required TimeOfDay horaFinJornada,
  }) {
    final DateTime momentoActual = DateTime.now();

    // 1. Determinar dificultades permitidas según el slider de energía
    List<int> prioridadesPermitidas;
    if (porcentajeEnergia >= 81) {
      prioridadesPermitidas = [5, 4];
    } else if (porcentajeEnergia >= 61) {
      prioridadesPermitidas = [4, 3];
    } else if (porcentajeEnergia >= 41) {
      prioridadesPermitidas = [3, 2];
    } else if (porcentajeEnergia >= 21) {
      prioridadesPermitidas = [2, 1];
    } else {
      prioridadesPermitidas = [1];
    }

    // 2. Filtrar tareas no completadas:
    final tareasCandidatas = listaTareas.where((tarea) {
      if (tarea.estaCompletada) return false;

      final bool venceHoy = tarea.fechaHoraEntrega.year == momentoActual.year &&
          tarea.fechaHoraEntrega.month == momentoActual.month &&
          tarea.fechaHoraEntrega.day == momentoActual.day;

      final bool estaVencida = tarea.fechaHoraEntrega.isBefore(momentoActual);

      if (venceHoy || estaVencida) return true;
      return prioridadesPermitidas.contains(tarea.nivelPrioridad);
    }).toList();

    // 3. Ordenar: Primero las de entrega más cercana/urgente, luego por mayor dificultad
    tareasCandidatas.sort((primera, segunda) {
      final bool primeraVenceHoy = primera.fechaHoraEntrega.year == momentoActual.year &&
          primera.fechaHoraEntrega.month == momentoActual.month &&
          primera.fechaHoraEntrega.day == momentoActual.day;
      final bool segundaVenceHoy = segunda.fechaHoraEntrega.year == momentoActual.year &&
          segunda.fechaHoraEntrega.month == momentoActual.month &&
          segunda.fechaHoraEntrega.day == momentoActual.day;

      if (primeraVenceHoy && !segundaVenceHoy) return -1;
      if (!primeraVenceHoy && segundaVenceHoy) return 1;

      final int comparacionFecha = primera.fechaHoraEntrega.compareTo(segunda.fechaHoraEntrega);
      if (comparacionFecha != 0) return comparacionFecha;

      return segunda.nivelPrioridad.compareTo(primera.nivelPrioridad);
    });

    // 4. Ubicar en bloques dentro del tiempo disponible
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
