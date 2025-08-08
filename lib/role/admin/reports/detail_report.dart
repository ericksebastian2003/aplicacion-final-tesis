import 'package:desole_app/data/models/ReportesAdmin.dart';
import 'package:desole_app/services/complaints_services.dart';
import 'package:flutter/material.dart';

class DetailReport extends StatefulWidget {
  final ReporteAdmin reportes;
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
  String? _mensaje;
  bool _isError = false;

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
      _mensaje = null; // Limpiar mensaje anterior
    });

    try {
      // ✅ CORRECCIÓN CLAVE: El servicio ahora devuelve un String? con la respuesta
      final responseMessage = await widget.services.changeStatusComplaints(widget.reportes.id, nuevoEstado);
      
      if (responseMessage != null) {
        setState(() {
          _estado = nuevoEstado;
          _mensaje = responseMessage;
          _isError = false; // Asumimos éxito si hay mensaje
        });
        
      } else {
        setState(() {
          _mensaje = 'Error al actualizar el estado.';
          _isError = true;
        });
      }
    } catch (e) {
      setState(() {
        _mensaje = 'Error inesperado: $e';
        _isError = true;
      });
    }

    setState(() {
      _isLoading = false;
    });
  }

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
                leading: const Icon(Icons.pending_actions, color: Colors.orange),
                title: const Text('Pendiente'),
                onTap: () {
                  Navigator.pop(context);
                  _actualizarEstado('pendiente');
                },
                selected: _estado == 'pendiente',
                selectedTileColor: Colors.orange.withOpacity(0.15),
              ),
              ListTile(
                leading: const Icon(Icons.check_circle, color: Colors.green),
                title: const Text('Revisado'),
                onTap: () {
                  Navigator.pop(context);
                  _actualizarEstado('revisado');
                },
                selected: _estado == 'revisado',
                selectedTileColor: Colors.green.withOpacity(0.15),
              ),
              ListTile(
                leading: const Icon(Icons.cancel, color: Colors.red),
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
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                                '${widget.reportes.reportante?.nombre ?? 'Anónimo'} ${widget.reportes.reportante?.apellido ?? ''}',
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
                    // ✅ Botón mejorado para mostrar carga
                    ElevatedButton(
                      onPressed: _isLoading ? null : _mostrarModalSeleccionEstado,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text('Cambiar estado'),
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
          // ✅ Mostrar el mensaje flotante
          _buildMensaje(),
        ],
      ),
    );
  }
}