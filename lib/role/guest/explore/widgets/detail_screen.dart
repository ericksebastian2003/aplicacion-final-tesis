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
  final ComplaintsServices _complaintsService = ComplaintsServices();

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
    if (texto.isEmpty) return '';
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
                      DropdownMenuItem(value: 'usuario', child: Text('Anfitrión')),
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
                    _showSnackBar('Motivo requerido', true);
                    return;
                  }

                  Navigator.pop(context);

                  final String idReportado = tipoSeleccionado == 'alojamiento'
                      ? accommodation!.id
                      : accommodation!.anfitrion.id;

                  final String? mensajeRespuesta = await _complaintsService.createComplaintsForGuest({
                    'tipoReportado': tipoSeleccionado,
                    'idReportado': idReportado,
                    'motivo': motivoFinal,
                  });

                  if (mensajeRespuesta != null) {
                    if (mensajeRespuesta.contains('Error') || mensajeRespuesta.contains('no puede')) {
                      _showSnackBar(mensajeRespuesta, true);
                    } else {
                      _showSnackBar('✅ $mensajeRespuesta', false);
                    }
                  } else {
                    _showSnackBar('❌ No se pudo completar la solicitud. Intente de nuevo más tarde.', true);
                  }
                },
                child: const Text(
                  'Enviar reporte',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          );
        });
      },
    );
  }

  void _showSnackBar(String mensaje, bool isError) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        content: _buildMensaje(mensaje, isError),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Widget _buildMensaje(String mensaje, bool isError) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 8,
            offset: Offset(0, 3),
          )
        ],
      ),
      constraints: const BoxConstraints(minWidth: 200),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isError ? Icons.error_outline : Icons.check_circle_outline,
            color: isError ? Colors.red.shade700 : Colors.black87,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              mensaje,
              style: const TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({required IconData icon, required String label, required String value}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.black87),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 14, color: Colors.black54)),
                const SizedBox(height: 2),
                Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
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
                            const SizedBox(height: 12),
                            Center(
                              child: Container(
                                width: 40,
                                height: 5,
                                decoration: BoxDecoration(
                                  color: Colors.grey[400],
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            _buildInfoCard(
                              icon: Icons.apartment,
                              label: 'Tipo de alojamiento',
                              value: capitalizar(accommodation!.tipoAlojamiento ?? ''),
                            ),
                            _buildInfoCard(
                              icon: Icons.attach_money,
                              label: 'Precio por noche',
                              value: '\$${accommodation!.precioNoche.toStringAsFixed(2)}',
                            ),
                            _buildInfoCard(
                              icon: Icons.star_border,
                              label: 'Calificación promedio',
                              value: accommodation!.calificacionPromedio.toStringAsFixed(1),
                            ),
                            _buildInfoCard(
                              icon: Icons.location_on_outlined,
                              label: 'Ubicación',
                              value: '${capitalizar(accommodation!.ciudad)}, ${capitalizar(accommodation!.provincia)}',
                            ),
                            _buildInfoCard(
                              icon: Icons.person_outline,
                              label: 'Anfitrión',
                              value: capitalizar(accommodation!.anfitrion.nombre),
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
                                        duenio: accommodation!.anfitrion.nombre,
                                        alojamientoId: accommodation!.id,
                                        precioPorNoche: accommodation!.precioNoche.toInt(),
                                        maxHuespedes:4,
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