import 'package:desole_app/role/guest/explore/widgets/detail_screen.dart';
import 'package:desole_app/services/accomodation_services.dart';
import 'package:flutter/material.dart';

import '../../../data/models/Alojamientos.dart';

class ExploreScreen extends StatefulWidget{

  const ExploreScreen({super.key});

    @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {

   final AccomodationServices _service = AccomodationServices();
  late Future<List<Alojamiento>> _futureAccommodations;

  @override
  void initState() {
    super.initState();
    _futureAccommodations = _service.getAllAccommodations();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Explorar',
          style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
    
    );
  }
}

class CardAccomodations extends StatefulWidget {
  final Alojamiento destino;

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
        // Puedes mostrar la que tiene fotoPrincipal == true, o simplemente la primera
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
          MaterialPageRoute(builder: (context) => DetailScreen(id: widget.destino.id)),
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
                : _firstImageUrl != null
                    ? ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                      child: FadeInImage.assetNetwork(
                        placeholder: 'assets/placeholder.jpg', // asegúrate de tener esta imagen en assets
                        image: _firstImageUrl!,
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        fadeInDuration: const Duration(milliseconds: 300),
                      ),
                    )

                    : const SizedBox(
                        height: 200,
                        child: Center(child: Text('Este alojamiento no tiene imagenes')),
                      ),
            Padding(
  padding: const EdgeInsets.all(16),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        widget.destino.titulo,
        style: const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w700,
        ),
      ),
      const SizedBox(height: 8),
      Row(
        children: [
          const Icon(Icons.home_work_outlined, size: 18, color: Colors.grey),
          const SizedBox(width: 6),
          Text(widget.destino.tipoAlojamiento),
        ],
      ),
      const SizedBox(height: 6),
      Row(
        children: [
          const Icon(Icons.attach_money, size: 18, color: Colors.grey),
          const SizedBox(width: 6),
          Text('Precio por noche: \$${widget.destino.precioNoche.toStringAsFixed(2)}'),
        ],
      ),
      const SizedBox(height: 6),
      Row(
        children: [
          const Icon(Icons.location_on_outlined, size: 18, color: Colors.grey),
          const SizedBox(width: 6),
          Expanded(
            child: Text('${widget.destino.ciudad}, ${widget.destino.provincia}, ${widget.destino.pais}'),
          ),
        ],
      ),
      const SizedBox(height: 6),
      Row(
        children: [
          const Icon(Icons.map_outlined, size: 18, color: Colors.grey),
          const SizedBox(width: 6),
          Expanded(child: Text(widget.destino.direccion)),
        ],
      ),
    ],
  ),
),

          ],
        ),
      ),
    );
  }
}
