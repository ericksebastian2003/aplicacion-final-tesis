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
        title: const Text('Reservas',   
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
                'Nombre del huesped: ${reservas.nombreHuesped!}',
                style: TextStyle(fontSize: 16, color: Colors.grey[800]),
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
