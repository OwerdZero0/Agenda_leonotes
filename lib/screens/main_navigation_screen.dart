import 'package:flutter/material.dart';

import '../config/theme/app_colors.dart';
import 'agendas_screen.dart';
import 'calendar_screen.dart';
import 'daily_schedule_screen.dart';
import 'home_screen.dart';
import 'new_task_screen.dart';
import 'timeline_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _indiceSeleccionado = 0;

  // Lista de pantallas principales accesibles desde la barra
  final List<Widget> _pantallas = const [
    HomeScreen(),
    AgendasScreen(),
    CalendarScreen(),
    TimelineScreen(),
    DailyScheduleScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.portadaLibreta,
      body: IndexedStack(
        index: _indiceSeleccionado,
        children: _pantallas,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.portadaLibreta,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: SafeArea(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // 1. Menú Principal / Home
              _construirBotonNavegacion(
                indice: 0,
                icono: Icons.home_rounded,
                mensajeTooltip: 'Home / Menú Principal',
              ),

              // 2. Mis Agendas
              _construirBotonNavegacion(
                indice: 1,
                icono: Icons.menu_book_rounded,
                mensajeTooltip: 'Mis Agendas',
              ),

              // 3. Calendario
              _construirBotonNavegacion(
                indice: 2,
                icono: Icons.calendar_month_rounded,
                mensajeTooltip: 'Calendario',
              ),

              // 4. Línea del tiempo de hoy
              _construirBotonNavegacion(
                indice: 3,
                icono: Icons.timeline_rounded,
                mensajeTooltip: 'Línea del tiempo de hoy',
              ),

              // 5. Horario Inteligente
              _construirBotonNavegacion(
                indice: 4,
                icono: Icons.checklist_rtl_rounded,
                mensajeTooltip: 'Horario Inteligente',
              ),

              // 6. Botón flotante para Nueva Tarea (+)
              Tooltip(
                message: 'Nueva Tarea',
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const NewTaskScreen()),
                    );
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.botonOscuro,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 5,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.add_rounded,
                      color: Colors.white,
                      size: 26,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _construirBotonNavegacion({
    required int indice,
    required IconData icono,
    required String mensajeTooltip,
  }) {
    final bool estaActivo = _indiceSeleccionado == indice;

    return Tooltip(
      message: mensajeTooltip,
      child: InkWell(
        onTap: () {
          setState(() {
            _indiceSeleccionado = indice;
          });
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: estaActivo ? AppColors.botonOscuro.withOpacity(0.12) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icono,
            size: 26,
            color: estaActivo ? AppColors.botonOscuro : AppColors.textoOscuro.withOpacity(0.5),
          ),
        ),
      ),
    );
  }
}