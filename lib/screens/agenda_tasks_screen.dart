import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../config/theme/app_colors.dart';
import '../models/agenda_model.dart';
import '../models/task_model.dart';
import '../providers/agenda_provider.dart';
import '../widgets/notebook_scaffold.dart';
import '../widgets/task_card.dart';

class AgendaTasksScreen extends StatelessWidget {
  final AgendaModel agenda;

  const AgendaTasksScreen({
    super.key,
    required this.agenda,
  });

  @override
  Widget build(BuildContext context) {
    final proveedor = Provider.of<AgendaProvider>(context);
    final tareas = proveedor.obtenerTareasPorAgenda(agenda.id);

    return NotebookScaffold(
      contenido: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Barra superior de navegación interna
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textoOscuro),
                onPressed: () => Navigator.pop(context),
              ),
              const SizedBox(width: 4),
              CircleAvatar(
                radius: 7,
                backgroundColor: Color(agenda.colorHexadecimal),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  agenda.nombre,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textoOscuro,
                  ),
                ),
              ),
            ],
          ),
          const Divider(color: AppColors.lineaMargenHoja, thickness: 1.5),
          const SizedBox(height: 8),

          // Lista de tareas de esta agenda
          Expanded(
            child: tareas.isEmpty
                ? const Center(
                    child: Text(
                      'Esta agenda no tiene tareas aún.',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textoSecundario,
                      ),
                    ),
                  )
                : ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    itemCount: tareas.length,
                    itemBuilder: (context, indice) {
                      final tarea = tareas[indice];
                      final colorPrioridad =
                          AppColors.obtenerColorPrioridad(tarea.nivelPrioridad);

                      return TaskCard(
                        tarea: tarea,
                        onToggleCompletada: (_) {
                          proveedor.conmutarEstadoCompletado(tarea);
                        },
                        onEliminar: () {
                          final tareaEliminada = tarea;
                          proveedor.eliminarTarea(tarea.id);
                          ScaffoldMessenger.of(context).clearSnackBars();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Tarea "${tareaEliminada.titulo}" eliminada'),
                              action: SnackBarAction(
                                label: 'Deshacer',
                                textColor: Colors.amberAccent,
                                onPressed: () => proveedor.agregarTarea(tareaEliminada),
                              ),
                              duration: const Duration(seconds: 4),
                            ),
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}