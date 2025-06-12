import 'package:desole_app/data/models/Reservas.dart';
import 'package:flutter/material.dart';

class DetailReserve extends StatelessWidget {
  final Reservas reservas;
  const DetailReserve({
    super.key,
    required this.reservas,
  });

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: Text(
          reservas.tituloAlojamiento
        ),
      ),
      body: Padding(
        padding : const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children :[
          Text(
                  'Detalles de la Reserva',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
          //Text('Huésped: ${reservas.nombreHuesped} (${reservas.emailHuesped})'),
            Text('Check-in: ${reservas.fechaCheckIn.toLocal().toString().split(' ')[0]}'),
            Text('Check-out: ${reservas.fechaCheckOut.toLocal().toString().split(' ')[0]}'),
            Text('Huéspedes: ${reservas.numeroHuespedes}'),
            Text('Precio total: \$${reservas.precioTotal}'),
            Text('Estado: ${reservas.estadoReserva}'),
            Text('Pago: ${reservas.estadoPago}'),
        
        ]
      )
      
      )
      
    );

  }

}