
import 'package:desole_app/data/models/Calificacion.dart';
import 'package:desole_app/data/models/Reservas.dart';
import 'package:desole_app/role/guest/reserves/widgets/edit_reservation.dart';
import 'package:desole_app/services/reserves_services.dart';
import 'package:flutter/material.dart';
import 'package:collection/collection.dart';
import 'package:intl/intl.dart';

class ReserveDestination extends StatefulWidget {
  final Reservas reservas;

  const ReserveDestination({super.key, required this.reservas});

  @override
  State<ReserveDestination> createState() => _ReserveDestinationState();
}

class _ReserveDestinationState extends State<ReserveDestination> {
  late Reservas reservas;
  final ReservesServices _services = ReservesServices();

  Calificacion? _calificacionExistente;
  bool _isLoadingCalificacion = true;
  bool _isProcessing = false;

  // Añadimos variables para el mensaje flotante
  String? _mensaje;
  bool _isError = false;

  @override
  void initState() {
    super.initState();
    reservas = widget.reservas;
    _loadCalificacion();
  }

  String formatDateWithMonthName(DateTime date) {
  final d = date.toLocal();
  return DateFormat('dd-MMMM-yyyy', 'es').format(d);
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

  // Método para construir el mensaje flotante
  Widget _buildMensaje() {
    if (_mensaje == null) return const SizedBox.shrink();

    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        child: AnimatedOpacity(
          opacity: _mensaje != null ? 1 : 0,
          duration: const Duration(milliseconds: 300),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 8,
                  offset: Offset(0, 3),
                )
              ],
            ),
            constraints: const BoxConstraints(minWidth: 200),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _isError ? Icons.error_outline : Icons.check_circle_outline,
                  color: _isError ? Colors.red.shade700 : Colors.black87,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _mensaje!,
                    style: const TextStyle(
                      color: Colors.black87,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _confirmarEliminar(BuildContext context, String id) async {
    final confirmacion = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          '¿Cancelar la reserva?',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('¿Estás seguro de que deseas cancelar la reserva?'),
            const SizedBox(height: 16),
            Text(
              '⚠️ No se realizarán reembolsos en caso de cancelación.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[800],
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actionsPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        actions: [
          TextButton(
            child: const Text('No', style: TextStyle(fontSize: 16)),
            onPressed: () => Navigator.of(context).pop(false),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade700,
              foregroundColor: Colors.white, // ✅ Letras blancas
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text('Sí, cancelar', style: TextStyle(fontSize: 16)),
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
  setState(() {
    _isProcessing = true;
    _mensaje = null;
  });

  try {
    final result = await _services.delereservations(id);

    if (mounted) {
      setState(() {
        _isProcessing = false;
        _mensaje = result['msg'];
        _isError = !result['success'];
      });

      if (result['success']) {
        Navigator.pop(context, true);
      }
    }
  } catch (e) {
    if (mounted) {
      setState(() {
        _isProcessing = false;
        _mensaje = 'Ocurrió un error al cancelar la reserva.';
        _isError = true;
      });
    }
  }
}


  Future<void> _showCalificationModal() async {
    if (_calificacionExistente != null) {
      // (Lógica para mostrar calificación existente sin cambios)
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
                // CLAVE: Usamos _buildMensaje para el feedback
                setState(() {
                  _mensaje = 'Debes ingresar una calificación y un comentario';
                  _isError = true;
                });
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

              final result = await _services.qualifyreservationsForGuest(
                reservas.id,
                calificacion.toJsonForCreate(),
              );

              setStateModal(() => _isProcessing = false);

              // CLAVE: Mostramos el mensaje del backend
              setState(() {
                _mensaje = result['msg'];
                _isError = result['success'] != true;
              });

              if (result['success'] == true) {
                Navigator.of(context).pop();
                _loadCalificacion();
              }
            }

            return Dialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              insetPadding: const EdgeInsets.all(24),
              backgroundColor: Colors.white,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.star_rate_rounded, size: 60, color: Colors.deepPurple),
                    const SizedBox(height: 10),
                    const Text('Califica tu experiencia', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    const Text('Tu opinión nos ayuda a mejorar', style: TextStyle(color: Colors.grey)),
                    const SizedBox(height: 24),
                    // Estrellas
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
                    // Comentario
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
                    const SizedBox(height: 24),
                    // Botones
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(
                          onPressed: _isProcessing ? null : () => Navigator.of(context).pop(),
                          child: const Text('Cancelar', style: TextStyle(fontSize: 16)),
                        ),
                        ElevatedButton.icon(
                          icon: _isProcessing
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                )
                              : const Icon(Icons.send, size: 20),
                          label: const Text('Enviar', style: TextStyle(fontSize: 16, color: Colors.white)),
                          onPressed: _isProcessing ? null : enviarCalificacion,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepPurple,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
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
      body: Stack(
        children: [
          _isLoadingCalificacion
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
                      ],
                      const SizedBox(height: 16),
                      _buildActionButton('Calificar experiencia', Colors.deepPurple, _showCalificationModal),
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
                        _buildMensaje();
                      }),
                    ],
                  ),
                ),
          _buildMensaje(),
        ],
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

  Widget _buildActionButton(String text, Color color, VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white, // Letras blancas para todos los botones
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 3,
        ),
        onPressed: onPressed,
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}