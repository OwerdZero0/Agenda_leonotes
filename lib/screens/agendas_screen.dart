import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../config/theme/app_colors.dart';
import '../models/agenda_model.dart';
import '../providers/agenda_provider.dart';
import '../widgets/notebook_scaffold.dart';
import 'agenda_tasks_screen.dart';

class AgendasScreen extends StatelessWidget {
  const AgendasScreen({super.key});

  Future<void> _mostrarDialogoNuevaAgenda(BuildContext contexto) async {
    final TextEditingController controladorNombre = TextEditingController();
    int colorSeleccionado = 0xFF1976D2;

    await showDialog(
      context: contexto,
      builder: (contextoDialogo) {
        return StatefulBuilder(
          builder: (context, setEstadoDialogo) {
            return AlertDialog(
              backgroundColor: AppColors.hojaLibreta,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: const Text(
                'Nueva Agenda',
                style: TextStyle(
                  color: AppColors.textoOscuro,
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: controladorNombre,
                    autofocus: true,
                    style: const TextStyle(color: AppColors.textoOscuro),
                    decoration: InputDecoration(
                      labelText: 'Nombre de la agenda',
                      labelStyle: const TextStyle(color: AppColors.textoSecundario),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.lineaMargenHoja),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Color distintivo:',
                    style: TextStyle(
                      color: AppColors.textoOscuro,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      0xFF1976D2, // Azul
                      0xFF388E3C, // Verde
                      0xFFD32F2F, // Rojo
                      0xFFF57C00, // Naranja
                      0xFF7B1FA2, // Morado
                      0xFF00796B, // Verde Azulado
                    ].map((colorHex) {
                      final bool esSeleccionado = colorSeleccionado == colorHex;
                      return GestureDetector(
                        onTap: () {
                          setEstadoDialogo(() {
                            colorSeleccionado = colorHex;
                          });
                        },
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: Color(colorHex),
                            shape: BoxShape.circle,
                            border: esSeleccionado
                                ? Border.all(color: AppColors.botonOscuro, width: 3)
                                : null,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(contextoDialogo),
                  child: const Text(
                    'Cancelar',
                    style: TextStyle(color: AppColors.textoSecundario),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.botonOscuro,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: () async {
                    if (controladorNombre.text.trim().isNotEmpty) {
                      final proveedor = Provider.of<AgendaProvider>(contexto, listen: false);
                      final nuevaAgenda = AgendaModel(
                        id: const Uuid().v4(),
                        nombre: controladorNombre.text.trim(),
                        colorHexadecimal: colorSeleccionado,
                      );
                      await proveedor.agregarAgenda(nuevaAgenda);
                      if (contextoDialogo.mounted) {
                        Navigator.pop(contextoDialogo);
                      }
                    }
                  },
                  child: const Text('Crear', style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _confirmarEliminarAgenda(BuildContext contexto, AgendaModel agenda) async {
    final confirmar = await showDialog<bool>(
      context: contexto,
      builder: (contextoDialogo) {
        return AlertDialog(
          backgroundColor: AppColors.hojaLibreta,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text(
            '¿Eliminar agenda?',
            style: TextStyle(
              color: AppColors.textoOscuro,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            'Se eliminará la agenda "${agenda.nombre}" y todas las tareas asociadas a ella de forma permanente.',
            style: const TextStyle(color: AppColors.textoOscuro),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(contextoDialogo, false),
              child: const Text(
                'Cancelar',
                style: TextStyle(color: AppColors.textoSecundario),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.prioridadMuyAlta,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () => Navigator.pop(contextoDialogo, true),
              child: const Text('Eliminar', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );

    if (confirmar == true && contexto.mounted) {
      final proveedor = Provider.of<AgendaProvider>(contexto, listen: false);
      await proveedor.eliminarAgenda(agenda.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final proveedor = Provider.of<AgendaProvider>(context);
    final listaAgendas = proveedor.listaAgendas;

    return NotebookScaffold(
      contenido: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cabecera superior
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Mis Agendas',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textoOscuro,
                ),
              ),
              IconButton.filled(
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.botonOscuro,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                icon: const Icon(Icons.add, color: Colors.white),
                tooltip: 'Nueva Agenda',
                onPressed: () => _mostrarDialogoNuevaAgenda(context),
              ),
            ],
          ),
          const Divider(color: AppColors.lineaMargenHoja, thickness: 1.5),
          const SizedBox(height: 8),

          // Lista de Agendas o estado vacío
          Expanded(
            child: listaAgendas.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.menu_book_rounded,
                          size: 64,
                          color: AppColors.textoSecundario.withOpacity(0.4),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'No hay agendas creadas',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textoSecundario,
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Toca el botón "+" arriba para añadir tu primera agenda.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.textoSecundario,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    itemCount: listaAgendas.length,
                    itemBuilder: (context, indice) {
                      final agenda = listaAgendas[indice];
                      final double progreso = proveedor.calcularProgresoAgenda(agenda.id);
                      final tareasAsociadas = proveedor.obtenerTareasPorAgenda(agenda.id);
                      final int totalTareas = tareasAsociadas.length;
                      final int tareasCompletadas =
                          tareasAsociadas.where((tarea) => tarea.estaCompletada).length;

                      return Card(
                        margin: const EdgeInsets.only(bottom: 14),
                        elevation: 1,
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: BorderSide(
                            color: Color(agenda.colorHexadecimal).withOpacity(0.4),
                            width: 1.5,
                          ),
                        ),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => AgendaTasksScreen(agenda: agenda),
                              ),
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(14),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 8,
                                      backgroundColor: Color(agenda.colorHexadecimal),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        agenda.nombre,
                                        style: const TextStyle(
                                          fontSize: 17,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.textoOscuro,
                                        ),
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.delete_outline_rounded,
                                        color: AppColors.textoSecundario,
                                        size: 20,
                                      ),
                                      onPressed: () =>
                                          _confirmarEliminarAgenda(context, agenda),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      totalTareas == 0
                                          ? 'Sin tareas pendientes'
                                          : '$tareasCompletadas de $totalTareas completadas',
                                      style: const TextStyle(
                                        fontSize: 13,
                                        color: AppColors.textoSecundario,
                                      ),
                                    ),
                                    Text(
                                      '${(progreso * 100).toInt()}%',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        color: Color(agenda.colorHexadecimal),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: LinearProgressIndicator(
                                    value: totalTareas == 0 ? 0.0 : progreso,
                                    minHeight: 7,
                                    backgroundColor: Colors.black12,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Color(agenda.colorHexadecimal),
                                    ),
                                  ),
                                ),
                              ],
                            ),
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