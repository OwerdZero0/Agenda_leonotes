import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';

import 'config/theme/app_colors.dart';
import 'config/theme/app_theme.dart';
import 'models/agenda_model.dart';
import 'models/task_model.dart';
import 'providers/agenda_provider.dart';
import 'screens/splash_screen.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar formateo en español para intl (evita pantalla gris en calendario y timeline)
  await initializeDateFormatting('es_ES', null);

  // Inicializar Hive
  await Hive.initFlutter();
  Hive.registerAdapter(AgendaModelAdapter());
  Hive.registerAdapter(TaskModelAdapter());

  await Hive.openBox<AgendaModel>('caja_agendas');
  await Hive.openBox<TaskModel>('caja_tareas');

  // Inicializar notificaciones locales
  await NotificationService().inicializarServicio();

  runApp(const AplicacionAgenda());
}

class AplicacionAgenda extends StatelessWidget {
  const AplicacionAgenda({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AgendaProvider()..inicializarProveedor(),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Agenda Inteligente',
        theme: AppTheme.temaClaro,
        home: const SplashScreen(),
      ),
    );
  }
}