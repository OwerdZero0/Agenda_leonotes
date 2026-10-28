import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../config/theme/app_colors.dart';
import '../models/task_model.dart';
import '../providers/agenda_provider.dart';
import '../widgets/notebook_scaffold.dart';
import 'new_task_screen.dart';

class TimelineScreen extends StatefulWidget {
  final DateTime? fechaInicial;

  const TimelineScreen({super.key, this.fechaInicial});

  @override
  State<TimelineScreen> createState() => _TimelineScreenState();
}

class _TimelineScreenState extends State<TimelineScreen> {
  late DateTime _diaVisualizado;

  @override
  void initState() {
    super.initState();
    _diaVisualizado = widget.fechaInicial ?? DateTime.now();
  }

  void _ajustarDia(int dias) {
    setState(() {
      _diaVisualizado = _diaVisualizado.add(Duration(days: dias));
    });
  }

  String _obtenerEtiquetaDificultad(int nivel) {
    switch (nivel) {
      case 1:
        return 'Muy baja';
      case 2:
        return 'Baja';
      case 3:
        return 'Media';
      case 4:
        return 'Alta';
      case 5:
        return 'Muy alta';
      default:
        return 'Media';
    }
  }

  @override
  Widget build(BuildContext context) {
    final proveedor = Provider.of<AgendaProvider>(context);
    final listaTareasDia = proveedor.obtenerTareasPorDia(_diaVisualizado);

    // Ordenar cronológicamente por la hora de entrega
    listaTareasDia.sort((primera, segunda) =>
        primera.fechaHoraEntrega.compareTo(segunda.fechaHoraEntrega));

    final bool esHoy = _diaVisualizado.year == DateTime.now().year &&
        _diaVisualizado.month == DateTime.now().month &&
        _diaVisualizado.day == DateTime.now().day;

    return NotebookScaffold(
      contenido: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Selector y encabezado del día
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textoOscuro, size: 18),
                onPressed: () => _ajustarDia(-1),
              ),
              Column(
                children: [
                  Text(
                    esHoy ? 'Línea de Tiempo (Hoy)' : 'Línea de Tiempo',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textoOscuro,
                    ),
                  ),
                  Text(
                    DateFormat('EEEE, d \'de\' MMMM', 'es_ES').format(_diaVisualizado),
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textoSecundario,
                    ),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.arrow_forward_ios_rounded, color: AppColors.textoOscuro, size: 18),
                onPressed: () => _ajustarDia(1),
              ),
            ],
          ),
          const Divider(color: AppColors.lineaMargenHoja, thickness: 1.5),
          const SizedBox(height: 6),

          // Lista cronológica
          Expanded(
            child: listaTareasDia.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.timeline_rounded,
                          size: 56,
                          color: AppColors.textoSecundario.withOpacity(0.3),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'No hay tareas programadas para este día',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textoSecundario,
                          ),
                        ),
                        const SizedBox(height: 10),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.botonOscuro,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          icon: const Icon(Icons.add, color: Colors.white, size: 16),
                          label: const Text('Crear tarea', style: TextStyle(color: Colors.white)),
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
                    itemCount: listaTareasDia.length,
                    itemBuilder: (context, indice) {
                      final tarea = listaTareasDia[indice];
                      final Color colorEstado = tarea.estaCompletada
                          ? AppColors.tareaCompletada
                          : AppColors.obtenerColorPrioridad(tarea.nivelPrioridad);

                      return IntrinsicHeight(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Columna de hora lateral
                            SizedBox(
                              width: 50,
                              child: Text(
                                DateFormat('HH:mm').format(tarea.fechaHoraEntrega),
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textoOscuro,
                                ),
                              ),
                            ),
                            // Indicador vertical con punto y línea conectora
                            Column(
                              children: [
                                Container(
                                  width: 14,
                                  height: 14,
                                  decoration: BoxDecoration(
                                    color: colorEstado,
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.white, width: 2),
                                    boxShadow: [
                                      BoxShadow(
                                        color: colorEstado.withOpacity(0.4),
                                        blurRadius: 4,
                                        spreadRadius: 1,
                                      ),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  child: Container(
                                    width: 2,
                                    color: AppColors.lineaMargenHoja,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(width: 10),

                            // Tarjeta descriptiva de la tarea
                            Expanded(
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 14),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: colorEstado.withOpacity(0.4),
                                    width: 1.5,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.04),
                                      blurRadius: 6,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            tarea.titulo,
                                            style: TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold,
                                              color: AppColors.textoOscuro,
                                              decoration: tarea.estaCompletada
                                                  ? TextDecoration.lineThrough
                                                  : null,
                                            ),
                                          ),
                                        ),
                                        InkWell(
                                          onTap: () => proveedor.conmutarEstadoCompletado(tarea),
                                          child: Icon(
                                            tarea.estaCompletada
                                                ? Icons.check_circle_rounded
                                                : Icons.radio_button_unchecked_rounded,
                                            color: colorEstado,
                                            size: 20,
                                          ),
                                        ),
                                      ],
                                    ),
                                    if (tarea.descripcion.isNotEmpty) ...[
                                      const SizedBox(height: 4),
                                      Text(
                                        tarea.descripcion,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: AppColors.textoSecundario,
                                        ),
                                      ),
                                    ],
                                    const SizedBox(height: 8),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        // Etiqueta de dificultad / prioridad
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color: colorEstado.withOpacity(0.15),
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: Text(
                                            tarea.estaCompletada
                                                ? 'Completada'
                                                : 'Dificultad ${_obtenerEtiquetaDificultad(tarea.nivelPrioridad)}',
                                            style: TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold,
                                              color: colorEstado,
                                            ),
                                          ),
                                        ),
                                        // Tiempo estimado de realización
                                        Row(
                                          children: [
                                            const Icon(
                                              Icons.timer_outlined,
                                              size: 13,
                                              color: AppColors.textoSecundario,
                                            ),
                                            const SizedBox(width: 3),
                                            Text(
                                              '${tarea.minutosEstimadosRealizacion} min',
                                              style: const TextStyle(
                                                fontSize: 11,
                                                color: AppColors.textoSecundario,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
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