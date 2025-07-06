import 'package:desole_app/services/pays_services.dart';
import 'package:desole_app/services/users_services.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:desole_app/role/guest/dashboard/guest_dashboard.dart';
import '../profile/widgets/my_balance.dart';
class PayAccomodation extends StatefulWidget {
  final int noches;
  final int precioPorNoche;
  final int precioTotal;
  final String duenio;
  final String alojamientoId;
  final String huespedId;
  final DateTime fechaCheckIn;
  final DateTime fechaCheckOut;
  final int cantidadHuespedes;

  const PayAccomodation({
    super.key,
    required this.noches,
    required this.precioPorNoche,
    required this.precioTotal,
    required this.duenio,
    required this.alojamientoId,
    required this.huespedId,
    required this.fechaCheckIn,
    required this.fechaCheckOut,
    required this.cantidadHuespedes,
  });

  @override
  State<PayAccomodation> createState() => _PayAccomodationState();
}

class _PayAccomodationState extends State<PayAccomodation> {
  bool isLoading = false;
  final Dio dio = Dio();
  double _saldo = 0;

  Future<void> _confirmarPago() async {
    setState(() => isLoading = true);

    try {
      final userService = UsersServices();
      final profile = await userService.getUserProfile();
      final rawSaldo = profile?['saldo'];
      _saldo = rawSaldo is num ? rawSaldo.toDouble() : 0;

      // ✅ Verificar si el saldo es suficiente
      if (_saldo < widget.precioTotal) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Saldo insuficiente. Debes realizar un depósito.')),
        );
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const SaldoPage()),
        );
        return;
      }

      // ✅ Continuar con la reserva y el pago
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';
      dio.options.headers['Authorization'] = 'Bearer $token';

      final datos = {
        "huesped": widget.huespedId,
        "alojamiento": widget.alojamientoId,
        "fechaCheckIn": widget.fechaCheckIn.toIso8601String(),
        "fechaCheckOut": widget.fechaCheckOut.toIso8601String(),
        "numeroHuespedes": widget.cantidadHuespedes,
        "precioTotal": widget.precioTotal,
      };

      final respuesta = await dio.post(
        'https://hospedajes-4rmu.onrender.com/api/reservas/crear',
        data: datos,
      );

      if (respuesta.statusCode == 201) {
        final reservaId = respuesta.data['_id'] ?? respuesta.data['id'] ?? '';
        if (reservaId.isEmpty) throw Exception('ID de reserva no recibido');

        final pagoResponse = await PaysServices().createPay(reservaId);
        if (pagoResponse == null) throw Exception('Error al crear el pago');

        final nombre = prefs.getString('userName') ?? '';
        final rol = prefs.getString('userRole') ?? '';

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => GuestDashboard(nombre: nombre, rol: rol)),
          (route) => false,
        );
      } else {
        throw Exception('Error al crear la reserva. Código: ${respuesta.statusCode}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Error: $e')),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.grey),
            ),
          ),
          Expanded(
            flex: 4,
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pago del alojamiento'),
        backgroundColor: Colors.green.shade700,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Detalles de la transferencia',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 0.5),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 5,
              shadowColor: Colors.green.shade200,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    _buildDetailRow('Cuenta:', widget.duenio),
                    _buildDetailRow('Concepto:', 'Reserva por ${widget.noches} noches'),
                    _buildDetailRow('Precio por noche:', '\$${widget.precioPorNoche}'),
                    const Divider(height: 32, thickness: 1.2),
                    _buildDetailRow('Total a pagar:', '\$${widget.precioTotal}'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 36),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade700,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: isLoading ? null : _confirmarPago,
                child: isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
                      )
                    : const Text(
                        'Confirmar Transferencia',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
