import 'package:flutter/material.dart';

import '../config/theme/app_colors.dart';
import 'agendas_screen.dart';
import 'calendar_screen.dart';
import 'daily_schedule_screen.dart';
import 'home_screen.dart';
import 'new_task_screen.dart';
import 'timeline_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  final int indiceInicial;
  const MainNavigationScreen({super.key, this.indiceInicial = 0});

  static MainNavigationScreenState? of(BuildContext context) =>
      context.findAncestorStateOfType<MainNavigationScreenState>();

  @override
  MainNavigationScreenState createState() => MainNavigationScreenState();
}

class MainNavigationScreenState extends State<MainNavigationScreen> {
  late int _indiceSeleccionado;

  @override
  void initState() {
    super.initState();
    _indiceSeleccionado = widget.indiceInicial;
  }

  void cambiarPestana(int nuevoIndice) {
    setState(() {
      _indiceSeleccionado = nuevoIndice;
    });
  }

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
              color: Colors.black.withValues(alpha: 0.06),
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
              _construirBotonNavegacion(0, Icons.home_rounded, 'Inicio', 'Home / Menú Principal'),
              _construirBotonNavegacion(1, Icons.menu_book_rounded, 'Agendas', 'Mis Agendas'),
              _construirBotonNavegacion(2, Icons.calendar_month_rounded, 'Calendario', 'Calendario'),
              _construirBotonNavegacion(3, Icons.timeline_rounded, 'Timeline', 'Línea del tiempo de hoy'),
              _construirBotonNavegacion(4, Icons.checklist_rtl_rounded, 'Horario', 'Horario Inteligente'),
              Tooltip(
                message: 'Nueva Tarea',
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => NewTaskScreen(
                          alGuardarExitoso: () {
                            cambiarPestana(1);
                          },
                        ),
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.botonOscuro,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(Icons.add_rounded, color: Colors.white, size: 24),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _construirBotonNavegacion(int indice, IconData icono, String etiqueta, String tooltip) {
    final bool estaActivo = _indiceSeleccionado == indice;
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: () => cambiarPestana(indice),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: estaActivo ? AppColors.botonOscuro.withValues(alpha: 0.12) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icono,
                size: 22,
                color: estaActivo ? AppColors.botonOscuro : AppColors.textoOscuro.withValues(alpha: 0.6),
              ),
              const SizedBox(height: 2),
              Text(
                etiqueta,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: estaActivo ? FontWeight.bold : FontWeight.normal,
                  color: estaActivo ? AppColors.botonOscuro : AppColors.textoOscuro.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
