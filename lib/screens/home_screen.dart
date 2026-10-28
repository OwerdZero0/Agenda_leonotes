import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../config/theme/app_colors.dart';
import '../models/task_model.dart';
import '../providers/agenda_provider.dart';
import '../widgets/notebook_scaffold.dart';
import 'agendas_screen.dart';
import 'calendar_screen.dart';
import 'daily_schedule_screen.dart';
import 'new_task_screen.dart';
import 'timeline_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _controladorBusqueda = TextEditingController();
  bool _mostrarVencidas = false; // Alterna entre tareas próximas y vencidas

  @override
  void dispose() {
    _controladorBusqueda.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final proveedor = Provider.of<AgendaProvider>(context);
    final bool hayBusquedaActiva = proveedor.terminoBusqueda.isNotEmpty;

    final listaAgendasCoincidentes = proveedor.agendasFiltradas;
    final listaTareasCoincidentes = proveedor.tareasFiltradasPorTitulo;

    final tareasVencidas = proveedor.tareasVencidas;
    final tareasProximas = proveedor.tareasProximas;

    return NotebookScaffold(
      contenido: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Saludo y encabezado
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    '¡Hola!',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textoOscuro,
                    ),
                  ),
                  Text(
                    'Organiza tu día con tu agenda',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textoSecundario,
                    ),
                  ),
                ],
              ),
              CircleAvatar(
                radius: 20,
                backgroundColor: AppColors.lineaMargenHoja,
                child: const Icon(
                  Icons.person_rounded,
                  color: AppColors.botonOscuro,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Buscador en tiempo real de agendas y tareas
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
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

          // Si hay texto en el buscador, mostramos los resultados dinámicos
          if (hayBusquedaActiva) ...[
            const Text(
              'Resultados de búsqueda',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.textoOscuro,
              ),
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
            // Accesos directos a secciones
            SizedBox(
              height: 76,
              child: Row(
                children: [
                  _construirBotonAccesoRapido(
                    context,
                    icono: Icons.menu_book_rounded,
                    titulo: 'Mis Agendas',
                    color: const Color(0xFF1976D2),
                    destino: const AgendasScreen(),
                  ),
                  const SizedBox(width: 8),
                  _construirBotonAccesoRapido(
                    context,
                    icono: Icons.calendar_month_rounded,
                    titulo: 'Calendario',
                    color: const Color(0xFF388E3C),
                    destino: const CalendarScreen(),
                  ),
                  const SizedBox(width: 8),
                  _construirBotonAccesoRapido(
                    context,
                    icono: Icons.timeline_rounded,
                    titulo: 'Hoy',
                    color: const Color(0xFFF57C00),
                    destino: const TimelineScreen(),
                  ),
                  const SizedBox(width: 8),
                  _construirBotonAccesoRapido(
                    context,
                    icono: Icons.bolt_rounded,
                    titulo: 'Inteligente',
                    color: const Color(0xFF7B1FA2),
                    destino: const DailyScheduleScreen(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Pestañas: Tareas Próximas vs Tareas Vencidas
            Container(
              height: 38,
              decoration: BoxDecoration(
                color: AppColors.lineaMargenHoja.withOpacity(0.5),
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

            // Lista de tareas según la pestaña seleccionada
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
  }

  Widget _construirBotonAccesoRapido(
    BuildContext contexto, {
    required IconData icono,
    required String titulo,
    required Color color,
    required Widget destino,
  }) {
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Navigator.push(
            contexto,
            MaterialPageRoute(builder: (_) => destino),
          );
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withOpacity(0.3), width: 1.2),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icono, color: color, size: 22),
              const SizedBox(height: 4),
              Text(
                titulo,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textoOscuro,
                ),
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
        child: Text(
          'No se encontraron coincidencias.',
          style: TextStyle(color: AppColors.textoSecundario, fontSize: 13),
        ),
      );
    }

    return ListView(
      physics: const BouncingScrollPhysics(),
      children: [
        if (agendas.isNotEmpty) ...[
          const Text(
            'Agendas:',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: AppColors.textoSecundario,
            ),
          ),
          const SizedBox(height: 4),
          ...agendas.map((agenda) {
            return ListTile(
              dense: true,
              leading: CircleAvatar(
                radius: 6,
                backgroundColor: Color(agenda.colorHexadecimal),
              ),
              title: Text(
                agenda.nombre,
                style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textoOscuro),
              ),
              onTap: () {
                Navigator.push(
                  contexto,
                  MaterialPageRoute(builder: (_) => const AgendasScreen()),
                );
              },
            );
          }),
          const SizedBox(height: 8),
        ],
        if (tareas.isNotEmpty) ...[
          const Text(
            'Tareas:',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: AppColors.textoSecundario,
            ),
          ),
          const SizedBox(height: 4),
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              esVencidas ? Icons.check_circle_outline_rounded : Icons.event_available_rounded,
              size: 44,
              color: AppColors.textoSecundario.withOpacity(0.3),
            ),
            const SizedBox(height: 8),
            Text(
              esVencidas ? 'No tienes tareas vencidas' : 'No hay tareas próximas',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: AppColors.textoSecundario,
              ),
            ),
            if (!esVencidas) ...[
              const SizedBox(height: 8),
              OutlinedButton.icon(
                icon: const Icon(Icons.add, size: 14, color: AppColors.botonOscuro),
                label: const Text(
                  'Crear tarea',
                  style: TextStyle(color: AppColors.botonOscuro, fontSize: 11),
                ),
                onPressed: () {
                  Navigator.push(
                    contexto,
                    MaterialPageRoute(builder: (_) => const NewTaskScreen()),
                  );
                },
              ),
            ],
          ],
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

  Widget _construirTarjetaTarea(
    BuildContext contexto,
    AgendaProvider proveedor,
    TaskModel tarea,
  ) {
    final colorDificultad = AppColors.obtenerColorPrioridad(tarea.nivelPrioridad);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: tarea.estaCompletada
              ? AppColors.tareaCompletada
              : colorDificultad.withOpacity(0.5),
          width: 1.2,
        ),
      ),
      child: ListTile(
        dense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
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
            color: AppColors.textoOscuro,
            decoration: tarea.estaCompletada ? TextDecoration.lineThrough : null,
          ),
        ),
        subtitle: Row(
          children: [
            Icon(Icons.access_time_rounded, size: 12, color: colorDificultad),
            const SizedBox(width: 4),
            Text(
              DateFormat('dd/MM - HH:mm').format(tarea.fechaHoraEntrega),
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: colorDificultad,
              ),
            ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline_rounded, size: 18),
          color: AppColors.textoSecundario,
          onPressed: () => proveedor.eliminarTarea(tarea.id),
        ),
      ),
    );
  }
}