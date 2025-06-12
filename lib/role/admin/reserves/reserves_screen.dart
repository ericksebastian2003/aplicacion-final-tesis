import 'package:desole_app/role/admin/reserves/widgets/detail_admin_reserve.dart';
import 'package:flutter/material.dart';
import '../../../data/models/Reservas.dart';
import '../../../services/reserves_services.dart';

class ReservesAdminScreen extends StatefulWidget {
  const ReservesAdminScreen({super.key});

  @override
  State<ReservesAdminScreen> createState() => _ReservesAdminScreenState();
}

class _ReservesAdminScreenState extends State<ReservesAdminScreen> {
  late Future<List<Reservas>> _futureReservas;

  @override
  void initState() {
    super.initState();
    _futureReservas = ReservesServices().getReservationsForAdmin();
  }

  Future<void> _refreshData() async {
    setState(() {
      _futureReservas = ReservesServices().getReservationsForAdmin();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Reservas',
          style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: RefreshIndicator(
          onRefresh: _refreshData,
          child: FutureBuilder<List<Reservas>>(
            future: _futureReservas,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('❌ Error: ${snapshot.error}'));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text('📭 No hay reservas realizadas'));
              } else {
                final reservas = snapshot.data!;
                return ListView.builder(
                  itemCount: reservas.length,
                  itemBuilder: (context, index) {
                    return CardReserves(reservas: reservas[index]);
                  },
                );
              }
            },
          ),
        ),
      ),
    );
  }
}

class CardReserves extends StatelessWidget {
  final Reservas reservas;
  const CardReserves({super.key, required this.reservas});

  String formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
           '${date.month.toString().padLeft(2, '0')}/'
           '${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 6,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Título
            Row(
              children: [
                const Icon(Icons.home, color: Colors.blueAccent),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    reservas.tituloAlojamiento,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Información básica
            Row(
              children: [
                const Icon(Icons.person, size: 20),
                const SizedBox(width: 6),
                Text('${reservas.nombreHuesped} (${reservas.emailHuesped})'),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 20),
                const SizedBox(width: 6),
                Text('Check-in: ${formatDate(reservas.fechaCheckIn)}'),
                const SizedBox(width: 12),
                Text('Check-out: ${formatDate(reservas.fechaCheckOut)}'),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(Icons.group, size: 20),
                const SizedBox(width: 6),
                Text('Huéspedes: ${reservas.numeroHuespedes}'),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(Icons.attach_money, size: 20),
                const SizedBox(width: 6),
                Text('Total: \$${reservas.precioTotal.toStringAsFixed(2)}'),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(Icons.info_outline, size: 20),
                const SizedBox(width: 6),
                Text('Estado: ${reservas.estadoReserva}'),
              ],
            ),
            Row(
              children: [
                const Icon(Icons.payment, size: 20),
                const SizedBox(width: 6),
                Text('Pago: ${reservas.estadoPago}'),
              ],
            ),
            const SizedBox(height: 12),

            // Botón "Ver más"
            Align(
              alignment: Alignment.centerRight,
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => DetailAdminReserve(reservas: reservas),
                    ),
                  );
                },
                icon: const Icon(Icons.arrow_forward),
                label: const Text('Ver más'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
