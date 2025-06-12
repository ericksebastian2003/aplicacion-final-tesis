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
            Text('Check-in: ${reservas.fechaCheckIn.toLocal().toString().split(' ')[0]}'),
            Text('Check-out: ${reservas.fechaCheckOut.toLocal().toString().split(' ')[0]}'),
            Text('Huéspedes: ${reservas.numeroHuespedes}'),
            Text('Precio total: \$${reservas.precioTotal}'),
            Text('Estado: ${reservas.estadoReserva}'),
            Text('Pago: ${reservas.estadoPago}'),
            SizedBox(height: 30),
            SizedBox(
  width: double.infinity,
  child: ElevatedButton(
    style: ElevatedButton.styleFrom(
      padding: const EdgeInsets.symmetric(vertical: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      backgroundColor: Colors.black,
    ),
    onPressed: () {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => EditReservationScreen(reservas: reservas),
    ),
  );
},

    child: const Text(
      'Actualizar reserva',
      style: TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.w700,
      ),
    ),
  ),
),
SizedBox(height: 30),
SizedBox(
  width: double.infinity,
  child: ElevatedButton(
    style: ElevatedButton.styleFrom(
      padding: const EdgeInsets.symmetric(vertical: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      backgroundColor: Colors.black,
    ),
    onPressed: () => _confirmarEliminar(context, reservas.id),
    child: const Text(
      'Cancelar reserva',
      style: TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.w700,
      ),
    ),
  ),
),

        ]
      )
      
      )
      
    );

  }

}