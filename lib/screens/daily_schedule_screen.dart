import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../config/theme/app_colors.dart';
import '../models/task_model.dart';
import '../providers/agenda_provider.dart';
import '../widgets/notebook_scaffold.dart';

class DailyScheduleScreen extends StatefulWidget {
  const DailyScheduleScreen({super.key});

  @override
  State<DailyScheduleScreen> createState() => _DailyScheduleScreenState();
}

class _DailyScheduleScreenState extends State<DailyScheduleScreen> {
  double _porcentajeEnergia = 50.0;
  TimeOfDay _horaInicioJornada = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay _horaFinJornada = const TimeOfDay(hour: 17, minute: 0);

  Future<void> _seleccionarHoraInicio(BuildContext contexto) async {
    final TimeOfDay? horaElegida = await showTimePicker(
      context: contexto,
      initialTime: _horaInicioJornada,
    );
    if (horaElegida != null) setState(() => _horaInicioJornada = horaElegida);
  }

  Future<void> _seleccionarHoraFin(BuildContext contexto) async {
    final TimeOfDay? horaElegida = await showTimePicker(
      context: contexto,
      initialTime: _horaFinJornada,
    );
    if (horaElegida != null) setState(() => _horaFinJornada = horaElegida);
  }

  String _obtenerTextoEnergia(int energia) {
    if (energia >= 81) return 'Máxima (Dificultades 5 y 4 + Urgencias de hoy)';
    if (energia >= 61) return 'Buena (Dificultades 4 y 3 + Urgencias de hoy)';
    if (energia >= 41) return 'Media (Dificultades 3 y 2 + Urgencias de hoy)';
    if (energia >= 21) return 'Baja (Dificultades 2 y 1 + Urgencias de hoy)';
    return 'Mínima (Dificultad 1 + Urgencias obligatorias de hoy)';
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AgendaProvider>(
      builder: (context, proveedor, child) {
        final List<BloqueHorarioInteligente> bloquesHorario =
            proveedor.calcularHorarioPorEnergia(
          porcentajeEnergia: _porcentajeEnergia.round(),
          horaInicioJornada: _horaInicioJornada,
          horaFinJornada: _horaFinJornada,
        );

        final momentoActual = DateTime.now();

        return NotebookScaffold(
          contenido: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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

              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.black12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Tu nivel de energía hoy:',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textoOscuro),
                        ),
                        Text(
                          '${_porcentajeEnergia.round()}%',
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.botonOscuro),
                        ),
                      ],
                    ),
                    Slider(
                      value: _porcentajeEnergia,
                      min: 0,
                      max: 100,
                      divisions: 100,
                      activeColor: AppColors.botonOscuro,
                      onChanged: (v) => setState(() => _porcentajeEnergia = v),
                    ),
                    Center(
                      child: Text(
                        _obtenerTextoEnergia(_porcentajeEnergia.round()),
                        style: const TextStyle(fontSize: 11, fontStyle: FontStyle.italic, color: AppColors.textoSecundario),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Divider(color: AppColors.lineaMargenHoja, height: 1),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Expanded(
                          child: Text('Tiempo disponible:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textoOscuro)),
                        ),
                        InkWell(
                          onTap: () => _seleccionarHoraInicio(context),
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.lineaMargenHoja.withValues(alpha: 0.5),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(_horaInicioJornada.format(context), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textoOscuro)),
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
                              color: AppColors.lineaMargenHoja.withValues(alpha: 0.5),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(_horaFinJornada.format(context), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textoOscuro)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Plan sugerido para hoy', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textoOscuro)),
                  Text('${bloquesHorario.length} actividades', style: const TextStyle(fontSize: 12, color: AppColors.textoSecundario)),
                ],
              ),
              const SizedBox(height: 6),

              Expanded(
                child: bloquesHorario.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.checklist_rtl_rounded, size: 50, color: AppColors.textoSecundario.withValues(alpha: 0.3)),
                            const SizedBox(height: 8),
                            const Text('No hay tareas que encajen en tu jornada', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textoSecundario)),
                            const SizedBox(height: 4),
                            const Text('Ajusta el rango de horas disponibles o crea nuevas tareas.', textAlign: TextAlign.center, style: TextStyle(fontSize: 12, color: AppColors.textoSecundario)),
                          ],
                        ),
                      )
                    : ListView.builder(
                        physics: const BouncingScrollPhysics(),
                        itemCount: bloquesHorario.length,
                        itemBuilder: (context, indice) {
                          final bloque = bloquesHorario[indice];
                          final TaskModel tarea = bloque.tarea;
                          final Color colorDificultad = AppColors.obtenerColorPrioridad(tarea.nivelPrioridad);

                          final bool esVencimientoHoy = tarea.fechaHoraEntrega.day == momentoActual.day &&
                              tarea.fechaHoraEntrega.month == momentoActual.month;

                          return Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: colorDificultad.withValues(alpha: 0.4),
                                width: 1.5,
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: colorDificultad.withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Column(
                                    children: [
                                      Text(bloque.horaInicio.format(context), style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: colorDificultad)),
                                      const Text('|', style: TextStyle(fontSize: 10, color: AppColors.textoSecundario)),
                                      Text(bloque.horaFin.format(context), style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: colorDificultad)),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              tarea.titulo,
                                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textoOscuro),
                                            ),
                                          ),
                                          if (esVencimientoHoy)
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                              decoration: BoxDecoration(
                                                color: AppColors.prioridadMuyAlta.withValues(alpha: 0.15),
                                                borderRadius: BorderRadius.circular(6),
                                              ),
                                              child: const Text('¡Vence hoy!', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.prioridadMuyAlta)),
                                            ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text('${tarea.minutosEstimadosRealizacion} min estimados', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: colorDificultad)),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.check_circle_outline_rounded, color: AppColors.textoSecundario, size: 22),
                                  onPressed: () => proveedor.conmutarEstadoCompletado(tarea),
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
      },
    );
  }
}