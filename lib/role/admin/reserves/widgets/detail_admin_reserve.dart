import 'package:desole_app/data/models/Reservas.dart';
import 'package:flutter/material.dart';

class DetailAdminReserve extends StatelessWidget {
  final Reservas reservas;
  const DetailAdminReserve({super.key, required this.reservas});

  String formatDate(DateTime date) {
    final months = [
      'ene', 'feb', 'mar', 'abr', 'may', 'jun',
      'jul', 'ago', 'sep', 'oct', 'nov', 'dic'
    ];
    return '${date.day.toString().padLeft(2, '0')} '
           '${months[date.month - 1]} '
           '${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(reservas.tituloAlojamiento,
          style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Detalles de la Reserva',
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),

                Row(
                  children: [
                    const Icon(Icons.person, color: Colors.blue),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        '${reservas.nombreHuesped} (${reservas.emailHuesped})',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),
                const Divider(height: 24),

                Row(
                  children: [
                    const Icon(Icons.calendar_today, color: Colors.green),
                    const SizedBox(width: 10),
                    Text('Check-in: ${formatDate(reservas.fechaCheckIn)}'),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.calendar_today_outlined, color: Colors.redAccent),
                    const SizedBox(width: 10),
                    Text('Check-out: ${formatDate(reservas.fechaCheckOut)}'),
                  ],
                ),
                const Divider(height: 24),

                Row(
                  children: [
                    const Icon(Icons.group, color: Colors.deepPurple),
                    const SizedBox(width: 10),
                    Text('Huéspedes: ${reservas.numeroHuespedes}'),
                  ],
                ),
                const SizedBox(height: 12),

                Row(
                  children: [
                    const Icon(Icons.attach_money, color: Colors.orange),
                    const SizedBox(width: 10),
                    Text(
                      'Precio total: \$${reservas.precioTotal.toStringAsFixed(2)}',
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
                const Divider(height: 24),

                Row(
                  children: [
                    const Icon(Icons.info, color: Colors.teal),
                    const SizedBox(width: 10),
                    Text('Estado de reserva: ${reservas.estadoReserva}'),
                  ],
                ),
                const SizedBox(height: 8),

                Row(
                  children: [
                    const Icon(Icons.payment, color: Colors.brown),
                    const SizedBox(width: 10),
                    Text('Estado de pago: ${reservas.estadoPago}'),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
