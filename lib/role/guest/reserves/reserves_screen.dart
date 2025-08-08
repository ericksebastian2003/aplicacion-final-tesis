import 'package:desole_app/role/guest/reserves/widgets/details_guest_reservation.dart';
import 'package:flutter/material.dart';
import '../../../data/models/Reservas.dart';
import '../../../services/reserves_services.dart';

// Declara un RouteObserver global (idealmente en main.dart y exportarlo)
final RouteObserver<ModalRoute<void>> routeObserver = RouteObserver<ModalRoute<void>>();

class ReservesGuestScreen extends StatefulWidget {
  const ReservesGuestScreen({super.key});

  @override
  State<ReservesGuestScreen> createState() => _ReservesGuestScreenState();
}

class _ReservesGuestScreenState extends State<ReservesGuestScreen> with RouteAware {
  late Future<List<Reservas>> _futureReservas;

  @override
  void initState() {
    super.initState();
    _loadReservations();
  }

  void _loadReservations() {
    setState(() {
      _futureReservas = ReservesServices().getReservationsForGuest();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context)!);
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPopNext() {
    _loadReservations(); // refresca cuando regresas a esta pantalla
  }

  Future<bool?> _showDeleteConfirmDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false, // No cierra al tocar fuera
      builder: (context) {
        return AlertDialog(
          title: const Text('Confirmar eliminación'),
          content: const Text('¿Estás seguro de que quieres eliminar esta reserva?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
              ),
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Eliminar'),
            ),
          ],
        );
      },
    );
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
        child: FutureBuilder<List<Reservas>>(
          future: _futureReservas,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(
                  child: Text('Error: ${snapshot.error}',
                      style: const TextStyle(fontSize: 18)));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(
                  child: Text('No hay reservas realizadas',
                      style: TextStyle(fontSize: 18)));
            } else {
              final reservas = snapshot.data!;
              return ListView.builder(
                itemCount: reservas.length,
                itemBuilder: (context, index) {
                  return CardReserves(
                    reservas: reservas[index],
                  );
                },
              );
            }
          },
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
    final estadoPago = reservas.estadoPago.toLowerCase();
    final estadoReserva = reservas.estadoReserva.toLowerCase();

    Color getEstadoColor() {
      switch (estadoReserva) {
        case 'confirmada':
          return Colors.green.shade600;
        case 'pendiente':
          return Colors.orange.shade600;
        case 'cancelada':
          return Colors.red.shade600;
        default:
          return Colors.blue.shade600;
      }
    }

    Color getPagoColor() {
      return estadoPago == 'pagado' ? Colors.green.shade600 : Colors.red.shade600;
    }

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 5,
      shadowColor: Colors.black26,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () {
          // Navega a detalle de reserva
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ReserveDestination(reservas: reservas),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Título y estado reserva
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      reservas.tituloAlojamiento,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: getEstadoColor().withOpacity(0.15),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Text(
                      reservas.estadoReserva.toUpperCase(),
                      style: TextStyle(
                        color: getEstadoColor(),
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.1,
                        fontSize: 14,
                      ),
                    ),
                  )
                ],
              ),

              const SizedBox(height: 18),

              // Datos uno abajo del otro
              _InfoIconText(
                icon: Icons.calendar_today,
                text: 'Check-in: ${reservas.fechaCheckIn.toLocal().toString().split(' ')[0]}',
              ),
              const SizedBox(height: 8),
              _InfoIconText(
                icon: Icons.calendar_month,
                text: 'Check-out: ${reservas.fechaCheckOut.toLocal().toString().split(' ')[0]}',
              ),
              const SizedBox(height: 8),
              _InfoIconText(
                icon: Icons.people,
                text: 'Huéspedes: ${reservas.numeroHuespedes}',
              ),

              const SizedBox(height: 20),

              // Precio y estado pago en fila
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total: \$${reservas.precioTotal.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: getPagoColor().withOpacity(0.15),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Text(
                      reservas.estadoPago.toUpperCase(),
                      style: TextStyle(
                        color: getPagoColor(),
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
class _InfoIconText extends StatelessWidget {
  final IconData icon;
  final String text;
  const _InfoIconText({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey.shade600),
        const SizedBox(width: 6),
        Text(
          text,
          style: TextStyle(fontSize: 15, color: Colors.grey.shade800),
        ),
      ],
    );
  }
}