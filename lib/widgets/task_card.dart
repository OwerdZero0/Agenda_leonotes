// lib/widgets/task_card.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../config/theme/app_colors.dart';
import '../config/theme/app_spacing.dart';
import '../config/theme/app_text_styles.dart';
import '../models/task_model.dart';

class TaskCard extends StatelessWidget {
  final TaskModel tarea;
  final VoidCallback? onTap;
  final ValueChanged<bool?>? onToggleCompletada;
  final VoidCallback? onEliminar;

  const TaskCard({
    super.key,
    required this.tarea,
    this.onTap,
    this.onToggleCompletada,
    this.onEliminar,
  });

  @override
  Widget build(BuildContext context) {
    final Color colorPrioridad = AppColors.obtenerColorPrioridad(tarea.nivelPrioridad);

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppSpacing.radiusMd,
        border: Border.all(
          color: tarea.estaCompletada
              ? AppColors.tareaCompletada
              : colorPrioridad.withValues(alpha: 0.5),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: AppSpacing.radiusMd,
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
            child: Row(
              children: [
                Checkbox(
                  value: tarea.estaCompletada,
                  activeColor: AppColors.tareaCompletada,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                  onChanged: onToggleCompletada,
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        tarea.titulo,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: tarea.estaCompletada ? AppColors.tareaCompletada : AppColors.textoOscuro,
                          decoration: tarea.estaCompletada ? TextDecoration.lineThrough : null,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (tarea.descripcion.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          tarea.descripcion,
                          style: AppTextStyles.bodySm,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          Icon(Icons.access_time_rounded, size: 12, color: colorPrioridad),
                          const SizedBox(width: 4),
                          Text(
                            DateFormat('dd/MM - HH:mm').format(tarea.fechaHoraEntrega),
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: colorPrioridad,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${tarea.minutosEstimadosRealizacion}m',
                            style: AppTextStyles.caption,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (onEliminar != null)
                  IconButton(
                    icon: const Icon(Icons.delete_outline_rounded, size: 18, color: AppColors.textoSecundario),
                    onPressed: onEliminar,
                    tooltip: 'Eliminar tarea',
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

