import 'package:flutter/material.dart';
import 'package:desole_app/data/models/Reservas.dart';
import 'package:desole_app/services/reserves_services.dart';

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
  bool _isLoading = false;
  String? _mensaje;
  bool _isError = false;

  @override
  void initState() {
    super.initState();
    numerohuespedesController =
        TextEditingController(text: widget.reservas.numeroHuespedes.toString());
  }

  @override
  void dispose() {
    numerohuespedesController.dispose();
    super.dispose();
  }



  void _saveChanges() async {
    if (!_formKey.currentState!.validate()) {
      _mensaje = 'Por favor, corrige los errores en el formulario.';
      _isError = true;
      return;
    }

    setState(() {
      _isLoading = true;
      _mensaje = null;
    });

    final updateData = {
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