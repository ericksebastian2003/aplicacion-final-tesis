import 'package:desole_app/role/host/reserves/widgets/detail_reserve.dart';
import 'package:flutter/material.dart';
import '../../../data/models/Reservas.dart';
import '../../../services/reserves_services.dart';
class ReservesScreen extends StatefulWidget {
  const ReservesScreen({super.key});

  @override
  State<ReservesScreen> createState() => _ReservesScreenState();
}

class _ReservesScreenState extends State<ReservesScreen> {
late Future<List<Reservas>> _futureReservas;

  @override
void initState() {
  super.initState();
  _futureReservas = ReservesServices().getReservationsForHost();
}



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reservas'),
      ),
      body: Padding(
  padding: const EdgeInsets.all(12.0),
  child: Column(
    children: [
      Expanded(
        
        child: FutureBuilder<List<Reservas>>(
          future: _futureReservas,
          builder: (context, snapshot) {
             print('🔍 [SNAPSHOT STATE] => ${snapshot.connectionState}');
            print('🔍 [SNAPSHOT HAS DATA] => ${snapshot.hasData}');
            print('🔍 [SNAPSHOT ERROR] => ${snapshot.error}');

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('No hay reservas realizadas'));
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
      onTap: (){
        Navigator.push(context, MaterialPageRoute(builder: (_)=> DetailReserve(reservas: reservas))
        );
      },
      child: Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              reservas.tituloAlojamiento,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text('Huésped: ${reservas.nombreHuesped} (${reservas.emailHuesped})'),
            Text('Check-in: ${reservas.fechaCheckIn.toLocal().toString().split(' ')[0]}'),
            Text('Check-out: ${reservas.fechaCheckOut.toLocal().toString().split(' ')[0]}'),
            Text('Huéspedes: ${reservas.numeroHuespedes}'),
            Text('Precio total: \$${reservas.precioTotal}'),
            Text('Estado: ${reservas.estadoReserva}'),
            Text('Pago: ${reservas.estadoPago}'),
          ],
        ),
      ),
    )
    );
  }
}
