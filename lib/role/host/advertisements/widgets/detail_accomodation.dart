import 'package:desole_app/data/models/AlojamientosAnfitrion.dart';
import 'package:desole_app/data/models/FotoAlojamientos.dart';
import 'package:flutter/material.dart';
import 'package:desole_app/role/host/advertisements/widgets/edit_accommodations.dart';
import 'package:desole_app/services/accomodation_services.dart';
import 'dart:convert';
import 'package:intl/intl.dart';
class DetailAccomodationScreen extends StatefulWidget {
  final String id;

  const DetailAccomodationScreen({super.key, required this.id});

  @override
  State<DetailAccomodationScreen> createState() => _DetailAccomodationScreenState();
}

class _DetailAccomodationScreenState extends State<DetailAccomodationScreen> {
  AlojamientoAnfitrion? accommodation;
  List<FotosAlojamientos> fotos = [];
  bool isLoading = true;
  PageController _pageController = PageController();
  int _currentPage = 0;

  final AccomodationServices _service = AccomodationServices();

  @override
  void initState() {
    super.initState();
    fetchAlojamientoDetail();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> fetchAlojamientoDetail() async {
    print('🚀 Intentando cargar detalle para id: ${widget.id}');
    try {
      final alojamientoData = await _service.getAccommodationHost(widget.id);
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

 void _confirmarEliminar(BuildContext context, String id) async {
  final confirmacion = await showDialog<bool>(
    context: context,
    barrierDismissible: false, 
    builder: (context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        titlePadding: const EdgeInsets.only(top: 20, left: 24, right: 24),
        contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        title: Column(
          children: const [
            Icon(Icons.delete_forever, size: 48, color: Colors.redAccent),
            SizedBox(height: 12),
            Text(
              '¿Eliminar alojamiento?',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: const Text(
          'Esta acción eliminará el alojamiento de forma permanente. ¿Deseas continuar?',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16, color: Colors.black87),
        ),
        actions: [
          OutlinedButton(
            onPressed: () => Navigator.of(context).pop(false),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Colors.black),
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text(
              'Eliminar',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      );
    },
  );

  if (confirmacion == true) {
    await _eliminarAlojamiento(context, id);
  }
}

  Future<void> _eliminarAlojamiento(BuildContext context, String id) async {
    print('🗑️ Intentando eliminar alojamiento con id: $id');

    try {
      final success = await _service.deleteAccommodation(id);

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Alojamiento eliminado con éxito')),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al eliminar el alojamiento')),
        );
      }
    } catch (e) {
      print('❌ Error al eliminar: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al eliminar: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white.withOpacity(0.9),
        title: Text(
          capitalizar(accommodation!.titulo),
          style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
          ),
        actions: [
          if (accommodation != null)
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'delete') {
                  _confirmarEliminar(context, accommodation!.id);
                }
              },
              icon: const Icon(Icons.more_vert, color: Colors.black87),
              itemBuilder: (BuildContext context) => [
                const PopupMenuItem<String>(
                  value: 'delete',
                  child: Text('Eliminar alojamiento'),
                ),
              ],
            ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : accommodation == null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'No se pudo cargar el alojamiento',
                        style: TextStyle(fontSize: 18),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: fetchAlojamientoDetail,
                        child: const Text('Reintentar'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          textStyle: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                )
              : Stack(
                  children: [
                    // Carrusel de imágenes con sombra y bordes redondeados
                    if (fotos.isNotEmpty)
  SizedBox(
    height: 320,
    child: Stack(
      children: [
        PageView.builder(
          controller: _pageController,
          itemCount: fotos.length,
          onPageChanged: (index) {
            setState(() {
              _currentPage = index;
            });
          },
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Container(
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 8,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Image.network(
                    fotos[index].urlFoto,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) =>
                        loadingProgress == null
                            ? child
                            : const Center(child: CircularProgressIndicator()),
                    errorBuilder: (_, __, ___) =>
                        const Icon(Icons.broken_image, size: 80, color: Colors.grey),
                  ),
                ),
              ),
            );
          },
        ),

        // ⭐ Badge de calificación
        Positioned(
          top: 30,
          right: 30,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.6),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                const Icon(Icons.star, color: Colors.amber, size: 18),
                const SizedBox(width: 4),
                Text(
                  "${accommodation!.calificacionPromedio.toStringAsFixed(1)} / 5.0",
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ),

        // Indicador de página
        Positioned(
          bottom: 20,
          left: 0,
          right: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              fotos.length,
              (index) => AnimatedContainer(
                duration: const Duration(milliseconds: 350),
                margin: const EdgeInsets.symmetric(horizontal: 6),
                width: _currentPage == index ? 16 : 10,
                height: 10,
                decoration: BoxDecoration(
                  color: _currentPage == index
                      ? Colors.white
                      : Colors.white70,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ),
      ],
                        ),
                      ),

                    // Contenido flotante con fondo blanco y bordes redondeados
                    DraggableScrollableSheet(
                      initialChildSize: 0.7,
                      minChildSize: 0.65,
                      maxChildSize: 0.95,
                      builder: (_, controller) => Container(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                          boxShadow: [BoxShadow(blurRadius: 15, color: Colors.black12)],
                        ),
                        child: ListView(
  controller: controller,
  physics: const BouncingScrollPhysics(),
  children: [

    _infoTile(
      icon: Icons.home_outlined,
      title: "Título",
      value: accommodation!.titulo,
    ),
    _infoTile(
      icon: Icons.monetization_on_outlined,
      title: "Precio por noche",
      value: "\$${accommodation!.precioNoche}",
    ),
    _infoTile(
      icon: Icons.star_outline,
      title: "Calificación promedio",
      value: "${accommodation!.calificacionPromedio.toStringAsFixed(1)} / 5.0",
    ),
    
    _infoTile(
      icon: Icons.calendar_today_outlined,
      title: "Creado el",
      value: DateFormat('dd/MM/yyyy').format(accommodation!.createdAt),
    ),

    const SizedBox(height: 28),


                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 18),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  backgroundColor: Colors.black,
                                ),
                                onPressed: () async {
                                  print('🚀 Enviando alojamiento a editar: ${jsonEncode(accommodation!.toJson())}');

                                  final result = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => EditAccommodationScreen(
                                        alojamiento: accommodation!,
                                      ),
                                    ),
                                  );

                                  if (result == true) {
                                    fetchAlojamientoDetail(); // Recarga si hubo edición
                                  }
                                },
                                child: const Text(
                                  'Editar alojamiento',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }
Widget _infoTile({required IconData icon, required String title, required String value}) {
  return Card(
    margin: const EdgeInsets.symmetric(vertical: 8),
    elevation: 2,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 28, color: Colors.black54),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(fontSize: 16, color: Colors.black54)),
                const SizedBox(height: 4),
                Text(value,
                    style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87)),
              ],
            ),
          )
        ],
      ),
    ),
  );
}
}
