import 'package:desole_app/data/models/Calificacion.dart';
import 'package:desole_app/data/models/Reservas.dart';
import 'package:desole_app/role/guest/reserves/widgets/edit_reservation.dart';
import 'package:desole_app/services/reserves_services.dart';
import 'package:flutter/material.dart';
import 'package:collection/collection.dart';

class DetailGuestReservation extends StatefulWidget {
  final Reservas reservas;

  const DetailGuestReservation({super.key, required this.reservas});

  @override
  State<DetailGuestReservation> createState() => _DetailGuestReservationState();
}

class _DetailGuestReservationState extends State<DetailGuestReservation> {
  late Reservas reservas;
  final ReservesServices _services = ReservesServices();

  Calificacion? _calificacionExistente;
  bool _isLoadingCalificacion = true;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    reservas = widget.reservas;
    _loadCalificacion();
  }

  String formatDateWithMonthName(DateTime date) {
    final d = date.toLocal();
    const monthNames = [
      '', 'Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun',
      'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'
    ];
    return '${d.day}-${monthNames[d.month]}-${d.year}';
  }

  Future<void> _loadCalificacion() async {
    setState(() => _isLoadingCalificacion = true);
    final calificaciones = await _services.getScoreForGuest(reservas.alojamientoId);
    final existente = calificaciones.firstWhereOrNull((c) => c.reserva == reservas.id);
    setState(() {
      _calificacionExistente = existente;
      _isLoadingCalificacion = false;
    });
  }

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
            onPressed: () => Navigator.pop(context, true),
          ),
        ],
      ),
    );

    if (confirmacion == true) {
      await _cancelarReserva(context, id);
    }
  }

  Future<void> _cancelarReserva(BuildContext context, String id) async {
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cancelar: $e')),
      );
    }
  }

  Future<void> _showCalificationModal() async {
    if (_calificacionExistente != null) {
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Tu calificación'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  return Icon(
                    Icons.star,
                    size: 32,
                    color: index < _calificacionExistente!.estrellas ? Colors.amber : Colors.grey[300],
                  );
                }),
              ),
              const SizedBox(height: 12),
              Text(_calificacionExistente!.comentario),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cerrar'),
            )
          ],
        ),
      );
      return;
    }

    int rating = 0;
    TextEditingController comentarioController = TextEditingController();

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateModal) {
            Future<void> enviarCalificacion() async {
              if (rating == 0 || comentarioController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Debes ingresar una calificación y un comentario')),
                );
                return;
              }

              setStateModal(() => _isProcessing = true);

              final calificacion = Calificacion(
                id: '',
                huespedId: '',
                huespedNombre: null,
                alojamiento: '',
                reserva: reservas.id,
                estrellas: rating,
                comentario: comentarioController.text.trim(),
                createdAt: DateTime.now(),
                updatedAt: DateTime.now(),
              );

              final success = await _services.qualifyreservationsForGuest(
                reservas.id,
                calificacion.toJsonForCreate(),
              );

              setStateModal(() => _isProcessing = false);

              if (success) {
                Navigator.of(context).pop();
                _loadCalificacion();
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Error al enviar la calificación')),
                );
              }
            }

            return AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: Column(
                children: const [
                  Icon(Icons.star_rate_rounded, size: 48, color: Colors.deepPurple),
                  SizedBox(height: 10),
                  Text('Califica tu experiencia', style: TextStyle(fontWeight: FontWeight.bold)),
                  SizedBox(height: 4),
                  Text(
                    'Tu opinión nos ayuda a mejorar',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (index) {
                        return IconButton(
                          icon: Icon(
                            Icons.star_rounded,
                            size: 36,
                            color: index < rating ? Colors.amber : Colors.grey[300],
                          ),
                          onPressed: () => setStateModal(() => rating = index + 1),
                        );
                      }),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: comentarioController,
                      maxLines: 4,
                      decoration: InputDecoration(
                        hintText: 'Escribe tu comentario...',
                        filled: true,
                        fillColor: Colors.grey[100],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: _isProcessing ? null : () => Navigator.of(context).pop(),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton.icon(
                  icon: _isProcessing
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Icon(Icons.send),
                  label: const Text('Enviar',style: TextStyle(color: Colors.white),),
                  onPressed: _isProcessing ? null : enviarCalificacion,
                  style: ElevatedButton.styleFrom(

                    backgroundColor: Colors.deepPurple,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Detalle de la reserva',
          style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
        ),
      ),
      body: _isLoadingCalificacion
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDetailRow('Fecha de ingreso', formatDateWithMonthName(reservas.fechaCheckIn)),
                  _buildDetailRow('Fecha de salida', formatDateWithMonthName(reservas.fechaCheckOut)),
                  _buildDetailRow('Huéspedes', reservas.numeroHuespedes.toString()),
                  _buildDetailRow('Precio total', '\$${reservas.precioTotal.toStringAsFixed(2)}'),
                  _buildDetailRow('Estado', reservas.estadoReserva),
                  _buildDetailRow('Pago', reservas.estadoPago),
                  const SizedBox(height: 30),

                  if (_calificacionExistente != null) ...[
                    Text(
                      'Tu calificación:',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.green[700]),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: List.generate(5, (index) {
                        return Icon(
                          Icons.star,
                          size: 32,
                          color: index < _calificacionExistente!.estrellas ? Colors.amber : Colors.grey[300],
                        );
                      }),
                    ),
                    const SizedBox(height: 8),
                    Text(_calificacionExistente!.comentario, style: const TextStyle(fontSize: 18)),
                  ] else if (reservas.estadoReserva.toLowerCase() == 'confirmada') ...[
                    Center(
                      child: InkWell(
                        borderRadius: BorderRadius.circular(20),
                        onTap: _showCalificationModal,
                        child: Ink(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF7B1FA2), Color(0xFF512DA8)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.deepPurpleAccent.withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 16),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: const [
                                Icon(Icons.star, color: Colors.white),
                                SizedBox(width: 10),
                                Text(
                                  'Calificar experiencia',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: 30),

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
            ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Text('$label: ', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 18)),
            Expanded(child: Text(value, style: const TextStyle(fontSize: 18))),
          ],
        ),
      ),
    );
  }
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
