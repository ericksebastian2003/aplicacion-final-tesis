import 'package:desole_app/data/models/PagosAnfitriones.dart';
import 'package:flutter/material.dart';
import 'package:desole_app/data/models/Reservas.dart';
import 'package:desole_app/services/pays_services.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

class DetailReserve extends StatefulWidget {
  final Reservas reservas;

  const DetailReserve({super.key, required this.reservas});

  @override
  State<DetailReserve> createState() => _DetailReserveState();
}

class _DetailReserveState extends State<DetailReserve> {
  List<PagosAnfitriones> pagos = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('es').then((_) {
      _loadPagos();
    });
  }

  Future<void> _loadPagos() async {
    final servicio = PaysServices();
    final resultado = await servicio.getPagosPorReserva(widget.reservas.id);
    setState(() {
      pagos = resultado;
      isLoading = false;
    });
  }

  String formatDate(DateTime date) {
    return DateFormat('dd MMM yyyy', 'es').format(date);
  }

  Widget _buildInfoRow(IconData icon, String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 22, color: Colors.blueAccent),
          const SizedBox(width: 12),
          Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: valueColor ?? Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 13,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.reservas;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          r.tituloAlojamiento,
          style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                    elevation: 6,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15)),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Detalles de la Reserva',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blueAccent,
                                ),
                          ),
                          const Divider(height: 25, thickness: 2),
                          _buildInfoRow(Icons.calendar_today, 'Check-in:', formatDate(r.fechaCheckIn)),
                          _buildInfoRow(Icons.calendar_month, 'Check-out:', formatDate(r.fechaCheckOut)),
                          _buildInfoRow(Icons.people, 'Huéspedes:', r.numeroHuespedes.toString()),
                          _buildInfoRow(Icons.attach_money, 'Total:', '\$${r.precioTotal.toStringAsFixed(2)}'),
                          _buildInfoRow(
                            Icons.verified,
                            'Estado:',
                            '',
                            valueColor: Colors.black,
                          ),
                          _buildStatusChip(
                            r.estadoReserva.toUpperCase(),
                            r.estadoReserva.toLowerCase() == 'confirmada'
                                ? Colors.green
                                : Colors.orange,
                          ),
                          const SizedBox(height: 8),
                          _buildInfoRow(Icons.payment, 'Pago:', ''),
                          _buildStatusChip(
                            r.estadoPago.toUpperCase(),
                            r.estadoPago.toLowerCase() == 'pagado' ? Colors.green : Colors.redAccent,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Pagos realizados',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.blueAccent,
                        ),
                  ),
                  const SizedBox(height: 12),
                  if (pagos.isNotEmpty)
                    ...pagos.map(
                      (pago) => Card(
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        margin: const EdgeInsets.only(bottom: 16),
                        color: Colors.green[50],
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Pago',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green[700],
                                    ),
                              ),
                              const SizedBox(height: 10),
                              _buildInfoRow(
                                  Icons.monetization_on,
                                  'Monto total:',
                                  '\$${pago.montoTotal.toStringAsFixed(2)}'),
                              _buildInfoRow(
                                  Icons.account_balance_wallet,
                                  'Comisión sistema:',
                                  '\$${pago.comisionSistema.toStringAsFixed(2)}'),
                              _buildInfoRow(
                                  Icons.person,
                                  'Para anfitrión:',
                                  '\$${pago.montoAnfitrion.toStringAsFixed(2)}'),
                              _buildInfoRow(Icons.date_range, 'Fecha:', formatDate(pago.createdAt)),
                            ],
                          ),
                        ),
                      ),
                    )
                  else
                    const Padding(
                      padding: EdgeInsets.only(top: 20),
                      child: Center(
                        child: Text(
                          'No hay información de pagos registrada para esta reserva.',
                          style: TextStyle(color: Colors.grey, fontSize: 16),
                        ),
                      ),
                    ),
                ],
              ),
            ),
    );
  }
}
