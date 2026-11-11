import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/data/latest.dart' as tz_datos;
import 'package:timezone/timezone.dart' as tz;
import '../models/task_model.dart';

class NotificationService {
  static final NotificationService _instancia = NotificationService._interno();
  factory NotificationService() => _instancia;
  NotificationService._interno();

  final FlutterLocalNotificationsPlugin _pluginNotificaciones = FlutterLocalNotificationsPlugin();

  Future<void> inicializarServicio() async {
    tz_datos.initializeTimeZones();

    const configuracionAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
    const configuracionIos = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const configuracionInicial = InitializationSettings(
      android: configuracionAndroid,
      iOS: configuracionIos,
    );

    await _pluginNotificaciones.initialize(settings: configuracionInicial);
    await verificarYSolicitarPermisos();
  }

  Future<void> verificarYSolicitarPermisos() async {
    // 1. Permiso de Notificaciones (Android 13+ / 16)
    final estadoNotificaciones = await Permission.notification.status;
    if (!estadoNotificaciones.isGranted) {
      await Permission.notification.request();
    }

    // 2. Permiso de Alarmas Exactas (Android 14+ / 16)
    final estadoAlarmaExacta = await Permission.scheduleExactAlarm.status;
    if (!estadoAlarmaExacta.isGranted) {
      await Permission.scheduleExactAlarm.request();
    }

    // 3. Permiso de Ignorar Optimización de Batería (evita que HyperOS mate la app)
    final estadoBateria = await Permission.ignoreBatteryOptimizations.status;
    if (!estadoBateria.isGranted) {
      await Permission.ignoreBatteryOptimizations.request();
    }
  }

  int _obtenerIdNotificacion(String id) => id.hashCode & 0x7FFFFFFF;

  Future<void> programarAlarmaTarea(TaskModel tarea) async {
    try {
      final int idNotificacion = _obtenerIdNotificacion(tarea.id);
      await cancelarAlarma(tarea.id);

      // Si la tarea ya está completada o su fecha de entrega ya pasó, no programar alarma
      if (tarea.estaCompletada || tarea.fechaHoraEntrega.isBefore(DateTime.now())) {
        return;
      }

      DateTime momentoDisparo = tarea.fechaHoraEntrega.subtract(Duration(minutes: tarea.minutosAvisoAnticipado));
      if (momentoDisparo.isBefore(DateTime.now())) {
        momentoDisparo = DateTime.now().add(const Duration(seconds: 5));
      }

      final String tituloNotificacion = 'Aviso de realización: ${tarea.titulo}';
      const String cuerpoNotificacion = 'Comienza a realizar tu tarea para entregarla a tiempo.';

      const detallesAndroid = AndroidNotificationDetails(
        'canal_alarmas_agenda',
        'Alarmas de Agenda',
        channelDescription: 'Avisos con sonido y alerta continua de tareas',
        importance: Importance.max,
        priority: Priority.high,
        fullScreenIntent: true,
        audioAttributesUsage: AudioAttributesUsage.alarm,
        category: AndroidNotificationCategory.alarm,
        playSound: true,
        enableVibration: true,
        ongoing: true,
        autoCancel: false,
      );

      const detallesIos = DarwinNotificationDetails(
        presentAlert: true,
        presentSound: true,
        presentBadge: true,
        interruptionLevel: InterruptionLevel.critical,
      );

      const detallesGenerales = NotificationDetails(
        android: detallesAndroid,
        iOS: detallesIos,
      );

      await _pluginNotificaciones.zonedSchedule(
        id: idNotificacion,
        title: tituloNotificacion,
        body: cuerpoNotificacion,
        scheduledDate: tz.TZDateTime.from(momentoDisparo, tz.local),
        notificationDetails: detallesGenerales,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );
    } catch (e) {
      debugPrint('Error al programar alarma: $e');
    }
  }

  Future<void> cancelarAlarma(String idTarea) async {
    try {
      await _pluginNotificaciones.cancel(id: _obtenerIdNotificacion(idTarea));
    } catch (e) {
      debugPrint('Error al cancelar alarma: $e');
    }
  }
}
