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

  String? mensaje;  // Mensaje a mostrar
  bool isError = false;  // Si el mensaje es de error o no

  Future<void> _confirmarPago() async {
    setState(() {
      isLoading = true;
      mensaje = null; // Limpiar mensaje previo
    });

    try {
      final userService = UsersServices();
      final profile = await userService.getUserProfile();
      final rawSaldo = profile?['saldo'];
      _saldo = rawSaldo is num ? rawSaldo.toDouble() : 0;

      if (_saldo < widget.precioTotal) {
        setState(() {
          mensaje = 'Saldo insuficiente. Debes realizar un depósito.';
          isError = true;
        });
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const SaldoPage()),
        );
        return;
      }

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

      final backendMsg = respuesta.data['msg'] ?? 'No se recibió mensaje del backend';

      if (respuesta.statusCode == 201 || respuesta.statusCode == 200) {
        final reservaId = respuesta.data['_id'] ?? respuesta.data['id'] ?? '';
        if (reservaId.isEmpty) throw Exception('ID de reserva no recibido');

        final pagoResponse = await PaysServices().createPay(reservaId);
        if (pagoResponse == null || pagoResponse['success'] != true) {
          setState(() {
            mensaje = pagoResponse?['msg'] ?? 'Error al crear el pago';
            isError = true;
          });
          return;
        }

        setState(() {
          mensaje = pagoResponse['msg'] ?? 'Pago realizado con éxito';
          isError = false;
        });

        final nombre = prefs.getString('userName') ?? '';
        final rol = prefs.getString('userRole') ?? '';

        // Esperamos 2 segundos para que el usuario vea el mensaje antes de navegar
        await Future.delayed(const Duration(seconds: 2));

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => GuestDashboard(nombre: nombre, rol: rol)),
          (route) => false,
        );
      } else {
        setState(() {
          mensaje = 'Error: $backendMsg';
          isError = true;
        });
      }
    } catch (e) {
      setState(() {
        mensaje = '❌ Error inesperado: $e';
        isError = true;
      });
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

  Widget _buildMensaje() {
    if (mensaje == null) return const SizedBox.shrink();

    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        child: AnimatedOpacity(
          opacity: mensaje != null ? 1 : 0,
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
                  isError ? Icons.error_outline : Icons.check_circle_outline,
                  color: isError ? Colors.red.shade700 : Colors.black87,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    mensaje!,
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
          'Pago del alojamiento',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Detalles de la transferencia',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
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
                        _buildDetailRow('Propietario de Cuenta:', widget.duenio),
                        _buildDetailRow('Concepto:', 'Reserva por alojamiento'),
                        _buildDetailRow('Precio por noche:', '\$${widget.precioPorNoche}'),
                        const Divider(height: 32, thickness: 1.2),
                        _buildDetailRow('Total a pagar:', '\$${widget.precioTotal}'),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: isLoading ? null : _confirmarPago,
                    child: isLoading
                        ? const SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.5,
                            ),
                          )
                        : const Text(
                            'Confirmar Transferencia',
                            style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                  ),
                ),
              ],
            ),
          ),

          // Mensaje flotante
          _buildMensaje(),
        ],
      ),
    );
  }
}
