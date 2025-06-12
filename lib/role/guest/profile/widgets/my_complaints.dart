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
                        return CardReserves(reportes: reportes[index]);
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

class CardReserves extends StatelessWidget {
  final Reportes reportes;
  const CardReserves({super.key, required this.reportes});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      // Puedes descomentar esto si tienes una pantalla de detalle
      // onTap: () {
      //   Navigator.push(context, MaterialPageRoute(builder: (_) => DetailGuestReservation(reservas: reportes)));
      // },
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Reporte ID: ${reportes.id}',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              Text(reportes.estado),
              const SizedBox(height: 6),
              Text('Fecha: ${reportes.motivo}'),
            ],
          ),
        ),
      ),
    );
  }
}
