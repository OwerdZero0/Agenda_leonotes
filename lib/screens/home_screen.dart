import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../config/theme/app_colors.dart';
import '../models/task_model.dart';
import '../providers/agenda_provider.dart';
import '../widgets/notebook_scaffold.dart';
import '../widgets/task_card.dart';
import 'main_navigation_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _controladorBusqueda = TextEditingController();
  bool _mostrarVencidas = false;

  @override
  void dispose() {
    _controladorBusqueda.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AgendaProvider>(
      builder: (context, proveedor, child) {
        final bool hayBusquedaActiva = proveedor.terminoBusqueda.isNotEmpty;
        final listaAgendasCoincidentes = proveedor.agendasFiltradas;
        final listaTareasCoincidentes = proveedor.tareasFiltradasPorTitulo;
        final tareasVencidas = proveedor.tareasVencidas;
        final tareasProximas = proveedor.tareasProximas;

        return NotebookScaffold(
          contenido: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        '¡Hola!',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textoOscuro,
                        ),
                      ),
                      Text(
                        'Organiza tu día con tu agenda',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textoSecundario,
                        ),
                      ),
                    ],
                  ),
                  const CircleAvatar(
                    radius: 20,
                    backgroundColor: AppColors.lineaMargenHoja,
                    child: Icon(Icons.person_rounded, color: AppColors.botonOscuro),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _controladorBusqueda,
                  onChanged: (valor) => proveedor.actualizarBusqueda(valor),
                  style: const TextStyle(color: AppColors.textoOscuro, fontSize: 14),
                  decoration: InputDecoration(
                    hintText: 'Buscar agenda o título de tarea...',
                    hintStyle: const TextStyle(color: AppColors.textoSecundario, fontSize: 13),
                    prefixIcon: const Icon(Icons.search_rounded, color: AppColors.textoSecundario),
                    suffixIcon: hayBusquedaActiva
                        ? IconButton(
                            icon: const Icon(Icons.close_rounded, size: 18, color: AppColors.textoSecundario),
                            onPressed: () {
                              _controladorBusqueda.clear();
                              proveedor.actualizarBusqueda('');
                            },
                          )
                        : null,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              if (hayBusquedaActiva) ...[
                const Text(
                  'Resultados de búsqueda',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textoOscuro),
                ),
                const SizedBox(height: 6),
                Expanded(
                  child: _construirResultadosBusqueda(
                    context,
                    proveedor,
                    listaAgendasCoincidentes,
                    listaTareasCoincidentes,
                  ),
                ),
              ] else ...[
                SizedBox(
                  height: 76,
                  child: Row(
                    children: [
                      _construirAccesoDirecto(context, indicePestana: 1, icono: Icons.menu_book_rounded, titulo: 'Mis Agendas', color: const Color(0xFF1976D2)),
                      const SizedBox(width: 8),
                      _construirAccesoDirecto(context, indicePestana: 2, icono: Icons.calendar_month_rounded, titulo: 'Calendario', color: const Color(0xFF388E3C)),
                      const SizedBox(width: 8),
                      _construirAccesoDirecto(context, indicePestana: 3, icono: Icons.timeline_rounded, titulo: 'Hoy', color: const Color(0xFFF57C00)),
                      const SizedBox(width: 8),
                      _construirAccesoDirecto(context, indicePestana: 4, icono: Icons.bolt_rounded, titulo: 'Inteligente', color: const Color(0xFF7B1FA2)),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                Container(
                  height: 38,
                  decoration: BoxDecoration(
                    color: AppColors.lineaMargenHoja.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _mostrarVencidas = false),
                          child: Container(
                            decoration: BoxDecoration(
                              color: !_mostrarVencidas ? AppColors.botonOscuro : Colors.transparent,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              'Próximas (${tareasProximas.length})',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: !_mostrarVencidas ? Colors.white : AppColors.textoOscuro,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _mostrarVencidas = true),
                          child: Container(
                            decoration: BoxDecoration(
                              color: _mostrarVencidas ? AppColors.prioridadMuyAlta : Colors.transparent,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              'Vencidas (${tareasVencidas.length})',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: _mostrarVencidas ? Colors.white : AppColors.textoOscuro,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: _construirListaTareas(
                    context,
                    proveedor,
                    _mostrarVencidas ? tareasVencidas : tareasProximas,
                    esVencidas: _mostrarVencidas,
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _construirAccesoDirecto(
    BuildContext contexto, {
    required int indicePestana,
    required IconData icono,
    required String titulo,
    required Color color,
  }) {
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          MainNavigationScreen.of(contexto)?.cambiarPestana(indicePestana);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withValues(alpha: 0.3), width: 1.2),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icono, color: color, size: 22),
              const SizedBox(height: 4),
              Text(
                titulo,
                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textoOscuro),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _construirResultadosBusqueda(
    BuildContext contexto,
    AgendaProvider proveedor,
    List agendas,
    List<TaskModel> tareas,
  ) {
    if (agendas.isEmpty && tareas.isEmpty) {
      return const Center(
        child: Text('No se encontraron coincidencias.', style: TextStyle(color: AppColors.textoSecundario, fontSize: 13)),
      );
    }

    return ListView(
      physics: const BouncingScrollPhysics(),
      children: [
        if (agendas.isNotEmpty) ...[
          const Text('Agendas:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textoSecundario)),
          ...agendas.map((agenda) {
            return ListTile(
              dense: true,
              leading: CircleAvatar(radius: 6, backgroundColor: Color(agenda.colorHexadecimal)),
              title: Text(agenda.nombre, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textoOscuro)),
              onTap: () {
                MainNavigationScreen.of(contexto)?.cambiarPestana(1);
              },
            );
          }),
        ],
        if (tareas.isNotEmpty) ...[
          const SizedBox(height: 8),
          const Text('Tareas:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textoSecundario)),
          ...tareas.map((tarea) => _construirTarjetaTarea(contexto, proveedor, tarea)),
        ],
      ],
    );
  }

  Widget _construirListaTareas(
    BuildContext contexto,
    AgendaProvider proveedor,
    List<TaskModel> tareas, {
    required bool esVencidas,
  }) {
    if (tareas.isEmpty) {
      return Center(
        child: Text(
          esVencidas ? 'No tienes tareas vencidas' : 'No hay tareas próximas',
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textoSecundario),
        ),
      );
    }

    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      itemCount: tareas.length,
      itemBuilder: (context, indice) {
        return _construirTarjetaTarea(contexto, proveedor, tareas[indice]);
      },
    );
  }

  Widget _construirTarjetaTarea(BuildContext contexto, AgendaProvider proveedor, TaskModel tarea) {
    return TaskCard(
      tarea: tarea,
      onToggleCompletada: (_) async {
        await proveedor.conmutarEstadoCompletado(tarea);
      },
      onEliminar: () {
        final tareaEliminada = tarea;
        proveedor.eliminarTarea(tarea.id);
        ScaffoldMessenger.of(contexto).clearSnackBars();
        ScaffoldMessenger.of(contexto).showSnackBar(
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
  }
}