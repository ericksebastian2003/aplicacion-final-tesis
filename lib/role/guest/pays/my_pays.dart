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
  String? _mensaje;
  bool _esExito = true;

  @override
  void initState() {
    super.initState();
    _futuresPays = _cargarPagos();
  }

  Future<List<PagosHuespedes>> _cargarPagos() async {
    try {
      final pagos = await _service.getPagosByHuesped();
      if (pagos.isEmpty) {
        _mostrarMensaje("No se encontraron pagos.", false);
      } 
      return pagos;
    } catch (e) {
      return [];
    }
  }

  void _mostrarMensaje(String mensaje, bool exito) {
    setState(() {
      _mensaje = mensaje;
      _esExito = exito;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        title: const Text(
          'Mis pagos',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.white,
        centerTitle: true,
        elevation: 1,
      ),
      body: Column(
        children: [
          Expanded(
            child: FutureBuilder<List<PagosHuespedes>>(
              future: _futuresPays,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text('Error: ${snapshot.error}'),
                  );
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Text(
                      'No has hecho aún un pago.',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  );
                } else {
                  final pays = snapshot.data!;
                  return ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: pays.length,
                    itemBuilder: (context, index) {
                      return CardPays(pagos: pays[index]);
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

  String _formatFecha(String fechaStr) {
    try {
      final fecha = DateTime.parse(fechaStr);
      return "${fecha.day.toString().padLeft(2, '0')}/${fecha.month.toString().padLeft(2, '0')}/${fecha.year}";
    } catch (e) {
      return "Fecha inválida";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 3,
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Encabezado con ícono y ID
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Icon(Icons.payment, color: Colors.black87),
                Text(
                  'ID: ${pagos.id.substring(0, 8)}...',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Título del alojamiento
            Row(
              children: [
                const Icon(Icons.home, color: Colors.black87),
                const SizedBox(width: 8),
                Text(pagos.alojamientoTitulo),
              ],
            ),
            const SizedBox(height: 6),

            // Ciudad
            Row(
              children: [
                const Icon(Icons.location_city, color: Colors.black87),
                const SizedBox(width: 8),
                Text(pagos.ciudad),
              ],
            ),
            const SizedBox(height: 6),

            // Fechas de reserva
            Row(
              children: [
                const Icon(Icons.calendar_month, color: Colors.black87),
                const SizedBox(width: 8),
                Text(
                  'Check-in: ${_formatFecha(pagos.fechaCheckIn)}',
                  style: const TextStyle(color: Colors.black87),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(Icons.calendar_month, color: Colors.black87),
                const SizedBox(width: 8),
                Text(
                 ' Check-out: ${_formatFecha(pagos.fechaCheckOut)}',
                  style: const TextStyle(color: Colors.black87),
                ),
              ],
            ),
            const SizedBox(height: 6),

            // Monto total
            Row(
              children: [
                const Icon(Icons.attach_money, color: Colors.black87),
                const SizedBox(width: 8),
                Text('Total pagado: \$${pagos.montoTotal.toStringAsFixed(2)}'),
              ],
            ),
            const SizedBox(height: 12),

            // Fecha de pago
            Row(
              children: [
                const Icon(Icons.calendar_today, color: Colors.black87),
                const SizedBox(width: 8),
                Text(
                  'Fecha de pago: ${_formatFecha(pagos.createdAt)}',
                  style: const TextStyle(color: Colors.black87),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
