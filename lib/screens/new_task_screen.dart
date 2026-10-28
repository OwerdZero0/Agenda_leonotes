import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../config/theme/app_colors.dart';
import '../models/agenda_model.dart';
import '../models/task_model.dart';
import '../providers/agenda_provider.dart';
import '../widgets/notebook_scaffold.dart';

class NewTaskScreen extends StatefulWidget {
  const NewTaskScreen({super.key});

  @override
  State<NewTaskScreen> createState() => _NewTaskScreenState();
}

class _NewTaskScreenState extends State<NewTaskScreen> {
  final _claveFormulario = GlobalKey<FormState>();

  final TextEditingController _controladorTitulo = TextEditingController();
  final TextEditingController _controladorDescripcion = TextEditingController();

  String? _idAgendaSeleccionada;
  DateTime _fechaSeleccionada = DateTime.now();
  TimeOfDay _horaSeleccionada = const TimeOfDay(hour: 12, minute: 0);

  int _minutosAvisoAnticipado = 10;
  int _minutosEstimadosRealizacion = 30;
  int _nivelPrioridadSeleccionado = 3; // Media por defecto

  @override
  void dispose() {
    _controladorTitulo.dispose();
    _controladorDescripcion.dispose();
    super.dispose();
  }

  Future<void> _seleccionarFecha(BuildContext contexto) async {
    final DateTime? fechaElegida = await showDatePicker(
      context: contexto,
      initialDate: _fechaSeleccionada,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 3)),
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

    if (fechaElegida != null) {
      setState(() {
        _fechaSeleccionada = fechaElegida;
      });
    }
  }

  Future<void> _seleccionarHora(BuildContext contexto) async {
    final TimeOfDay? horaElegida = await showTimePicker(
      context: contexto,
      initialTime: _horaSeleccionada,
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
        _horaSeleccionada = horaElegida;
      });
    }
  }

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
                'Crear nueva agenda',
                style: TextStyle(color: AppColors.textoOscuro, fontWeight: FontWeight.bold),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: controladorNombre,
                    decoration: const InputDecoration(
                      labelText: 'Nombre de la agenda',
                      hintText: 'Ej. Escuela, Personal...',
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      0xFF1976D2, // Azul
                      0xFF388E3C, // Verde
                      0xFFD32F2F, // Rojo
                      0xFFF57C00, // Naranja
                      0xFF7B1FA2, // Morado
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
                  child: const Text('Cancelar', style: TextStyle(color: AppColors.textoSecundario)),
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
                      setState(() {
                        _idAgendaSeleccionada = nuevaAgenda.id;
                      });
                      if (contextoDialogo.mounted) {
                        Navigator.pop(contextoDialogo);
                      }
                    }
                  },
                  child: const Text('Guardar', style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
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
      _fechaSeleccionada.year,
      _fechaSeleccionada.month,
      _fechaSeleccionada.day,
      _horaSeleccionada.hour,
      _horaSeleccionada.minute,
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tarea creada con éxito'),
          backgroundColor: AppColors.tareaCompletada,
        ),
      );
      Navigator.pop(context);
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
              // Encabezado
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textoOscuro),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Text(
                    'Nueva Tarea',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textoOscuro,
                    ),
                  ),
                  const SizedBox(width: 48), // Balance visual con el botón atrás
                ],
              ),
              const Divider(color: AppColors.lineaMargenHoja, thickness: 1.5),
              const SizedBox(height: 12),

              // 1. Título
              TextFormField(
                controller: _controladorTitulo,
                style: const TextStyle(color: AppColors.textoOscuro, fontWeight: FontWeight.w600),
                decoration: InputDecoration(
                  labelText: 'Título de la tarea',
                  labelStyle: const TextStyle(color: AppColors.textoSecundario),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.lineaMargenHoja),
                  ),
                ),
                validator: (valor) {
                  if (valor == null || valor.trim().isEmpty) {
                    return 'Ingresa un título para la tarea';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),

              // 2. Descripción
              TextFormField(
                controller: _controladorDescripcion,
                maxLines: 3,
                style: const TextStyle(color: AppColors.textoOscuro),
                decoration: InputDecoration(
                  labelText: 'Descripción de la tarea',
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

              // 3. Selector de Agenda
              const Text(
                'Agenda asignada',
                style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textoOscuro),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Expanded(
                    child: Container(
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
                                  CircleAvatar(
                                    radius: 6,
                                    backgroundColor: Color(agenda.colorHexadecimal),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(agenda.nombre),
                                ],
                              ),
                            );
                          }).toList(),
                          onChanged: (nuevoValor) {
                            setState(() {
                              _idAgendaSeleccionada = nuevoValor;
                            });
                          },
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    style: IconButton.styleFrom(
                      backgroundColor: AppColors.botonOscuro,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    icon: const Icon(Icons.add, color: Colors.white),
                    tooltip: 'Crear nueva agenda',
                    onPressed: () => _mostrarDialogoNuevaAgenda(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // 4. Fecha y Hora de Entrega
              const Text(
                'Fecha y hora de entrega',
                style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textoOscuro),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      icon: const Icon(Icons.calendar_today_rounded, size: 18, color: AppColors.botonOscuro),
                      label: Text(
                        DateFormat('dd/MM/yyyy').format(_fechaSeleccionada),
                        style: const TextStyle(color: AppColors.textoOscuro),
                      ),
                      onPressed: () => _seleccionarFecha(context),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      icon: const Icon(Icons.access_time_rounded, size: 18, color: AppColors.botonOscuro),
                      label: Text(
                        _horaSeleccionada.format(context),
                        style: const TextStyle(color: AppColors.textoOscuro),
                      ),
                      onPressed: () => _seleccionarHora(context),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // 5. Alarma / Aviso para entrega sonora
              const Text(
                'Alarma para aviso de entrega',
                style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textoOscuro),
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.black12),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<int>(
                    value: _minutosAvisoAnticipado,
                    isExpanded: true,
                    items: const [
                      DropdownMenuItem(value: 5, child: Text('5 minutos antes')),
                      DropdownMenuItem(value: 10, child: Text('10 minutos antes')),
                      DropdownMenuItem(value: 30, child: Text('30 minutos antes')),
                      DropdownMenuItem(value: 60, child: Text('1 hora antes')),
                      DropdownMenuItem(value: 120, child: Text('2 horas antes')),
                      DropdownMenuItem(value: 1440, child: Text('1 día antes')),
                    ],
                    onChanged: (nuevoValor) {
                      if (nuevoValor != null) {
                        setState(() {
                          _minutosAvisoAnticipado = nuevoValor;
                        });
                      }
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // 6. Tiempo estimado de realización
              const Text(
                'Tiempo estimado de realización',
                style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textoOscuro),
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.black12),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<int>(
                    value: _minutosEstimadosRealizacion,
                    isExpanded: true,
                    items: const [
                      DropdownMenuItem(value: 15, child: Text('15 minutos')),
                      DropdownMenuItem(value: 30, child: Text('30 minutos')),
                      DropdownMenuItem(value: 45, child: Text('45 minutos')),
                      DropdownMenuItem(value: 60, child: Text('1 hora')),
                      DropdownMenuItem(value: 90, child: Text('1 hora y media')),
                      DropdownMenuItem(value: 120, child: Text('2 horas')),
                      DropdownMenuItem(value: 180, child: Text('3 horas')),
                    ],
                    onChanged: (nuevoValor) {
                      if (nuevoValor != null) {
                        setState(() {
                          _minutosEstimadosRealizacion = nuevoValor;
                        });
                      }
                    },
                  ),
                ),
              ),
              const SizedBox(height: 18),

              // 7. Dificultad / Prioridad (Radio buttons)
              const Text(
                'Dificultad de la tarea',
                style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textoOscuro),
              ),
              const SizedBox(height: 8),
              _construirOpcionPrioridad(1, 'Muy baja', AppColors.prioridadMuyBaja),
              _construirOpcionPrioridad(2, 'Baja', AppColors.prioridadBaja),
              _construirOpcionPrioridad(3, 'Media', AppColors.prioridadMedia),
              _construirOpcionPrioridad(4, 'Alta', AppColors.prioridadAlta),
              _construirOpcionPrioridad(5, 'Muy alta', AppColors.prioridadMuyAlta),
              const SizedBox(height: 24),

              // Botón Guardar Tarea
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.botonOscuro,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: _guardarTarea,
                  child: const Text(
                    'Guardar Tarea',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _construirOpcionPrioridad(int nivel, String etiqueta, Color colorPrioridad) {
    final bool esSeleccionado = _nivelPrioridadSeleccionado == nivel;
    return InkWell(
      onTap: () {
        setState(() {
          _nivelPrioridadSeleccionado = nivel;
        });
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Radio<int>(
              value: nivel,
              groupValue: _nivelPrioridadSeleccionado,
              activeColor: colorPrioridad,
              onChanged: (valor) {
                if (valor != null) {
                  setState(() {
                    _nivelPrioridadSeleccionado = valor;
                  });
                }
              },
            ),
            Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                color: colorPrioridad,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'Dificultad $etiqueta',
              style: TextStyle(
                color: AppColors.textoOscuro,
                fontWeight: esSeleccionado ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}