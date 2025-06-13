import 'package:desole_app/data/models/Reservas.dart';
import 'package:desole_app/role/guest/reserves/widgets/edit_reservation.dart';
import 'package:desole_app/services/reserves_services.dart';
import 'package:flutter/material.dart';

class DetailGuestReservation extends StatefulWidget {
  Reservas reservas;
  DetailGuestReservation({
    super.key,
    required this.reservas,
  });
  @override
  State<DetailGuestReservation> createState() => _DetailsGuestReservationState();
}
class _DetailsGuestReservationState extends State<DetailGuestReservation> {
   late Reservas reservas;
   final ReservesServices _services = ReservesServices();

  @override
  void initState() {
    super.initState();
    reservas = widget.reservas;
  }

  //Confirmar eliminacion
void _confirmarEliminar(BuildContext context, String id) async {
    final confirmacion = await showDialog<bool>(
  context: context,
  builder: (context) => AlertDialog(
    title: const Text('¿Cancelar la reserva?'),
    content: const Text('¿Estás seguro de que deseas cancelar la reserva?'),
    actions: [
      TextButton(
        child: const Text('No'),
        onPressed: () => Navigator.of(context).pop(false),
      ),
      TextButton(
        child: const Text('Sí'),
        onPressed: () => Navigator.of(context).pop(true),
      ),
    ],
  ),
);


    if (confirmacion == true) {
      await _cancelarReserva(context, id);
    }
  
 }
 Future<void> _cancelarReserva(BuildContext context, String id) async {
    print('🗑️ Intentando eliminar la reserva con id: $id'); // PRINT para debug

    try {
      final success = await _services.delereservations(id);

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Reserva cancelada con éxito')),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al cancelar la reserva')),
        );
      }
    } catch (e) {
      print('❌ Error al eliminar: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cancelar: $e')),
      );
    }
  }
  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Detalle del alojamiento',
          style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding : const EdgeInsets.all(16.0),
      child: Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    _buildDetailRow('Nombre del alojamiento', reservas.tituloAlojamiento.toString().split(' ')[0]),
    _buildDetailRow('Check-in', reservas.fechaCheckIn.toLocal().toString().split(' ')[0]),
    _buildDetailRow('Check-out', reservas.fechaCheckOut.toLocal().toString().split(' ')[0]),
    _buildDetailRow('Huéspedes', reservas.numeroHuespedes.toString()),
    _buildDetailRow('Precio total', '\$${reservas.precioTotal}'),
    _buildDetailRow('Estado', reservas.estadoReserva),
    _buildDetailRow('Pago', reservas.estadoPago),
    const SizedBox(height: 50),
    _buildActionButton('Actualizar reserva', Colors.black, () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => EditReservationScreen(reservas: reservas),
        ),
      );
    }),
    const SizedBox(height: 16),
    _buildActionButton('Cancelar reserva', Colors.red.shade700, () {
      _confirmarEliminar(context, reservas.id);
    }),
  ],
),
      
      )
      
    );

  }}
Widget _buildDetailRow(String label, String value) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(
      children: [
        Text(
          '$label: ',
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(color: Colors.black87 , fontSize: 22),
          ),
        ),
      ],
    ),
  );
}

Widget _buildActionButton(String text, Color color, VoidCallback onPressed) {
  return SizedBox(
    width: double.infinity,
    child: ElevatedButton(
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
        backgroundColor: color,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        elevation: 3,
      ),
      onPressed: onPressed,
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
  );
}
