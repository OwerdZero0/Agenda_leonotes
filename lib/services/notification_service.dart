// lib/services/notification_service.dart
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
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
  }

  Future<void> programarAlarmaTarea(TaskModel tarea) async {
    final int idNotificacion = tarea.id.hashCode;
    await cancelarAlarma(tarea.id);

    // Si ya venció la fecha de entrega, no se programa
    if (tarea.fechaHoraEntrega.isBefore(DateTime.now())) return;

    DateTime momentoDisparo;
    String tituloNotificacion;
    String cuerpoNotificacion;

    if (tarea.estaCompletada) {
      momentoDisparo = tarea.fechaHoraEntrega;
      tituloNotificacion = '¡Momento de entregar!: ${tarea.titulo}';
      cuerpoNotificacion = 'Ya completaste esta tarea. No olvides entregarla a tiempo.';
    } else {
      momentoDisparo = tarea.fechaHoraEntrega.subtract(Duration(minutes: tarea.minutosAvisoAnticipado));
      if (momentoDisparo.isBefore(DateTime.now())) {
        momentoDisparo = DateTime.now().add(const Duration(seconds: 5));
      }
      tituloNotificacion = 'Aviso de tarea: ${tarea.titulo}';
      cuerpoNotificacion = 'Faltan ${tarea.minutosAvisoAnticipado} minutos para el plazo de entrega.';
    }

    const detallesAndroid = AndroidNotificationDetails(
      'canal_alarmas_agenda',
      'Alarmas de Agenda',
      channelDescription: 'Avisos con sonido y alerta continua de tareas',
      importance: Importance.max,
      priority: Priority.high,
      fullScreenIntent: true,
      audioAttributesUsage: AudioAttributesUsage.alarm,
      category: AndroidNotificationCategory.alarm,
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

    // Parámetros nombrados según la nueva API del paquete
    await _pluginNotificaciones.zonedSchedule(
      id: idNotificacion,
      title: tituloNotificacion,
      body: cuerpoNotificacion,
      scheduledDate: tz.TZDateTime.from(momentoDisparo, tz.local),
      notificationDetails: detallesGenerales,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  Future<void> cancelarAlarma(String idTarea) async {
    // El parámetro ahora exige 'id:' nombrado
    await _pluginNotificaciones.cancel(id: idTarea.hashCode);
  }
}