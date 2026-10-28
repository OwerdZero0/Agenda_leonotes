import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../config/theme/app_colors.dart';
import '../models/task_model.dart';
import '../providers/agenda_provider.dart';
import '../widgets/notebook_scaffold.dart';
import 'new_task_screen.dart';

class DailyScheduleScreen extends StatefulWidget {
  const DailyScheduleScreen({super.key});

  @override
  State<DailyScheduleScreen> createState() => _DailyScheduleScreenState();
}

class _DailyScheduleScreenState extends State<DailyScheduleScreen> {
  // Estado local para los controles de cálculo
  double _porcentajeEnergia = 80.0;
  TimeOfDay _horaInicioJornada = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay _horaFinJornada = const TimeOfDay(hour: 17, minute: 0);

  Future<void> _seleccionarHoraInicio(BuildContext contexto) async {
    final TimeOfDay? horaElegida = await showTimePicker(
      context: contexto,
      initialTime: _horaInicioJornada,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.botonOscuro,
              onPrimary: Colors.white,
              onSurface: AppColors.textoOscuro,
            ),
          ),
          child: child!,
        );
      },
    );

    if (horaElegida != null) {
      setState(() {
        _horaInicioJornada = horaElegida;
      });
    }
  }

  Future<void> _seleccionarHoraFin(BuildContext contexto) async {
    final TimeOfDay? horaElegida = await showTimePicker(
      context: contexto,
      initialTime: _horaFinJornada,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.botonOscuro,
              onPrimary: Colors.white,
              onSurface: AppColors.textoOscuro,
            ),
          ),
          child: child!,
        );
      },
    );

    if (horaElegida != null) {
      setState(() {
        _horaFinJornada = horaElegida;
      });
    }
  }

  String _obtenerTextoEnergia(int energia) {
    if (energia >= 81) return 'Máxima (Dificultad Muy alta y Alta)';
    if (energia >= 61) return 'Buena (Dificultad Alta y Media)';
    if (energia >= 41) return 'Media (Dificultad Media y Baja)';
    if (energia >= 21) return 'Baja (Dificultad Baja y Muy baja)';
    return 'Mínima (Dificultad Muy baja)';
  }

  @override
  Widget build(BuildContext context) {
    final proveedor = Provider.of<AgendaProvider>(context);

    // Ejecuta el algoritmo del proveedor con los parámetros de la pantalla
    final List<BloqueHorarioInteligente> bloquesHorario =
        proveedor.calcularHorarioPorEnergia(
      porcentajeEnergia: _porcentajeEnergia.round(),
      horaInicioJornada: _horaInicioJornada,
      horaFinJornada: _horaFinJornada,
    );

    return NotebookScaffold(
      contenido: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Título superior
          Row(
            children: const [
              Icon(Icons.bolt_rounded, color: AppColors.prioridadAlta, size: 28),
              SizedBox(width: 8),
              Text(
                'Horario Inteligente',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textoOscuro,
                ),
              ),
            ],
          ),
          const Divider(color: AppColors.lineaMargenHoja, thickness: 1.5),
          const SizedBox(height: 6),

          // Tarjeta de configuración: Nivel de energía y jornada
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.black12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Slider de energía
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Tu nivel de energía hoy:',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textoOscuro,
                      ),
                    ),
                    Text(
                      '${_porcentajeEnergia.round()}%',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppColors.botonOscuro,
                      ),
                    ),
                  ],
                ),
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: AppColors.botonOscuro,
                    inactiveTrackColor: AppColors.lineaMargenHoja,
                    thumbColor: AppColors.botonOscuro,
                    overlayColor: AppColors.botonOscuro.withOpacity(0.12),
                    trackHeight: 4,
                  ),
                  child: Slider(
                    value: _porcentajeEnergia,
                    min: 0,
                    max: 100,
                    divisions: 100,
                    onChanged: (nuevoValor) {
                      setState(() {
                        _porcentajeEnergia = nuevoValor;
                      });
                    },
                  ),
                ),
                Center(
                  child: Text(
                    _obtenerTextoEnergia(_porcentajeEnergia.round()),
                    style: const TextStyle(
                      fontSize: 11,
                      fontStyle: FontStyle.italic,
                      color: AppColors.textoSecundario,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                const Divider(color: AppColors.lineaMargenHoja, height: 1),
                const SizedBox(height: 8),

                // Selector de jornada disponible (de qué hora a qué hora)
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Tiempo disponible:',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textoOscuro,
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () => _seleccionarHoraInicio(context),
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.lineaMargenHoja.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _horaInicioJornada.format(context),
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textoOscuro,
                          ),
                        ),
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 6),
                      child: Text('a', style: TextStyle(color: AppColors.textoSecundario)),
                    ),
                    InkWell(
                      onTap: () => _seleccionarHoraFin(context),
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.lineaMargenHoja.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _horaFinJornada.format(context),
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textoOscuro,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Título de la lista generada
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Plan sugerido para hoy',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textoOscuro,
                ),
              ),
              Text(
                '${bloquesHorario.length} actividades',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textoSecundario,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),

          // Lista de bloques planificados por el algoritmo
          Expanded(
            child: bloquesHorario.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.checklist_rtl_rounded,
                          size: 50,
                          color: AppColors.textoSecundario.withOpacity(0.3),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'No hay tareas pendientes acordes',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textoSecundario,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          child: Text(
                            'Prueba ajustando el slider de energía o el rango horario de tu jornada.',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 12, color: AppColors.textoSecundario),
                          ),
                        ),
                        const SizedBox(height: 12),
                        OutlinedButton.icon(
                          icon: const Icon(Icons.add, size: 16, color: AppColors.botonOscuro),
                          label: const Text(
                            'Crear nueva tarea',
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
                    itemCount: bloquesHorario.length,
                    itemBuilder: (context, indice) {
                      final bloque = bloquesHorario[indice];
                      final TaskModel tarea = bloque.tarea;
                      final Color colorDificultad =
                          AppColors.obtenerColorPrioridad(tarea.nivelPrioridad);

                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: colorDificultad.withOpacity(0.4),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.02),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Franja horaria calculada
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                              decoration: BoxDecoration(
                                color: colorDificultad.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Column(
                                children: [
                                  Text(
                                    bloque.horaInicio.format(context),
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: colorDificultad,
                                    ),
                                  ),
                                  const Text(
                                    '|',
                                    style: TextStyle(fontSize: 10, color: AppColors.textoSecundario),
                                  ),
                                  Text(
                                    bloque.horaFin.format(context),
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: colorDificultad,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),

                            // Detalles de la tarea
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    tarea.titulo,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textoOscuro,
                                    ),
                                  ),
                                  if (tarea.descripcion.isNotEmpty) ...[
                                    const SizedBox(height: 2),
                                    Text(
                                      tarea.descripcion,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: AppColors.textoSecundario,
                                      ),
                                    ),
                                  ],
                                  const SizedBox(height: 6),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.timer_outlined,
                                        size: 13,
                                        color: colorDificultad,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        '${tarea.minutosEstimadosRealizacion} min estimados',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          color: colorDificultad,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),

                            // Checkbox para completarla directamente
                            IconButton(
                              icon: const Icon(
                                Icons.check_circle_outline_rounded,
                                color: AppColors.textoSecundario,
                                size: 22,
                              ),
                              tooltip: 'Marcar completada',
                              onPressed: () {
                                proveedor.conmutarEstadoCompletado(tarea);
                              },
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