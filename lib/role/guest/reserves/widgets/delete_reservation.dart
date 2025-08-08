import 'package:desole_app/data/models/Reservas.dart';
import 'package:desole_app/services/reserves_services.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
/*
class DeleteReservation extends StatefulWidget{
  const DeleteReservation({
    super.key,
});
@override 
State<DeleteReservation> createState() => _DeleteReservationState();


}
class _DeleteReservationState extends State<DeleteReservation>{
  Reservas? reservas;
  bool _isLoading = true;

  final ReservesServices _services = ReservesServices();
  //Confirmar eliminacion
void _confirmarEliminar(BuildContext context, String id) async {
    final confirmacion = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Cancelar la reserva?'),
        content: const Text('¿Estás seguro de que deseas cancelar la reserva?'),
        actions: [
          TextButton(
            child: const Text('Cancelar'),
            onPressed: () => Navigator.of(context).pop(false),
          ),
          TextButton(
            child: const Text('Cancelar'),
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

    );
  }
}
*/