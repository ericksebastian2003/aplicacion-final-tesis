import 'package:desole_app/data/models/PagosHuespedes.dart';
import 'package:desole_app/services/pays_services.dart';
import 'package:flutter/material.dart';

class MyPaysScreen extends StatefulWidget {
  const MyPaysScreen({super.key});

  @override
  State<MyPaysScreen> createState() => _MyPaysScreenState();
}

class _MyPaysScreenState extends State<MyPaysScreen> {
  final PaysServices _service = PaysServices();
  late Future<List<PagosHuespedes>> _futuresPays;

  @override
  void initState() {
    super.initState();
    _futuresPays = _service.getPagosByHuesped();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Mis pagos',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        backgroundColor: Colors.transparent,
        centerTitle: true,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: FutureBuilder<List<PagosHuespedes>>(
              future: _futuresPays,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text('Error al cargar la información: ${snapshot.error}'),
                  );
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No has hecho aún un pago.'));
                } else {
                  final pays = snapshot.data!;
                  return ListView.builder(
                    itemCount: pays.length,
                    itemBuilder: (context, index) {
                      final pay = pays[index];
                      return CardPays(pagos: pay);
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
}

class CardPays extends StatelessWidget {
  final PagosHuespedes pagos;

  const CardPays({super.key, required this.pagos});

  String _formatFecha(String fechaIso) {
    final date = DateTime.parse(fechaIso);
    return "${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute}";
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Pago ID: ${pagos.id}',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text('Total pagado: \$${pagos.montoTotal.toStringAsFixed(2)}'),
            Text('Comisión del sistema: \$${pagos.comisionSistema.toStringAsFixed(2)}'),
            Text('Monto recibido por anfitrión: \$${pagos.montoAnfitrion.toStringAsFixed(2)}'),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
