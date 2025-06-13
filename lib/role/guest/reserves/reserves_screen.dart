import 'package:desole_app/role/guest/reserves/widgets/details_guest_reservation.dart';
import 'package:flutter/material.dart';
import '../../../data/models/Reservas.dart';
import '../../../services/reserves_services.dart';

class ReservesGuestScreen extends StatefulWidget {
  const ReservesGuestScreen({super.key});

  @override
  State<ReservesGuestScreen> createState() => _ReservesGuestScreenState();
}

class _ReservesGuestScreenState extends State<ReservesGuestScreen> {
  late Future<List<Reservas>> _futureReservas;

  @override
  void initState() {
    super.initState();
    _futureReservas = ReservesServices().getReservationsForGuest();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Mis reservas',
          style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Expanded(
              child: FutureBuilder<List<Reservas>>(
                future: _futureReservas,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}', style: TextStyle(fontSize: 18)));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('No hay reservas realizadas', style: TextStyle(fontSize: 18)));
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
          ],
        ),
      ),
    );
  }
}

class CardReserves extends StatelessWidget {
  final Reservas reservas;
  const CardReserves({super.key, required this.reservas});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => DetailGuestReservation(reservas: reservas),
          ),
        );
      },
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 3,
        shadowColor: Colors.grey.shade200,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                reservas.tituloAlojamiento,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Text(
                'Fecha de ingreso: ${reservas.fechaCheckIn.toLocal().toString().split(' ')[0]}',
                style: TextStyle(fontSize: 16, color: Colors.grey[800]),
              ),
              Text(
                'Fecha de salida: ${reservas.fechaCheckOut.toLocal().toString().split(' ')[0]}',
                style: TextStyle(fontSize: 16, color: Colors.grey[800]),
              ),
              Text(
                'Número de huéspedes: ${reservas.numeroHuespedes}',
                style: TextStyle(fontSize: 16, color: Colors.grey[800]),
              ),
              const SizedBox(height: 12),
              Text(
                'Precio total: \$${reservas.precioTotal.toStringAsFixed(2)}',
                style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 20,
                runSpacing: 6,
                children: [
                  Text(
                    'Estado: ${reservas.estadoReserva}',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.blueGrey[700],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    'Pago: ${reservas.estadoPago}',
                    style: TextStyle(
                      fontSize: 16,
                      color: reservas.estadoPago.toLowerCase() == 'pagado'
                          ? Colors.green[700]
                          : Colors.red[700],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
