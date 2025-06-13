import 'package:desole_app/data/models/Reportes.dart';
import 'package:desole_app/services/complaints_services.dart';
import 'package:flutter/material.dart';

class ReportesGuestScreen extends StatefulWidget {
  const ReportesGuestScreen({super.key});

  @override
  State<ReportesGuestScreen> createState() => _ReportesGuestScreenState();
}

class _ReportesGuestScreenState extends State<ReportesGuestScreen> {
  late Future<List<Reportes>> _futureReportes;

  @override
  void initState() {
    super.initState();
    _futureReportes = fetchReportes();
  }

  Future<List<Reportes>> fetchReportes() async {
  print("🚀 Iniciando fetchReportes...");
  await Future.delayed(const Duration(seconds: 2));
  final service = ComplaintsServices();
  final reportes = await service.getComplaintsForGuest();
  print("✅ Reportes obtenidos: ${reportes.length}");
  return reportes;
}



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis reportes'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Expanded(
              child: FutureBuilder<List<Reportes>>(
                future: _futureReportes,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('No has hecho reportes aún'));
                  } else {
                    final reportes = snapshot.data!;
                    return ListView.builder(
                      itemCount: reportes.length,
                      itemBuilder: (context, index) {
                        return CardComplaints(reporte: reportes[index]);
                      },
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CardComplaints extends StatelessWidget {
  final Reportes reporte;

  const CardComplaints({
    super.key,
    required this.reporte,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      /*onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
            Detail(reportes: reporte),
          ),
        );
      },*/
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
                Text('Id del reporte :${reporte.id}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 4),

              // Motivo
              Text(
                '📌 Motivo: ${reporte.motivo}',
                style: TextStyle(fontSize: 15),
              ),

              const SizedBox(height: 6),

              // Estado del reporte
              Container(
                margin: const EdgeInsets.only(top: 6),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: reporte.estado == 'pendiente'
                      ? Colors.orange[100]
                      : Colors.green[100],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  reporte.estado.toUpperCase(),
                  style: TextStyle(
                    color: reporte.estado == 'pendiente'
                        ? Colors.orange[800]
                        : Colors.green[800],
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
