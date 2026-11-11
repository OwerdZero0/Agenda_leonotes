import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../config/theme/app_colors.dart';
import '../models/task_model.dart';
import '../providers/agenda_provider.dart';
import '../widgets/notebook_scaffold.dart';

class NewTaskScreen extends StatefulWidget {
  final VoidCallback? alGuardarExitoso;
  const NewTaskScreen({super.key, this.alGuardarExitoso});

  @override
  State<NewTaskScreen> createState() => _NewTaskScreenState();
}

class _NewTaskScreenState extends State<NewTaskScreen> {
  final _claveFormulario = GlobalKey<FormState>();

  final TextEditingController _controladorTitulo = TextEditingController();
  final TextEditingController _controladorDescripcion = TextEditingController();

  String? _idAgendaSeleccionada;
  DateTime _fechaEntrega = DateTime.now();
  TimeOfDay _horaEntrega = const TimeOfDay(hour: 18, minute: 0);

  int _minutosAvisoAnticipado = 15;
  int _minutosEstimadosRealizacion = 30;
  int _nivelPrioridadSeleccionado = 3;

  @override
  void dispose() {
    _controladorTitulo.dispose();
    _controladorDescripcion.dispose();
    super.dispose();
  }

  Future<void> _solicitarMinutosPersonalizados({
    required String titulo,
    required int valorActual,
    required Function(int) alConfirmar,
  }) async {
    final TextEditingController controladorDialogo =
        TextEditingController(text: valorActual.toString());

    await showDialog(
      context: context,
      builder: (contextoDialogo) {
        return AlertDialog(
          backgroundColor: AppColors.hojaLibreta,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(titulo, style: const TextStyle(color: AppColors.textoOscuro, fontSize: 16, fontWeight: FontWeight.bold)),
          content: TextField(
            controller: controladorDialogo,
            keyboardType: TextInputType.number,
            autofocus: true,
            decoration: const InputDecoration(
              labelText: 'Minutos',
              hintText: 'Ej. 40, 75, 150...',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(contextoDialogo),
              child: const Text('Cancelar', style: TextStyle(color: AppColors.textoSecundario)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.botonOscuro,
              ),
              onPressed: () {
                final int? ingresado = int.tryParse(controladorDialogo.text.trim());
                if (ingresado != null && ingresado > 0) {
                  alConfirmar(ingresado);
                  Navigator.pop(contextoDialogo);
                }
              },
              child: const Text('Aceptar', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  void _guardarTarea() async {
    if (!_claveFormulario.currentState!.validate()) return;

    if (_idAgendaSeleccionada == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, selecciona o crea una agenda primero.'),
          backgroundColor: AppColors.prioridadMuyAlta,
        ),
      );
      return;
    }

    final DateTime fechaHoraFinal = DateTime(
      _fechaEntrega.year,
      _fechaEntrega.month,
      _fechaEntrega.day,
      _horaEntrega.hour,
      _horaEntrega.minute,
    );

    final nuevaTarea = TaskModel(
      id: const Uuid().v4(),
      titulo: _controladorTitulo.text.trim(),
      descripcion: _controladorDescripcion.text.trim(),
      idAgenda: _idAgendaSeleccionada!,
      fechaHoraEntrega: fechaHoraFinal,
      minutosAvisoAnticipado: _minutosAvisoAnticipado,
      nivelPrioridad: _nivelPrioridadSeleccionado,
      minutosEstimadosRealizacion: _minutosEstimadosRealizacion,
      estaCompletada: false,
    );

    final proveedor = Provider.of<AgendaProvider>(context, listen: false);
    await proveedor.agregarTarea(nuevaTarea);

    if (mounted) {
      Navigator.pop(context);
      widget.alGuardarExitoso?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    final proveedor = Provider.of<AgendaProvider>(context);
    final listaAgendas = proveedor.listaAgendas;

    return NotebookScaffold(
      contenido: Form(
        key: _claveFormulario,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textoOscuro),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Text(
                    'Nueva Tarea',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textoOscuro),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
              const Divider(color: AppColors.lineaMargenHoja, thickness: 1.5),
              const SizedBox(height: 12),

              TextFormField(
                controller: _controladorTitulo,
                style: const TextStyle(color: AppColors.textoOscuro, fontWeight: FontWeight.w600),
                decoration: InputDecoration(
                  labelText: 'Título de la tarea',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                validator: (valor) => valor == null || valor.trim().isEmpty ? 'Ingresa un título' : null,
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _controladorDescripcion,
                maxLines: 2,
                style: const TextStyle(color: AppColors.textoOscuro),
                decoration: InputDecoration(
                  labelText: 'Descripción de la tarea',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 14),

              const Text('Agenda asignada', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textoOscuro)),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.black12),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _idAgendaSeleccionada,
                    hint: const Text('Selecciona una agenda'),
                    isExpanded: true,
                    items: listaAgendas.map((agenda) {
                      return DropdownMenuItem<String>(
                        value: agenda.id,
                        child: Row(
                          children: [
                            CircleAvatar(radius: 6, backgroundColor: Color(agenda.colorHexadecimal)),
                            const SizedBox(width: 8),
                            Text(agenda.nombre),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (val) => setState(() => _idAgendaSeleccionada = val),
                  ),
                ),
              ),
              const SizedBox(height: 14),

              const Text('Fecha y Hora límite de Entrega', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textoOscuro)),
              const SizedBox(height: 6),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.event_available_rounded, size: 18, color: AppColors.prioridadMuyAlta),
                      label: Text(DateFormat('dd/MM/yyyy').format(_fechaEntrega), style: const TextStyle(color: AppColors.textoOscuro)),
                      onPressed: () async {
                        final f = await showDatePicker(context: context, initialDate: _fechaEntrega, firstDate: DateTime.now(), lastDate: DateTime.now().add(const Duration(days: 730)));
                        if (f != null) setState(() => _fechaEntrega = f);
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.alarm_on_rounded, size: 18, color: AppColors.prioridadMuyAlta),
                      label: Text(_horaEntrega.format(context), style: const TextStyle(color: AppColors.textoOscuro)),
                      onPressed: () async {
                        final h = await showTimePicker(context: context, initialTime: _horaEntrega);
                        if (h != null) setState(() => _horaEntrega = h);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Alarma con opción personalizada
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Alarma sonora de aviso anticipado', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textoOscuro)),
                  Text('${_minutosAvisoAnticipado} min', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.botonOscuro)),
                ],
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.black12)),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<int>(
                    value: [5, 15, 30, 60, 1440].contains(_minutosAvisoAnticipado) ? _minutosAvisoAnticipado : -1,
                    isExpanded: true,
                    items: [
                      const DropdownMenuItem(value: 5, child: Text('5 minutos antes')),
                      const DropdownMenuItem(value: 15, child: Text('15 minutos antes')),
                      const DropdownMenuItem(value: 30, child: Text('30 minutos antes')),
                      const DropdownMenuItem(value: 60, child: Text('1 hora antes')),
                      const DropdownMenuItem(value: 1440, child: Text('1 día antes')),
                      DropdownMenuItem(
                        value: -1,
                        child: Text(
                          [5, 15, 30, 60, 1440].contains(_minutosAvisoAnticipado)
                              ? 'Personalizado...'
                              : 'Personalizado: $_minutosAvisoAnticipado minutos',
                          style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.botonOscuro),
                        ),
                      ),
                    ],
                    onChanged: (val) {
                      if (val == -1) {
                        _solicitarMinutosPersonalizados(
                          titulo: 'Minutos antes para la alarma',
                          valorActual: _minutosAvisoAnticipado,
                          alConfirmar: (nuevosMinutos) => setState(() => _minutosAvisoAnticipado = nuevosMinutos),
                        );
                      } else if (val != null) {
                        setState(() => _minutosAvisoAnticipado = val);
                      }
                    },
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // Tiempo estimado de realización promedio con opción personalizada
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Tiempo estimado de realización', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textoOscuro)),
                  Text('${_minutosEstimadosRealizacion} min', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.botonOscuro)),
                ],
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.black12)),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<int>(
                    value: [15, 30, 45, 60, 90, 120].contains(_minutosEstimadosRealizacion) ? _minutosEstimadosRealizacion : -1,
                    isExpanded: true,
                    items: [
                      const DropdownMenuItem(value: 15, child: Text('15 minutos')),
                      const DropdownMenuItem(value: 30, child: Text('30 minutos')),
                      const DropdownMenuItem(value: 45, child: Text('45 minutos')),
                      const DropdownMenuItem(value: 60, child: Text('1 hora (60 min)')),
                      const DropdownMenuItem(value: 90, child: Text('1 hora y media (90 min)')),
                      const DropdownMenuItem(value: 120, child: Text('2 horas (120 min)')),
                      DropdownMenuItem(
                        value: -1,
                        child: Text(
                          [15, 30, 45, 60, 90, 120].contains(_minutosEstimadosRealizacion)
                              ? 'Personalizado...'
                              : 'Personalizado: $_minutosEstimadosRealizacion minutos',
                          style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.botonOscuro),
                        ),
                      ),
                    ],
                    onChanged: (val) {
                      if (val == -1) {
                        _solicitarMinutosPersonalizados(
                          titulo: 'Minutos estimados de realización',
                          valorActual: _minutosEstimadosRealizacion,
                          alConfirmar: (nuevosMinutos) => setState(() => _minutosEstimadosRealizacion = nuevosMinutos),
                        );
                      } else if (val != null) {
                        setState(() => _minutosEstimadosRealizacion = val);
                      }
                    },
                  ),
                ),
              ),
              const SizedBox(height: 14),

              const Text('Dificultad de la tarea', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textoOscuro)),
              const SizedBox(height: 8),
              ...NivelPrioridad.values.map((p) => _construirRadioDificultad(p)),
              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.botonOscuro,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: _guardarTarea,
                  child: const Text('Guardar Tarea', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _construirRadioDificultad(NivelPrioridad prioridad) {
    return RadioListTile<int>(
      dense: true,
      value: prioridad.valor,
      groupValue: _nivelPrioridadSeleccionado,
      activeColor: prioridad.color,
      title: Row(
        children: [
          CircleAvatar(radius: 6, backgroundColor: prioridad.color),
          const SizedBox(width: 8),
          Text('Dificultad ${prioridad.etiqueta}', style: const TextStyle(color: AppColors.textoOscuro, fontWeight: FontWeight.w600)),
        ],
      ),
      onChanged: (v) => setState(() => _nivelPrioridadSeleccionado = v ?? NivelPrioridad.media.valor),
    );
  }
}
