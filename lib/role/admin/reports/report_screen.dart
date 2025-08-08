import 'package:desole_app/services/complaints_services.dart';
import 'package:flutter/material.dart';
import '../../../data/models/ReportesAdmin.dart';
import 'detail_report.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  // ✅ CORRECCIÓN: La variable ahora es nullable
  late Future<List<ReporteAdmin>?> _futureReportes;
  String tipoSeleccionado = 'alojamiento';

  @override
  void initState() {
    super.initState();
    // ✅ Cargar los reportes solo una vez al inicio
    _loadReportes();
  }

  void _loadReportes() {
    final service = ComplaintsServices();
    _futureReportes = service.getComplaintsForAdmin(tipoSeleccionado);
    // ✅ No es necesario llamar a setState aquí, FutureBuilder se encarga
    // ya que _futureReportes cambia de valor
  }

  void _onTipoChanged(String nuevoTipo) {
    if (tipoSeleccionado != nuevoTipo) {
      setState(() {
        tipoSeleccionado = nuevoTipo;
        _loadReportes();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Reportes',
          style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          _buildFiltroBotones(),
          Expanded(
            child: FutureBuilder<List<ReporteAdmin>?>( // ✅ CORRECCIÓN: Tipo nullable aquí
              future: _futureReportes,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('❌ Error al cargar los reportes: ${snapshot.error}'));
                } else if (snapshot.data == null || snapshot.data!.isEmpty) {
                  // ✅ Manejo del caso donde la lista es nula o vacía
                  return const Center(child: Text('No hay reportes disponibles'));
                } else {
                  final reportsPendientes = snapshot.data!
                      .where((r) => r.estado.toLowerCase() == 'pendiente')
                      .toList();

                  if (reportsPendientes.isEmpty) {
                    return const Center(child: Text('No hay reportes pendientes'));
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: reportsPendientes.length,
                    itemBuilder: (context, index) {
                      return CardComplaints(reporte: reportsPendientes[index]);
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFiltroBotones() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _FiltroBoton(
            label: 'Alojamientos',
            activo: tipoSeleccionado == 'alojamiento',
            onTap: () => _onTipoChanged('alojamiento'),
          ),
          const SizedBox(width: 12),
          _FiltroBoton(
            label: 'Usuarios',
            activo: tipoSeleccionado == 'usuario',
            onTap: () => _onTipoChanged('usuario'),
          ),
        ],
      ),
    );
  }
}

// ... (El resto de tus clases _FiltroBoton y CardComplaints están bien y se mantienen igual)
class _FiltroBoton extends StatelessWidget {
  final String label;
  final bool activo;
  final VoidCallback onTap;

  const _FiltroBoton({
    required this.label,
    required this.activo,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: activo ? Colors.black : Colors.grey[200],
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: Colors.black),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: activo ? Colors.white : Colors.black,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class CardComplaints extends StatelessWidget {
  final ReporteAdmin reporte;

  const CardComplaints({
    super.key,
    required this.reporte,
  });

  Color _getEstadoColor() {
    switch (reporte.estado.toLowerCase()) {
      case 'pendiente':
        return Colors.orange;
      case 'revisado':
        return Colors.green;
      case 'rechazado':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Color _getEstadoTextColor() {
    switch (reporte.estado.toLowerCase()) {
      case 'pendiente':
        return Colors.orange[800]!;
      case 'revisado':
        return Colors.green[800]!;
      case 'rechazado':
        return Colors.red[800]!;
      default:
        return Colors.grey[700]!;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorFondo = _getEstadoColor().withOpacity(0.15);
    final colorTexto = _getEstadoTextColor();

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetailReport(reportes: reporte),
          ),
        );
      },
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(14.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Nombre del reportante
              Text(
                '${reporte.reportante?.nombre ?? 'Anónimo'} ${reporte.reportante?.apellido ?? ''}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 4),

              // Motivo
              Text(
                'Motivo: ${reporte.motivo}',
                style: const TextStyle(fontSize: 15),
              ),

              const SizedBox(height: 6),

              // Fecha
              Text(
                'Fecha: ${reporte.createdAt}',
                style: TextStyle(color: Colors.grey[700]),
              ),

              const SizedBox(height: 4),

              // Estado del reporte
              Container(
                margin: const EdgeInsets.only(top: 6),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: colorFondo,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  reporte.estado.toUpperCase(),
                  style: TextStyle(
                    color: colorTexto,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}