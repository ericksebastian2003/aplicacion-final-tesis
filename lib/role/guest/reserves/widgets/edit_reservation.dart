
import 'package:flutter/material.dart';
import 'package:desole_app/data/models/Reservas.dart';
import 'package:desole_app/services/reserves_services.dart';
import 'package:intl/intl.dart';

class EditReservationScreen extends StatefulWidget {
  final Reservas reservas;

  const EditReservationScreen({super.key, required this.reservas});

  @override
  State<EditReservationScreen> createState() => _EditReservationScreenState();
}

class _EditReservationScreenState extends State<EditReservationScreen> {
  final _service = ReservesServices();
  final _formKey = GlobalKey<FormState>();
  late TextEditingController numerohuespedesController;

  // Variables de estado para las fechas
  late DateTime _selectedCheckInDate;
  late DateTime _selectedCheckOutDate;

  // Variables de estado para la carga y el mensaje
  bool _isLoading = false;
  String? _mensaje;
  bool _isError = false;

  @override
  void initState() {
    super.initState();
    numerohuespedesController =
        TextEditingController(text: widget.reservas.numeroHuespedes.toString());
    _selectedCheckInDate = widget.reservas.fechaCheckIn;
    _selectedCheckOutDate = widget.reservas.fechaCheckOut;
  }

  @override
  void dispose() {
    numerohuespedesController.dispose();
    super.dispose();
  }

  // Método para manejar la selección de fechas
  Future<void> _pickDate(BuildContext context, bool isCheckIn) async {
    final initialDate = isCheckIn ? _selectedCheckInDate : _selectedCheckOutDate;
    final firstDate = DateTime.now();
    final lastDate = DateTime(2100);

    final newDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.black, // Color principal del picker
              onPrimary: Colors.white, // Color del texto en el encabezado
              surface: Colors.white, // Color de la superficie del calendario
              onSurface: Colors.black, // Color del texto del calendario
            ),
            dialogBackgroundColor: Colors.white,
          ),
          child: child!,
        );
      },
    );

    if (newDate != null) {
      setState(() {
        if (isCheckIn) {
          _selectedCheckInDate = newDate;
          // Si la fecha de salida es anterior a la de entrada, se actualiza automáticamente
          if (_selectedCheckOutDate.isBefore(_selectedCheckInDate)) {
            _selectedCheckOutDate = _selectedCheckInDate.add(const Duration(days: 1));
          }
        } else {
          // No permitir que la fecha de salida sea anterior a la de entrada
          if (newDate.isAfter(_selectedCheckInDate)) {
            _selectedCheckOutDate = newDate;
          } else {
            // No hacemos nada, pero podríamos mostrar un mensaje de error
            _mensaje = 'La fecha de salida debe ser posterior a la de entrada.';
            _isError = true;
          }
        }
      });
    }
  }

  void _saveChanges() async {
    if (!_formKey.currentState!.validate()) {
      _mensaje = 'Por favor, corrige los errores en el formulario.';
      _isError = true;
      return;
    }

    // Validación adicional de fechas
    if (_selectedCheckOutDate.isBefore(_selectedCheckInDate) || _selectedCheckOutDate.isAtSameMomentAs(_selectedCheckInDate)) {
      setState(() {
        _mensaje = 'La fecha de salida debe ser posterior a la de entrada.';
        _isError = true;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _mensaje = null;
    });

    final updateData = {
      "fechaCheckIn": DateFormat('yyyy-MM-dd').format(_selectedCheckInDate),
      "fechaCheckOut": DateFormat('yyyy-MM-dd').format(_selectedCheckOutDate),
      "numeroHuespedes": int.parse(numerohuespedesController.text),
    };

    try {
      final message = await _service.updateReservationsForGuest(
        widget.reservas.id,
        updateData,
      );

      if (mounted) {
        setState(() {
          _isLoading = false;
          _mensaje = message;
          // Asumimos que un mensaje de error es cualquier cosa que no sea un mensaje de éxito esperado
          _isError = message != 'Reserva actualizada correctamente.';
        });

        if (!_isError) {
          // Navegar de regreso después de un breve retraso
          Future.delayed(const Duration(seconds: 2), () => Navigator.pop(context, true));
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _mensaje = 'Error al actualizar: $e';
          _isError = true;
        });
      }
    }
  }

  // Método para construir el mensaje flotante
  Widget _buildMensaje() {
    if (_mensaje == null) return const SizedBox.shrink();

    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        child: AnimatedOpacity(
          opacity: _mensaje != null ? 1 : 0,
          duration: const Duration(milliseconds: 300),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 8,
                  offset: Offset(0, 3),
                )
              ],
            ),
            constraints: const BoxConstraints(minWidth: 200),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _isError ? Icons.error_outline : Icons.check_circle_outline,
                  color: _isError ? Colors.red.shade700 : Colors.black87,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _mensaje!,
                    style: const TextStyle(
                      color: Colors.black87,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Editar reserva',
          style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Fechas de la Reserva',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  // Selector de fecha de Check-In
                  _buildDateSelector(
                    context,
                    'Fecha de ingreso',
                    _selectedCheckInDate,
                    () => _pickDate(context, true),
                  ),
                  const SizedBox(height: 16),
                  // Selector de fecha de Check-Out
                  _buildDateSelector(
                    context,
                    'Fecha de salida',
                    _selectedCheckOutDate,
                    () => _pickDate(context, false),
                  ),
                  const SizedBox(height: 30),
                  // Campo de número de huéspedes
                  const Text(
                    'Detalles de la Reserva',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    numerohuespedesController,
                    'Número de huéspedes',
                    'Ingresa el número de personas',
                    isNumeric: true,
                  ),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 3,
                      ),
                      onPressed: _isLoading ? null : _saveChanges,
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              'Actualizar Reserva',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                                letterSpacing: 0.5,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          _buildMensaje(),
        ],
      ),
    );
  }

  // Nuevo widget para el selector de fecha con mejor UI
  Widget _buildDateSelector(
    BuildContext context,
    String label,
    DateTime date,
    VoidCallback onPressed,
  ) {
    return InkWell(
      onTap: onPressed,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          prefixIcon: const Icon(Icons.calendar_today, color: Colors.black),
        ),
        child: Text(
          DateFormat('EEE, d MMM y').format(date),
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    String hint, {
    bool isNumeric = false,
    int? maxHuespedes,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: TextFormField(
        controller: controller,
        keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
        style: const TextStyle(fontSize: 16),
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          labelStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          hintStyle: const TextStyle(color: Colors.grey),
          contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.black, width: 1.5),
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Este campo es obligatorio';
          }
          if (isNumeric) {
            final numero = int.tryParse(value);
            if (numero == null) return 'Ingresa un número válido';
            if (numero < 1) return 'Debe haber al menos un huésped';
            if (maxHuespedes != null && numero > maxHuespedes) {
              return 'Máximo permitido: $maxHuespedes huéspedes';
            }
          }
          return null;
        },
      ),
    );
  }
}