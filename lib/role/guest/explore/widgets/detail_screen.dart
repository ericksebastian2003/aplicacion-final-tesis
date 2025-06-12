import 'package:desole_app/data/models/FotoAlojamientos.dart';
import 'package:desole_app/role/guest/explore/widgets/detail_pays.dart';
import 'package:desole_app/role/guest/explore/widgets/reserve_destination.dart';
import 'package:desole_app/services/accomodation_services.dart';
import 'package:flutter/material.dart';
import '../../../../data/models/Alojamientos.dart';

class DetailScreen extends StatefulWidget {
  final String id;

  const DetailScreen({super.key, required this.id});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  Alojamiento? accommodation;
  List<FotosAlojamientos> fotos = [];
  bool isLoading = true;

  final AccomodationServices _service = AccomodationServices();

  void _showDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar la denuncia'),
        content: const Text('¿Deseas denunciar este alojamiento?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            onPressed: () {
              Navigator.pop(context);
              _denunciarAlojamiento();
            },
            child: const Text('Denunciar'),
          ),
        ],
      ),
    );
  }

  void _denunciarAlojamiento() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Denuncia enviada')),
    );
  }

  @override
  void initState() {
    super.initState();
    fetchAlojamientoDetail();
  }

  Future<void> fetchAlojamientoDetail() async {
    print('🚀 Intentando cargar detalle para id: ${widget.id}');
    try {
      final alojamientoData = await _service.getAccommodation(widget.id);
      final fotosData = await _service.getPhotosAccommodations(widget.id);

      setState(() {
        accommodation = alojamientoData;
        fotos = fotosData;
        isLoading = false;
      });
    } catch (e) {
      print('❌ Error al cargar el detalle del alojamiento: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  String capitalizar(String texto) {
    return texto.split(' ').map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
  title: Text(
    accommodation != null ? capitalizar(accommodation!.titulo) : 'Detalle',
    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 26),
  ),
  backgroundColor: Colors.transparent,
  elevation: 0,
  actions: [
    // Botón Reservar (puedes usar un ícono o texto)
    TextButton(
      onPressed: () {
        if (accommodation != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ReserveDestination(
                duenio: accommodation!.anfitrionId,
                alojamientoId: accommodation!.id,
                precioPorNoche: accommodation!.precioNoche,
                maxHuespedes: accommodation!.maxHuespedes,
              ),
            ),
          );
        }
      },
      child: const Text(
        'Reservar',
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
    ),

    // Botón Denunciar (ícono de advertencia)
    IconButton(
      icon: const Icon(Icons.report, color: Colors.redAccent),
      tooltip: 'Denunciar alojamiento',
      onPressed: _showDialog,
    ),
  ],
),

      body: isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 10),
                  Text("Cargando alojamiento..."),
                ],
              ),
            )
          : accommodation == null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('No se pudo cargar el alojamiento'),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: fetchAlojamientoDetail,
                        child: const Text('Reintentar'),
                      ),
                    ],
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.all(16),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (fotos.isNotEmpty) ...[
                          SizedBox(
                            height: 220,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: fotos.length,
                              itemBuilder: (context, index) {
                                final foto = fotos[index];
                                return Padding(
                                  padding: const EdgeInsets.only(right: 8.0),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Image.network(
                                      foto.urlFoto,
                                      width: 300,
                                      height: 200,
                                      fit: BoxFit.cover,
                                      loadingBuilder: (context, child, loadingProgress) {
                                        if (loadingProgress == null) return child;
                                        return const Center(child: CircularProgressIndicator());
                                      },
                                      errorBuilder: (context, error, stackTrace) =>
                                          const Icon(Icons.broken_image, size: 80),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
                        const Text(
                          "Descripción",
                          style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          accommodation?.descripcion ?? 'Sin descripción',
                          style: const TextStyle(fontSize: 24),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          "Tipo de Alojamiento",
                          style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          capitalizar(accommodation?.tipoAlojamiento ?? ''),
                          style: const TextStyle(fontSize: 24),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Precio por noche:',
                          style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '\$${accommodation?.precioNoche ?? '0'}',
                          style: const TextStyle(fontSize: 24),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Máximo de huéspedes:',
                          style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '${accommodation?.maxHuespedes ?? '0'}',
                          style: const TextStyle(fontSize: 24),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Dirección:',
                          style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '${accommodation?.direccion ?? ''}, '
                          '${accommodation?.ciudad ?? ''}, '
                          '${accommodation?.provincia ?? ''}, '
                          '${accommodation?.pais ?? ''}',
                          style: const TextStyle(fontSize: 24),
                        ),
                        const SizedBox(height: 12),

                        // Botón Reservar
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              backgroundColor: Colors.black,
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ReserveDestination(
                                    duenio: accommodation!.anfitrionId,
                                    alojamientoId: accommodation!.id,
                                    precioPorNoche: accommodation!.precioNoche,
                                    maxHuespedes: accommodation!.maxHuespedes,
                                  ),
                                ),
                              );
                            },
                            child: const Text(
                              'Reservar',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 12),

                        
                      ],
                    ),
                  ),
                ),
    );
  }
}
