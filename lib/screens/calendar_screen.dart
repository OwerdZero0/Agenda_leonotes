import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../config/theme/app_colors.dart';
import '../models/task_model.dart';
import '../providers/agenda_provider.dart';
import '../widgets/notebook_scaffold.dart';
import 'new_task_screen.dart';
import 'timeline_screen.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _mesActual = DateTime(DateTime.now().year, DateTime.now().month, 1);
  DateTime _diaSeleccionado = DateTime.now();

  void _cambiarMes(int desplazamiento) {
    setState(() {
      _mesActual = DateTime(_mesActual.year, _mesActual.month + desplazamiento, 1);
    });
  }

  bool _esMismoDia(DateTime primera, DateTime segunda) {
    return primera.year == segunda.year &&
        primera.month == segunda.month &&
        primera.day == segunda.day;
  }

  @override
  Widget build(BuildContext context) {
    final proveedor = Provider.of<AgendaProvider>(context);
    final tareasDelDia = proveedor.obtenerTareasPorDia(_diaSeleccionado);

    // Cálculos para la cuadrícula del calendario
    final int diasEnMes = DateTime(_mesActual.year, _mesActual.month + 1, 0).day;
    final int primerDiaSemana = _mesActual.weekday; // 1 = Lunes, 7 = Domingo

    return NotebookScaffold(
      contenido: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cabecera del mes y controles
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left_rounded, color: AppColors.textoOscuro),
                onPressed: () => _cambiarMes(-1),
              ),
              Text(
                DateFormat('MMMM yyyy', 'es_ES').format(_mesActual).toUpperCase(),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textoOscuro,
                  letterSpacing: 0.8,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right_rounded, color: AppColors.textoOscuro),
                onPressed: () => _cambiarMes(1),
              ),
            ],
          ),
          const Divider(color: AppColors.lineaMargenHoja, thickness: 1.5),

          // Nombres de los días de la semana
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: const ['L', 'M', 'M', 'J', 'V', 'S', 'D'].map((dia) {
              return SizedBox(
                width: 32,
                child: Center(
                  child: Text(
                    dia,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textoSecundario,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 6),

          // Cuadrícula de días
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 42, // 6 filas de 7 días
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 3,
              crossAxisSpacing: 3,
              childAspectRatio: 1.15,
            ),
            itemBuilder: (context, indice) {
              final int offsetDia = indice - (primerDiaSemana - 1);
              if (offsetDia < 0 || offsetDia >= diasEnMes) {
                return const SizedBox.shrink();
              }

              final fechaCasilla = DateTime(_mesActual.year, _mesActual.month, offsetDia + 1);
              final bool esSeleccionado = _esMismoDia(fechaCasilla, _diaSeleccionado);
              final bool esHoy = _esMismoDia(fechaCasilla, DateTime.now());
              final tareasCasilla = proveedor.obtenerTareasPorDia(fechaCasilla);

              return GestureDetector(
                onTap: () {
                  setState(() {
                    _diaSeleccionado = fechaCasilla;
                  });
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: esSeleccionado
                        ? AppColors.botonOscuro
                        : (esHoy ? AppColors.lineaMargenHoja : Colors.transparent),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${fechaCasilla.day}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: esSeleccionado || esHoy ? FontWeight.bold : FontWeight.normal,
                          color: esSeleccionado ? Colors.white : AppColors.textoOscuro,
                        ),
                      ),
                      // Indicadores de tareas en esa fecha
                      if (tareasCasilla.isNotEmpty)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: tareasCasilla.take(3).map((tarea) {
                            return Container(
                              margin: const EdgeInsets.symmetric(horizontal: 1),
                              width: 4,
                              height: 4,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: esSeleccionado
                                    ? Colors.white
                                    : AppColors.obtenerColorPrioridad(tarea.nivelPrioridad),
                              ),
                            );
                          }).toList(),
                        )
                      else
                        const SizedBox(height: 4),
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 8),

          // Título de sección de pendientes para el día elegido
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Tareas del ${DateFormat('dd/MM/yyyy').format(_diaSeleccionado)}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textoOscuro,
                ),
              ),
              TextButton.icon(
                icon: const Icon(Icons.timeline_rounded, size: 16, color: AppColors.botonOscuro),
                label: const Text(
                  'Ver línea de tiempo',
                  style: TextStyle(fontSize: 12, color: AppColors.botonOscuro),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => TimelineScreen(fechaInicial: _diaSeleccionado),
                    ),
                  );
                },
              ),
            ],
          ),
          const Divider(color: AppColors.lineaMargenHoja, thickness: 1),

          // Lista de tareas del día seleccionado
          Expanded(
            child: tareasDelDia.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'No hay tareas para este día',
                          style: TextStyle(color: AppColors.textoSecundario, fontSize: 13),
                        ),
                        const SizedBox(height: 6),
                        OutlinedButton.icon(
                          icon: const Icon(Icons.add, size: 16, color: AppColors.botonOscuro),
                          label: const Text(
                            'Agregar tarea',
                            style: TextStyle(color: AppColors.botonOscuro, fontSize: 12),
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const NewTaskScreen()),
                            );
                          },
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    itemCount: tareasDelDia.length,
                    itemBuilder: (context, indice) {
                      final tarea = tareasDelDia[indice];
                      final colorPrioridad =
                          AppColors.obtenerColorPrioridad(tarea.nivelPrioridad);

                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: tarea.estaCompletada
                                ? AppColors.tareaCompletada
                                : colorPrioridad.withOpacity(0.5),
                            width: 1.2,
                          ),
                        ),
                        child: ListTile(
                          dense: true,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                          leading: Checkbox(
                            value: tarea.estaCompletada,
                            activeColor: AppColors.tareaCompletada,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                            onChanged: (_) => proveedor.conmutarEstadoCompletado(tarea),
                          ),
                          title: Text(
                            tarea.titulo,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              decoration: tarea.estaCompletada ? TextDecoration.lineThrough : null,
                              color: AppColors.textoOscuro,
                            ),
                          ),
                          subtitle: Text(
                            'Entrega: ${DateFormat('HH:mm').format(tarea.fechaHoraEntrega)}',
                            style: const TextStyle(fontSize: 11, color: AppColors.textoSecundario),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Signo de admiración con el color de su dificultad
                              Icon(
                                Icons.priority_high_rounded,
                                color: colorPrioridad,
                                size: 18,
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline_rounded, size: 18),
                                color: AppColors.textoSecundario,
                                onPressed: () => proveedor.eliminarTarea(tarea.id),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}