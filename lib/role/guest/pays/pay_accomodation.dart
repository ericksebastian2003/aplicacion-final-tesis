import 'package:flutter/material.dart';
import 'package:desole_app/services/pays_services.dart';

class PayAccomodation extends StatefulWidget {
  final int noches;
  final int precioPorNoche;
  final int precioTotal;
  final String nombreDuenio;
  final String alojamiento;
  final String idReserva;

  const PayAccomodation({
    super.key,
    required this.noches,
    required this.precioPorNoche,
    required this.precioTotal,
    required this.nombreDuenio,
    required this.alojamiento,
    required this.idReserva,
  });

  @override
  State<PayAccomodation> createState() => _PayAccomodationState();
}

class _PayAccomodationState extends State<PayAccomodation> {
  bool isLoading = false;

  Future<void> _confirmarPago() async {
    setState(() => isLoading = true);

    final paysService = PaysServices();
    final pago = await paysService.createPay(widget.idReserva);

    setState(() => isLoading = false);

    if (pago != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ Transferencia realizada exitosamente')),
      );
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('❌ Error al realizar la transferencia')),
      );
    }
  }

  Widget _buildDetailRow(String label, String value, {Color? valueColor, double? valueFontSize}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
              flex: 3,
              child: Text(
                label,
                style: TextStyle(
                    fontWeight: FontWeight.w600, color: Colors.grey.shade700),
              )),
          Expanded(
              flex: 4,
              child: Text(
                value,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: valueColor ?? Colors.black,
                  fontSize: valueFontSize ?? 16,
                ),
              )),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transferencia Bancaria'),
        centerTitle: true,
        backgroundColor: Colors.green.shade700,
        elevation: 2,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: isLoading ? null : () => Navigator.pop(context, false),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Detalles de la Transferencia',
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                  child: Column(
                    children: [
                      _buildDetailRow('Titular de la cuenta:', widget.nombreDuenio),
                      _buildDetailRow('Alojamiento:', widget.alojamiento),
                      _buildDetailRow(
                          'Concepto:', 'Reserva por ${widget.noches} noches'),
                      _buildDetailRow(
                        'Precio por noche:',
                        '\$${widget.precioPorNoche}',
                      ),
                      const Divider(height: 30),
                      _buildDetailRow(
                        'Total a pagar:',
                        '\$${widget.precioTotal}',
                        valueColor: Colors.green.shade700,
                        valueFontSize: 20,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 40),
              ElevatedButton.icon(
                onPressed: isLoading ? null : _confirmarPago,
                icon: isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 3,
                        ),
                      )
                    : const Icon(Icons.check_circle_outline, size: 26),
                label: Text(
                  isLoading ? 'Procesando...' : 'Confirmar Transferencia',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                  backgroundColor: Colors.green.shade700,
                  foregroundColor: Colors.white,
                  elevation: 5,
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: isLoading ? null : () => Navigator.pop(context, false),
                child: const Text(
                  'Cancelar',
                  style: TextStyle(fontSize: 16, color: Colors.black54),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
