import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:desole_app/role/guest/dashboard/guest_dashboard.dart';
import 'package:desole_app/role/guest/pays/pay_accomodation.dart';

class ReserveDestination extends StatefulWidget {
  final String duenio;
  final String alojamientoId;
  final int precioPorNoche;
  final int maxHuespedes;

  const ReserveDestination({
    super.key,
    required this.duenio,
    required this.alojamientoId,
    required this.maxHuespedes,
    required this.precioPorNoche,
  });

  @override
  State<ReserveDestination> createState() => _ReserveDestinationState();
}

class _ReserveDestinationState extends State<ReserveDestination> {
  final _formKey = GlobalKey<FormState>();
  final _fechaCheckInController = TextEditingController();
  final _fechaCheckOutController = TextEditingController();
  bool _enviando = false;
  int _cantidadHuespedes = 1;
  int _cantidadNoches = 1;

  @override
  void dispose() {
    _fechaCheckInController.dispose();
    _fechaCheckOutController.dispose();
    super.dispose();
  }

  Future<void> _crearReservation() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      setState(() => _enviando = true);

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';
      final huespedId = prefs.getString('userId') ?? '';

      final checkIn = DateTime.parse(_fechaCheckInController.text);
      final checkOut = DateTime.parse(_fechaCheckOutController.text);
      final noches = _cantidadNoches;

      final numHuespedes = _cantidadHuespedes;
      if (numHuespedes > widget.maxHuespedes) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Solo se permiten hasta ${widget.maxHuespedes} huéspedes')),
        );
        return;
      }

      final precioTotal = widget.precioPorNoche * noches;

      final datos = {
        "huesped": huespedId,
        "alojamiento": widget.alojamientoId,
        "fechaCheckIn": _fechaCheckInController.text,
        "fechaCheckOut": _fechaCheckOutController.text,
        "numeroHuespedes": numHuespedes,
        "precioTotal": precioTotal,
      };

      final dio = Dio();
      dio.options.headers['Authorization'] = 'Bearer $token';

      final response = await dio.post(
        'https://hospedajes-4rmu.onrender.com/api/reservas/crear',
        data: datos,
      );

      if (response.statusCode == 201) {
  final reservaData = response.data;
  final idReserva = reservaData['_id']; 

  // Guardar el ID de la reserva para uso posterior
  await prefs.setString('reservaId', idReserva);
  print(idReserva);
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('Reserva creada con éxito. ID: $idReserva')),
  );

  final rol = prefs.getString('rol');
  final nombre = prefs.getString('nombre') ?? '';

  Navigator.of(context).pushAndRemoveUntil(
    MaterialPageRoute(
      builder: (context) => GuestDashboard(rol: rol!, nombre: nombre),
    ),
    (route) => false,
  );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al crear la reserva')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() => _enviando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final precioTotal = widget.precioPorNoche * _cantidadNoches;

    return Scaffold(
      appBar: AppBar(title: const Text('Reservar alojamiento')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildTextField(_fechaCheckInController, 'Fecha Check-in', 'YYYY-MM-DD'),
              _buildTextField(_fechaCheckOutController, 'Fecha Check-out', 'YYYY-MM-DD'),
              const SizedBox(height: 12),
              Text('Número de huéspedes'),
              Row(
                children: [
                  IconButton(
                    onPressed: _cantidadHuespedes > 1
                        ? () => setState(() => _cantidadHuespedes--)
                        : null,
                    icon: const Icon(Icons.remove_circle_outline),
                  ),
                  Text('$_cantidadHuespedes', style: const TextStyle(fontSize: 16)),
                  IconButton(
                    onPressed: _cantidadHuespedes < widget.maxHuespedes
                        ? () => setState(() => _cantidadHuespedes++)
                        : null,
                    icon: const Icon(Icons.add_circle_outline),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Text('Cantidad de noches', style: TextStyle(fontWeight: FontWeight.bold)),
              Row(
                children: [
                  IconButton(
                    onPressed: _cantidadNoches > 1
                        ? () => setState(() => _cantidadNoches--)
                        : null,
                    icon: const Icon(Icons.remove_circle_outline),
                  ),
                  Text('$_cantidadNoches', style: const TextStyle(fontSize: 16)),
                  IconButton(
                    onPressed: () => setState(() => _cantidadNoches++),
                    icon: const Icon(Icons.add_circle_outline),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text('Precio total: \$${precioTotal}',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _enviando
    ? null
    : () async {
        if (!_formKey.currentState!.validate()) return;

        // Primero crea la reserva
        await _crearReservation();

        // Luego accede a SharedPreferences y obtén el idReserva
        final prefs = await SharedPreferences.getInstance();
        final idReserva = prefs.getString('reservaId');

        if (idReserva == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No se pudo obtener el ID de la reserva')),
          );
          return;
        }

        // Ahora redirige al proceso de pago con el ID de la reserva
        final resultadoPago = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => PayAccomodation(
              alojamiento: widget.alojamientoId,
              nombreDuenio: widget.duenio,
              noches: _cantidadNoches,
              precioPorNoche: widget.precioPorNoche,
              precioTotal: precioTotal,
              idReserva: idReserva,
            ),
          ),
        );

        if (resultadoPago != true) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Pago cancelado o fallido')),
          );
        }
      },

                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  backgroundColor: Colors.black,
                ),
                child: _enviando
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Siguiente', style: TextStyle(color: Colors.white, fontSize: 18)),
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
          return null;
        },
      ),
    );
  }
}
