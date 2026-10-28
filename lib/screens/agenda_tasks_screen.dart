import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../config/theme/app_colors.dart';
import '../models/agenda_model.dart';
import '../models/task_model.dart';
import '../providers/agenda_provider.dart';
import '../widgets/notebook_scaffold.dart';

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

                      return Card(
                        margin: const EdgeInsets.only(bottom: 10),
                        elevation: 0.5,
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color: tarea.estaCompletada
                                ? AppColors.tareaCompletada.withOpacity(0.5)
                                : colorPrioridad.withOpacity(0.5),
                            width: 1.5,
                          ),
                        ),
                        child: ListTile(
                          contentPadding:
                              const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          leading: Checkbox(
                            value: tarea.estaCompletada,
                            activeColor: AppColors.tareaCompletada,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4),
                            ),
                            onChanged: (_) {
                              proveedor.conmutarEstadoCompletado(tarea);
                            },
                          ),
                          title: Text(
                            tarea.titulo,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppColors.textoOscuro,
                              decoration: tarea.estaCompletada
                                  ? TextDecoration.lineThrough
                                  : null,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (tarea.descripcion.isNotEmpty)
                                Text(
                                  tarea.descripcion,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textoSecundario,
                                  ),
                                ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(
                                    Icons.access_time_rounded,
                                    size: 13,
                                    color: colorPrioridad,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    DateFormat('dd/MM/yyyy - HH:mm')
                                        .format(tarea.fechaHoraEntrega),
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: colorPrioridad,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          trailing: IconButton(
                            icon: const Icon(
                              Icons.delete_outline_rounded,
                              color: AppColors.textoSecundario,
                              size: 19,
                            ),
                            onPressed: () => proveedor.eliminarTarea(tarea.id),
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