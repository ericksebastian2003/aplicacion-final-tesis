import 'package:desole_app/features/host/advertisements/widgets/edit_accommodations.dart';
import 'package:desole_app/services/accomodation_services.dart';
import 'package:flutter/material.dart';
import '../../../../data/models/Alojamientos.dart';
import 'dart:convert';
class DetailAccomodation extends StatefulWidget {
  final String id;

  const DetailAccomodation({super.key, required this.id});

  @override
  State<DetailAccomodation> createState() => _DetailAccomodationState();
}

class _DetailAccomodationState extends State<DetailAccomodation> {
  Alojamiento? accommodation;
  bool isLoading = true;

  final AccomodationServices _service = AccomodationServices();

  @override
  void initState() {
    super.initState();
    fetchAlojamientoDetail();
  }

  Future<void> fetchAlojamientoDetail() async {
    print('🚀 Intentando cargar detalle para id: ${widget.id}');
    try {
      final alojamientoData = await _service.getAccommodationById(widget.id);
      setState(() {
        accommodation = alojamientoData;
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
      builder: (context) => AlertDialog(
        title: const Text('¿Eliminar alojamiento?'),
        content: const Text('¿Estás seguro de que deseas eliminar este alojamiento?'),
        actions: [
          TextButton(
            child: const Text('Cancelar'),
            onPressed: () => Navigator.of(context).pop(false),
          ),
          TextButton(
            child: const Text('Eliminar'),
            onPressed: () => Navigator.of(context).pop(true),
          ),
        ],
      ),
    );

    if (confirmacion == true) {
      await _eliminarAlojamiento(context, id);
    }
  }

  Future<void> _eliminarAlojamiento(BuildContext context, String id) async {
    print('🗑️ Intentando eliminar alojamiento con id: $id'); // PRINT para debug

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
        title: Text(
          accommodation != null ? capitalizar(accommodation!.titulo) : 'Detalle',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 26,
          ),
        ),
        backgroundColor: Colors.transparent,
        actions: [
          if (accommodation != null)
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'delete') {
                  _confirmarEliminar(context, accommodation!.id);
                }
              },
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
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
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
                          '${accommodation?.direccion ?? ''}, ${accommodation?.ciudad ?? ''}, ${accommodation?.provincia ?? ''}, ${accommodation?.pais ?? ''}',
                          style: const TextStyle(fontSize: 24),
                        ),
                        const SizedBox(height: 24),
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
                              onPressed: () async {
                                if (accommodation == null) return;

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
                                  fetchAlojamientoDetail(); // Recarga al volver si se editó
                                }
                              },
                              child: const Text(
                                'Editar Alojamiento',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),

                      ],
                    ),
                  ),
                ),
    );
  }
}
