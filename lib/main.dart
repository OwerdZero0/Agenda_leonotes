import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

import 'config/theme/app_colors.dart';
import 'models/agenda_model.dart';
import 'models/task_model.dart';
import 'providers/agenda_provider.dart';
import 'screens/splash_screen.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Inicialización de Hive Local
  await Hive.initFlutter();
  Hive.registerAdapter(AgendaModelAdapter());
  Hive.registerAdapter(TaskModelAdapter());

  await Hive.openBox<AgendaModel>('caja_agendas');
  await Hive.openBox<TaskModel>('caja_tareas');

  // 2. Inicialización del Servicio de Alarmas y Notificaciones
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
        title: 'Agenda',
        theme: ThemeData(
          scaffoldBackgroundColor: AppColors.portadaLibreta,
          useMaterial3: true,
        ),
        // Arranca con la SplashScreen que luego da paso a MainNavigationScreen
        home: const SplashScreen(),
      ),
    );
  }
}