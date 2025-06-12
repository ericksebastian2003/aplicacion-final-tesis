import 'package:desole_app/data/models/Pagos.dart';
import 'package:desole_app/role/guest/explore/widgets/detail_screen.dart';
import 'package:desole_app/services/accomodation_services.dart';
import 'package:desole_app/services/pays_services.dart';
import 'package:flutter/material.dart';


class MyPaysScreen extends StatefulWidget{

  const MyPaysScreen({super.key});

    @override
  State<MyPaysScreen> createState() => _MyPaysScreenState();
}

class _MyPaysScreenState extends State<MyPaysScreen> {

   final PaysServices _service = PaysServices();
  late Future<List<Pagos>> _futuresPays;

  @override
  void initState() {
    super.initState();
    _futuresPays = _service.getPagosComoHuesped();
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
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
        
          Expanded(
            child: FutureBuilder<List<Pagos>>(
              future: _futuresPays,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error al cargar la información: ${snapshot.error}'));
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

class CardPays extends StatefulWidget {
  final Pagos pagos;

  const CardPays({super.key, required this.pagos});

  @override
  State<CardPays> createState() => _CardPaysState();
}

class _CardPaysState extends State<CardPays> {

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      /*onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => DetailScreen(id: widget.destino.id)),
        );
      },
      */
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 4,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.pagos.id,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 28),
                  ),
                  const SizedBox(height: 8),
  
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
