import 'dart:async';
import 'package:desole_app/data/models/AlojamientosAnfitrion.dart';
import 'package:desole_app/services/accomodation_services.dart';
import 'package:flutter/material.dart';
import 'widgets/detail_accomodation.dart';
import 'widgets/create_accomodation_screen.dart';

class AdvertisementsScreen extends StatefulWidget {
  /*final String nombre;
  final String hostId;

  const AdvertisementsScreen({
    super.key,
    required this.nombre,
    required this.hostId,
  });
*/
  @override
  State<AdvertisementsScreen> createState() => _AdvertisementsScreenState();
}

class _AdvertisementsScreenState extends State<AdvertisementsScreen> {
  final AccomodationServices _service = AccomodationServices();
  late Future<List<AlojamientoAnfitrion>> _futureAccommodations;

 Timer? _refreshTimer;

@override
void initState() {
  super.initState();
  _loadAccommodations();

  _refreshTimer = Timer.periodic(const Duration(seconds: 25), (timer) {
    _loadAccommodations();
  });
}
void _loadAccommodations() {
  setState(() {
    _futureAccommodations = _service.getAllAccommodationsHost();
  });
}

@override
void dispose() {
  _refreshTimer?.cancel();
  super.dispose();
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Anuncios',
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
          /*Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Hola, ${widget.nombre[0].toUpperCase() + widget.nombre.substring(1).toLowerCase()}',
              style: const TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),*/
          Expanded(
            child: FutureBuilder<List<AlojamientoAnfitrion>>(
              future: _futureAccommodations,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error al cargar la información: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No hay alojamientos disponibles.'));
                } else {
                  final accommodations = snapshot.data!;
                  return ListView.builder(
                    itemCount: accommodations.length,
                    itemBuilder: (context, index) {
                      final accommodation = accommodations[index];
                      return CardAccomodations(destino: accommodation);
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final bool? created = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CreateAccomadationScreen(),
            ),
          );

          if (created == true) {
            setState(() {
              _futureAccommodations = _service.getAllAccommodationsHost();
            });
          }
        },
        backgroundColor: Colors.white70,
        child: const Icon(Icons.add , color: Color(0xFF070133)),
      ),
    );
  }
}
class CardAccomodations extends StatefulWidget {
  final AlojamientoAnfitrion destino;

  const CardAccomodations({super.key, required this.destino});

  @override
  State<CardAccomodations> createState() => _CardAccomodationsState();
}

class _CardAccomodationsState extends State<CardAccomodations> {
  final AccomodationServices _service = AccomodationServices();
  String? _firstImageUrl;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFirstImage();
  }

  Future<void> _loadFirstImage() async {
    try {
      final fotos = await _service.getPhotosAccommodations(widget.destino.id);
      if (fotos.isNotEmpty) {
        final fotoPrincipal = fotos.firstWhere(
          (foto) => foto.fotoPrincipal == true,
          orElse: () => fotos.first,
        );
        setState(() {
          _firstImageUrl = fotoPrincipal.urlFoto;
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error al cargar imagen: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => DetailAccomodationScreen(id: widget.destino.id)),
        );
      },
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 4,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _isLoading
                ? const SizedBox(
                    height: 200,
                    child: Center(child: CircularProgressIndicator()),
                  )
                : Stack(
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                        child: _firstImageUrl != null
                            ? FadeInImage.assetNetwork(
                                placeholder: 'assets/placeholder.jpg', // recuerda tener la imagen en assets
                                image: _firstImageUrl!,
                                height: 200,
                                width: double.infinity,
                                fit: BoxFit.cover,
                                fadeInDuration: const Duration(milliseconds: 300),
                              )
                            : Container(
                                height: 200,
                                color: Colors.grey[300],
                                child: const Center(child: Text('Sin imagen')),
                              ),
                      ),
                      // Caja para la calificación sobre la imagen, esquina superior derecha
                      Positioned(
                        top: 12,
                        right: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.4),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.star, color: Colors.yellowAccent, size: 18),
                              const SizedBox(width: 4),
                              Text(
                                widget.destino.calificacionPromedio.toStringAsFixed(1),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                widget.destino.titulo,
                style: const TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
