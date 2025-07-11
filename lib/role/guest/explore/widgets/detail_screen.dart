import 'package:desole_app/data/models/FotoAlojamientos.dart';
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
  final PageController _pageController = PageController();
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
    try {
      final alojamientoData = await _service.getAccommodation(widget.id);
      final fotosData = await _service.getPhotosAccommodations(widget.id);

      setState(() {
        accommodation = alojamientoData;
        fotos = fotosData;
        isLoading = false;
      });
    } catch (e) {
      print('❌ Error: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  String capitalizar(String texto) {
    return texto
        .split(' ')
        .map((w) => w.isEmpty ? w : w[0].toUpperCase() + w.substring(1).toLowerCase())
        .join(' ');
  }

void _showDialog() {
  final motivosAlojamiento = [
    'Ruido excesivo',
    'Alojamiento engañoso',
    'Suciedad',
    'Mal mantenimiento',
    'Problemas de seguridad',
    'Cancelación injustificada',
    'Otro'
  ];
  final motivosAnfitriones = [
    'Ruido excesivo',
    'Es un estafador',
    'Mal comportamiento',
    'Incumplimiento de normas',
    'Conducta inapropiada',
    'Otro'
  ];

  String tipoSeleccionado = 'alojamiento';
  List<String> motivos = motivosAlojamiento;
  String motivoSeleccionado = motivos[0];
  String motivoEspecifico = '';

  showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder(builder: (context, setState) {
        motivos = tipoSeleccionado == 'alojamiento' ? motivosAlojamiento : motivosAnfitriones;
        if (!motivos.contains(motivoSeleccionado)) motivoSeleccionado = motivos[0];

        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          backgroundColor: Colors.white,
          title: const Text(
            'Denunciar',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22, color: Colors.black),
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('¿Qué deseas reportar?', style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: tipoSeleccionado,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'alojamiento', child: Text('Alojamiento')),
                    DropdownMenuItem(value: 'anfitrión', child: Text('Anfitrión')),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        tipoSeleccionado = value;
                        motivos = value == 'alojamiento' ? motivosAlojamiento : motivosAnfitriones;
                        motivoSeleccionado = motivos[0];
                        motivoEspecifico = '';
                      });
                    }
                  },
                ),
                const SizedBox(height: 20),
                const Text('Motivo', style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                ...motivos.map((motivo) {
                  return RadioListTile<String>(
                    activeColor: Colors.black,
                    title: Text(motivo),
                    value: motivo,
                    groupValue: motivoSeleccionado,
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          motivoSeleccionado = value;
                          if (value != 'Otro') motivoEspecifico = '';
                        });
                      }
                    },
                  );
                }),
                if (motivoSeleccionado == 'Otro') ...[
                  const SizedBox(height: 12),
                  TextField(
                    maxLines: 2,
                    decoration: InputDecoration(
                      hintText: 'Especifica el motivo',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onChanged: (value) => motivoEspecifico = value,
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar', style: TextStyle(color: Colors.black)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () async {
                String motivoFinal = motivoSeleccionado == 'Otro' ? motivoEspecifico.trim() : motivoSeleccionado;
                if (motivoFinal.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Motivo requerido')),
                  );
                  return;
                }

                Navigator.pop(context);

                await ComplaintsServices().createComplaintsForGuest({
                  'tipoReportado': tipoSeleccionado,
                  'idReportado': tipoSeleccionado == 'alojamiento'
                      ? accommodation!.id
                      : accommodation!.anfitrionId,
                  'motivo': motivoFinal,
                });

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('✅ Denuncia enviada')),
                );
              },
              child: const Text(
                'Enviar',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      });
    },
  );
}


  Widget _buildTitle(String text) {
    return Text(
      text,
      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        //backgroundColor: Colors.white.withOpacity(0.9),
        elevation: 0,
        title: Text(
          accommodation != null ? capitalizar(accommodation!.titulo) : 'Detalle',
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.warning_amber_rounded, color: Colors.redAccent),
            tooltip: 'Denunciar',
            onPressed: _showDialog,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : accommodation == null
              ? const Center(child: Text('No se pudo cargar el alojamiento'))
              : Stack(
                  children: [
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
                                    child: Image.network(
                                      fotos[index].urlFoto,
                                      fit: BoxFit.cover,
                                      width: double.infinity,
                                      loadingBuilder: (_, child, progress) =>
                                          progress == null ? child : const Center(child: CircularProgressIndicator()),
                                      errorBuilder: (_, __, ___) =>
                                          const Icon(Icons.broken_image, size: 80, color: Colors.grey),
                                    ),
                                  ),
                                );
                              },
                            ),
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
                                      color: _currentPage == index ? Colors.white : Colors.white70,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
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
                          children: [
                            _buildTitle("Tipo de alojamiento"),
                            const SizedBox(height: 6),
                            Text(capitalizar(accommodation!.tipoAlojamiento), style: const TextStyle(fontSize: 16)),
                            const Divider(height: 32, thickness: 1.2),

                            _buildTitle("Descripción"),
                            const SizedBox(height: 6),
                            Text(accommodation!.descripcion.isNotEmpty ? accommodation!.descripcion : 'Sin descripción', style: const TextStyle(fontSize: 16, height: 1.4)),
                            const Divider(height: 32, thickness: 1.2),

                            _buildTitle("Precio por noche"),
                            const SizedBox(height: 6),
                            Text('\$${accommodation!.precioNoche}', style: const TextStyle(fontSize: 16)),
                            const Divider(height: 32, thickness: 1.2),

                            _buildTitle("Máximo de huéspedes"),
                            const SizedBox(height: 6),
                            Text('${accommodation!.maxHuespedes}', style: const TextStyle(fontSize: 16)),
                            const Divider(height: 32, thickness: 1.2),

                            _buildTitle("Dirección"),
                            const SizedBox(height: 6),
                            Text(
                              '${capitalizar(accommodation!.direccion)}, ${capitalizar(accommodation!.ciudad)}, ${capitalizar(accommodation!.provincia)}, ${capitalizar(accommodation!.pais)}',
                              style: const TextStyle(fontSize: 16, height: 1.4),
                            ),
                            const SizedBox(height: 32),

                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 18),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
}
