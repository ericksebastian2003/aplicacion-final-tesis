import 'package:desole_app/services/accomodation_services.dart';
import 'package:flutter/material.dart';
import 'package:desole_app/data/models/Alojamientos.dart';
import './widgets/detail_accomodation.dart';
import './widgets/create_accomodation_screen.dart';

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
  late Future<List<Alojamiento>> _futureAccommodations;

  @override
  void initState() {
    super.initState();
    _futureAccommodations = _service.getAccommodations();
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
            child: FutureBuilder<List<Alojamiento>>(
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
              _futureAccommodations = _service.getAccommodations();
            });
          }
        },
        backgroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class CardAccomodations extends StatefulWidget {
  final Alojamiento destino;

  const CardAccomodations({
    super.key,
    required this.destino,
  });@override
  State<CardAccomodations> createState() => _CardAccomodationsState();
}
class _CardAccomodationsState extends State<CardAccomodations>{
  final AccomodationServices _services = AccomodationServices();
  String? _firstImageUrl;
  bool _isLoading = true;
  @override 
  void initState(){
    super.initState();
    _loadFirstImage();
  }
  Future<void> _loadFirstImage() async{
    try{
      final photos = await _services.getPhotosAccomadations(widget.destino.id);
      if(photos.isNotEmpty){
        final firstPhoto = photos.firstWhere(
          (photo) => photo.firstPhoto == true,
          orElse: () => photos.first,
        );
        setState(() {
          _firstImageUrl = firstPhoto.urlFoto;
          _isLoading = false;
        });
      }
      else{
        setState(() {
          _isLoading = false;
        });
      }

    }
    catch(e){
      print('Error al cargar la img $e');
      setState(() {
        _isLoading = false;
      });
    }
  }
  @override
  Widget build(BuildContext context) {
  final destino = widget.destino;

return InkWell(
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetailAccomodation(id: widget.destino.id),
      ),
    );
  },
  child: Card(
    margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    elevation: 2,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _isLoading
            ? const SizedBox(
                height: 200,
                child: Center(child: CircularProgressIndicator()),
              )
            : _firstImageUrl != null
                ? ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                    child: Image.network(
                      _firstImageUrl!,
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  )
                : const SizedBox(
                    height: 200,
                    child: Center(child: Text('Sin imagen')),
                  ),
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                destino.titulo.toUpperCase(),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              const SizedBox(height: 8),
              Text('Tipo: ${destino.tipoAlojamiento}'),
              Text('Precio por noche: \$${destino.precioNoche}'),
              Text('Ubicación: ${destino.ciudad}, ${destino.provincia}, ${destino.pais}'),
              Text('Dirección: ${destino.direccion}'),
            ],
          ),
        ),
      ],
    ),
  ),
);

  }
}
