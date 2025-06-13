import 'package:desole_app/data/models/Reportes.dart';
import 'package:desole_app/services/complaints_services.dart';
import 'package:flutter/material.dart';

class DetailReport extends StatefulWidget {
  final Reportes reportes;
  final ComplaintsServices services = ComplaintsServices();

  DetailReport({
    super.key,
    required this.reportes,
  });

  @override
  State<DetailReport> createState() => _DetailReportState();
}

class _DetailReportState extends State<DetailReport> {
  late String _estado;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _estado = widget.reportes.estado;
  }

  Color _getEstadoColor(String estado) {
    switch (estado.toLowerCase()) {
      case 'revisado':
        return Colors.green;
      case 'rechazado':
        return Colors.red;
      case 'pendiente':
      default:
        return Colors.orange;
    }
  }

  Future<void> _actualizarEstado(String nuevoEstado) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final success = await widget.services.changeStatusComplaints(widget.reportes.id, nuevoEstado);
      if (success) {
        setState(() {
          _estado = nuevoEstado;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Estado actualizado a ${nuevoEstado.toUpperCase()}')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al actualizar estado')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }

    setState(() {
      _isLoading = false;
    });
  }

  void _mostrarModalSeleccionEstado() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Center(
                  child: Text(
                    'Selecciona el nuevo estado',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              ListTile(
                leading: Icon(Icons.pending_actions, color: Colors.orange),
                title: const Text('Pendiente'),
                onTap: () {
                  Navigator.pop(context);
                  _actualizarEstado('pendiente');
                },
                selected: _estado == 'pendiente',
                selectedTileColor: Colors.orange.withOpacity(0.15),
              ),
              ListTile(
                leading: Icon(Icons.check_circle, color: Colors.green),
                title: const Text('Revisado'),
                onTap: () {
                  Navigator.pop(context);
                  _actualizarEstado('revisado');
                },
                selected: _estado == 'revisado',
                selectedTileColor: Colors.green.withOpacity(0.15),
              ),
              ListTile(
                leading: Icon(Icons.cancel, color: Colors.red),
                title: const Text('Rechazado'),
                onTap: () {
                  Navigator.pop(context);
                  _actualizarEstado('rechazado');
                },
                selected: _estado == 'rechazado',
                selectedTileColor: Colors.red.withOpacity(0.15),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  String _capitalizar(String texto) {
    if (texto.isEmpty) return texto;
    return texto[0].toUpperCase() + texto.substring(1).toLowerCase();
  }

  @override
  Widget build(BuildContext context) {
    final estadoColor = _getEstadoColor(_estado);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Detalles del reporte',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 1,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Card con sombra y borde para destacar la info del denunciante
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              margin: EdgeInsets.zero,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const Icon(Icons.person, size: 40, color: Colors.black54),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Denunciante',
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black54),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${widget.reportes.reportante.nombre} ${widget.reportes.reportante.apellido}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Estado actual en un Chip
            Row(
              children: [
                const Text(
                  'Estado: ',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                Chip(
                  label: Text(
                    _capitalizar(_estado),
                    style: TextStyle(
                      color: estadoColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  backgroundColor: estadoColor.withOpacity(0.15),
                  side: BorderSide(color: estadoColor),
                ),
                const Spacer(),
                ElevatedButton.icon(
                  onPressed: _isLoading ? null : _mostrarModalSeleccionEstado,
                  icon: const Icon(Icons.edit, size: 20),
                  label: const Text('Cambiar estado'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 32),

            const Text(
              'Motivo del reporte',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Text(
                widget.reportes.motivo,
                style: const TextStyle(fontSize: 16, height: 1.5, color: Colors.black87),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
