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
    print('Id: ${widget.reservas.id}');
    if (!_formKey.currentState!.validate()) return;

    final updated = Reservas(
      id: widget.reservas.id,
      tituloAlojamiento: widget.reservas.tituloAlojamiento,
      huespedId: widget.reservas.huespedId,
      fechaCheckIn: widget.reservas.fechaCheckIn,
      fechaCheckOut: widget.reservas.fechaCheckOut,
      numeroHuespedes: int.parse(numerohuespedesController.text),
      precioTotal: widget.reservas.precioTotal,
      estadoReserva: widget.reservas.estadoReserva,
      estadoPago: widget.reservas.estadoPago,
      nombreHuesped: widget.reservas.nombreHuesped,
      emailHuesped: widget.reservas.emailHuesped,
    );

    print('🚀 Enviando reserva a editar: ${updated.toJsonForUpdateGuest()}');

    try {
      final success = await _service.updateReservationsForGuest(widget.reservas.id, updated);
      print(success);
      if (!success) throw Exception('Error actualizando la reserva');

      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al actualizar: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Editar reserva')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildTextField(
                numerohuespedesController,
                'Número de huéspedes',
                'Ingresa el número de personas',
                isNumeric: true,
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    backgroundColor: Colors.black,
                  ),
                  onPressed: _saveChanges,
                  child: const Text(
                    'Actualizar reserva',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
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
      padding: const EdgeInsets.only(bottom: 14.0),
      child: TextFormField(
        controller: controller,
        keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          border: const OutlineInputBorder(),
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
