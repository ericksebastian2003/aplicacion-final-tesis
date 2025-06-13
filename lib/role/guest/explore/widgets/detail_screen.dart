import 'package:desole_app/data/models/FotoAlojamientos.dart';
import 'package:desole_app/role/guest/explore/widgets/detail_pays.dart';
import 'package:desole_app/role/guest/explore/widgets/reserve_destination.dart';
import 'package:desole_app/services/accomodation_services.dart';
import 'package:desole_app/services/complaints_services.dart';
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
  PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  final AccomodationServices _service = AccomodationServices();

 void _showDialog() {
  // Lista de motivos
  final List<String> motivosAlojamiento = [
    'Ruido excesivo',
    'Alojamiento engañoso',
    'Suciedad',
    'Mal mantenimiento',
    'Problemas de seguridad',
    'Cancelación injustificada',
    'Otro',
  ];
    // Lista de motivos
  final List<String> motivosUsuario = [
    'Ruido excesivo',
    'Es un estafador',
    'Mal comportamiento',
    'Incumplimento de las normas',
    'Conducta inapropiada',
    'Otro',
  ];

    String tipoSeleccionado = 'alojamiento'; // valor por defecto
  List<String> motivos = motivosAlojamiento; // motivos actuales según tipo seleccionado
  String motivoSeleccionado = motivos[0]; // motivo por defecto
  String motivoEspecifico = '';

  showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          // Actualizar la lista de motivos si cambia el tipo
          motivos = tipoSeleccionado == 'alojamiento' ? motivosAlojamiento : motivosUsuario;

          // Si el motivoSeleccionado no está en la lista actual (cambio de tipo), resetearlo
          if (!motivos.contains(motivoSeleccionado)) {
            motivoSeleccionado = motivos[0];
          }

          return AlertDialog(
            title: const Text('Denunciar'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Selecciona el tipo de denuncia:'),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: tipoSeleccionado,
                    items: const [
                      DropdownMenuItem(value: 'alojamiento', child: Text('Alojamiento')),
                      DropdownMenuItem(value: 'usuario', child: Text('Usuario')),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          tipoSeleccionado = value;
                          motivos = tipoSeleccionado == 'alojamiento' ? motivosAlojamiento : motivosUsuario;
                          motivoSeleccionado = motivos[0];
                          motivoEspecifico = '';
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                  const Text('Selecciona el motivo de la denuncia:'),
                  ...motivos.map((motivo) {
                    return RadioListTile<String>(
                      title: Text(motivo),
                      value: motivo,
                      groupValue: motivoSeleccionado,
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            motivoSeleccionado = value;
                            if (value != 'Otro') {
                              motivoEspecifico = '';
                            }
                          });
                        }
                      },
                    );
                  }).toList(),
                  if (motivoSeleccionado == 'Otro') ...[
                    const SizedBox(height: 12),
                    TextField(
                      decoration: const InputDecoration(
                        labelText: 'Especifique el motivo',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) {
                        motivoEspecifico = value;
                      },
                    ),
                  ],
                ],
              ),
            ),
            actions: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.white ,foregroundColor: Colors.red),
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancelar')
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red ,foregroundColor: Colors.white),
                onPressed: () async {
                  String motivoFinal = motivoSeleccionado;
                  if (motivoSeleccionado == 'Otro' && motivoEspecifico.trim().isNotEmpty) {
                    motivoFinal = motivoEspecifico.trim();
                  }
                  if (motivoFinal.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Por favor, selecciona o especifica un motivo')),
                    );
                    return;
                  }

                  Navigator.pop(context);

                  final data = {
                    'tipoReportado': tipoSeleccionado,
                    'idReportado': tipoSeleccionado == 'alojamiento' ? accommodation!.id : accommodation!.anfitrionId,
                    'motivo': motivoFinal,
                  };

                  await ComplaintsServices().createComplaintsForGuest(data);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Denuncia enviada')),
                  );
                },
                child: const Text('Enviar denuncia'),
              ),
],
          );
        },
      );
    },
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
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          accommodation != null ? capitalizar(accommodation!.titulo) : 'Detalle del alojamiento',
          style: const TextStyle(
            color: Colors.black,
            fontSize: 26, 
            fontWeight: FontWeight.bold
            //shadows: [Shadow(blurRadius: 6, color: Colors.black)],
          ),
        ),
        actions: [
          IconButton(
            onPressed: _showDialog,
            icon: const Icon(
              Icons.warning_amber_rounded,
              color: Colors.redAccent,
              size: 30,
              shadows: [Shadow(blurRadius: 8, color: Colors.black45)],
            ),
            tooltip: 'Denunciar alojamiento',
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
                      const Text('No se pudo cargar el alojamiento'),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: fetchAlojamientoDetail,
                        child: const Text('Reintentar'),
                      ),
                    ],
                  ),
                )
              : Stack(
                  children: [
                    // Carrusel de imágenes
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
                                return ClipRRect(
                                  borderRadius: const BorderRadius.only(
                                    bottomLeft: Radius.circular(30),
                                    bottomRight: Radius.circular(30),
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
                                        const Icon(Icons.broken_image, size: 80),
                                  ),
                                );
                              },
                            ),
                            // Indicador de páginas
                            Positioned(
                              bottom: 16,
                              left: 0,
                              right: 0,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: List.generate(
                                  fotos.length,
                                  (index) => AnimatedContainer(
                                    duration: const Duration(milliseconds: 300),
                                    margin: const EdgeInsets.symmetric(horizontal: 4),
                                    width: _currentPage == index ? 12 : 8,
                                    height: 8,
                                    decoration: BoxDecoration(
                                      color: _currentPage == index
                                          ? Colors.white
                                          : Colors.white.withOpacity(0.5),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                    // Contenido flotante
                    DraggableScrollableSheet(
                      initialChildSize: 0.65,
                      minChildSize: 0.65,
                      maxChildSize: 0.95,
                      builder: (_, controller) => Container(
                        padding: const EdgeInsets.all(16),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                          boxShadow: [BoxShadow(blurRadius: 10, color: Colors.black12)],
                        ),
                        child: ListView(
                          controller: controller,
                          children: [
                            _buildTitle("Tipo de Alojamiento"),
                            Text(capitalizar(accommodation?.tipoAlojamiento ?? '')),
                            const SizedBox(height: 16),
                            _buildTitle("Descripción"),
                            Text(accommodation?.descripcion ?? 'Sin descripción'),
                            const SizedBox(height: 16),
                            _buildTitle("Precio por noche"),
                            Text("\$${accommodation?.precioNoche ?? '0'}"),
                            const SizedBox(height: 16),
                            _buildTitle("Máximo de huéspedes"),
                            Text("${accommodation?.maxHuespedes ?? '0'}"),
                            const SizedBox(height: 16),
                            _buildTitle("Dirección"),
                            Text(
                              '${accommodation?.direccion ?? ''}, '
                              '${accommodation?.ciudad ?? ''}, '
                              '${accommodation?.provincia ?? ''}, '
                              '${accommodation?.pais ?? ''}',
                            ),
                            const SizedBox(height: 24),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  backgroundColor: Colors.black,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
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
                                  'Reservar ahora',
                                  style: TextStyle(fontSize: 18, color: Colors.white),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }

  Widget _buildTitle(String text) {
    return Text(
      text,
      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
    );
  }
}