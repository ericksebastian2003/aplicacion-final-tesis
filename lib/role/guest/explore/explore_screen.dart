// ... tus imports
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:desole_app/services/accomodation_services.dart';
import 'package:desole_app/role/guest/explore/widgets/detail_screen.dart';
import '../../../data/models/Alojamientos.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> with SingleTickerProviderStateMixin {
  final AccomodationServices _service = AccomodationServices();
  late Future<List<Alojamiento>> _futureAccommodations;
  late AnimationController _animationController;

  List<Alojamiento> _todosLosAlojamientos = [];
  List<Alojamiento> _alojamientosFiltrados = [];

  String? _provinciaSeleccionada;
  String? _tipoSeleccionado;
  double? _precioMin;
  double? _precioMax;
  double? _calificacionMinima;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _futureAccommodations = _service.getAllAccommodations();
    _futureAccommodations.then((alojamientos) {
      final activos = alojamientos
          .where((a) => a.estadoAlojamiento.toLowerCase() == 'activo')
          .toList();
      setState(() {
        _todosLosAlojamientos = activos;
        _alojamientosFiltrados = activos;
        _animationController.forward();
      });
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _aplicarFiltros() async {
  try {
    print('Enviando filtros:');
    print('Provincia: $_provinciaSeleccionada');
    print('Tipo de alojamiento: $_tipoSeleccionado');
    print('Precio mínimo: $_precioMin');
    print('Precio máximo: $_precioMax');
    print('Calificación mínima: $_calificacionMinima');

    final filtrados = await _service.getAccommodationsFiltered(
      provincia: _provinciaSeleccionada,
      tipoAlojamiento: _tipoSeleccionado,
      precioMin: _precioMin,
      precioMax: _precioMax,
      calificacion: _calificacionMinima,
    );

   

    setState(() {
      _alojamientosFiltrados = filtrados;
      _animationController.forward(from: 0);
    });
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('No se encontró resultados con los filtros seleccionados')),
    );
  }
}


  List<String> get provinciasUnicas =>
      _todosLosAlojamientos.map((a) => a.provincia).toSet().toList()..sort();

  List<String> get tiposUnicos =>
      _todosLosAlojamientos.map((a) => a.tipoAlojamiento).toSet().toList()..sort();

void _mostrarFiltrosCompletos() {
  final TextEditingController minPrecioController = TextEditingController(
    text: _precioMin?.toStringAsFixed(0) ?? '',
  );
  final TextEditingController maxPrecioController = TextEditingController(
    text: _precioMax?.toStringAsFixed(0) ?? '',
  );

  double tempCalificacion = _calificacionMinima ?? 0;

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
    ),
    builder: (context) {
      return Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        child: StatefulBuilder(
          builder: (context, setModalState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Center(
                  child: Text("Filtros de búsqueda", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 20),

                // Provincia
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: "Provincia",
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  value: _provinciaSeleccionada,
                  isExpanded: true,
                  items: provinciasUnicas.map((p) => DropdownMenuItem(value: p, child: Text(p))).toList(),
                  onChanged: (val) => setModalState(() => _provinciaSeleccionada = val),
                ),

                const SizedBox(height: 16),

                // Tipo alojamiento
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: "Tipo de alojamiento",
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  value: _tipoSeleccionado,
                  isExpanded: true,
                  items: tiposUnicos.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                  onChanged: (val) => setModalState(() => _tipoSeleccionado = val),
                ),

                const SizedBox(height: 20),

                const Text("Precio por noche"),
                const SizedBox(height: 6),

                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: minPrecioController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        decoration: const InputDecoration(
                          labelText: "Mínimo",
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.attach_money),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: maxPrecioController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        decoration: const InputDecoration(
                          labelText: "Máximo",
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.attach_money),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),
                const Text("Calificación mínima"),
                Slider(
                  value: tempCalificacion,
                  min: 0,
                  max: 5,
                  divisions: 5,
                  label: '${tempCalificacion.toStringAsFixed(1)} ★',
                  activeColor: Colors.amber,
                  onChanged: (value) => setModalState(() => tempCalificacion = value),
                ),

                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          setState(() {
                            _provinciaSeleccionada = null;
                            _tipoSeleccionado = null;
                            _precioMin = null;
                            _precioMax = null;
                            _calificacionMinima = null;
                            Navigator.pop(context);
                            _aplicarFiltros();
                          });
                        },
                        child: const Text("Limpiar Filtros" ,style: TextStyle(color: Colors.black),),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: () {
                          setState(() {
                            _precioMin = double.tryParse(minPrecioController.text);
                            _precioMax = double.tryParse(maxPrecioController.text);
                            _calificacionMinima = tempCalificacion;
                            Navigator.pop(context);
                            _aplicarFiltros();
                          });
                        },
                        child: const Text("Aplicar Filtros"),
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      );
    },
  );
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Explorar', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton.icon(
                onPressed: _mostrarFiltrosCompletos,
                icon: const Icon(Icons.tune),
                label: const Text('Filtros'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ),
          Expanded(
            child: FadeTransition(
              opacity: _animationController,
              child: _alojamientosFiltrados.isEmpty
                  ? const Center(child: Text('No hay alojamientos que coincidan con los filtros.'))
                  : ListView.builder(
                      itemCount: _alojamientosFiltrados.length,
                      itemBuilder: (context, index) {
                        final alojamiento = _alojamientosFiltrados[index];
                        return CardAccomodations(destino: alojamiento);
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }
}



/*
class FiltroChip extends StatelessWidget {
  final IconData icono;
  final String texto;
  final bool activo;
  final VoidCallback onTap;

  const FiltroChip({
    super.key,
    required this.icono,
    required this.texto,
    required this.activo,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        margin: const EdgeInsets.only(right: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: activo ? Colors.deepPurple : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: activo ? Colors.deepPurple : Colors.grey.shade400,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Icon(icono, size: 18, color: activo ? Colors.white : Colors.black54),
            const SizedBox(width: 6),
            Text(
              texto,
              style: TextStyle(
                color: activo ? Colors.white : Colors.black87,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
*/
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
        final fotoPrincipal = fotos.firstWhere(
          (foto) => foto.fotoPrincipal == true,
          orElse: () => fotos.first,
        );
        setState(() {
          _firstImageUrl = fotoPrincipal.urlFoto;
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      print('Error al cargar imagen: $e');
      setState(() => _isLoading = false);
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
        margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 4,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagen
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: _isLoading
                  ? const SizedBox(
                      height: 200,
                      child: Center(child: CircularProgressIndicator()),
                    )
                  : _firstImageUrl != null
                      ? Stack(
                          children: [
                            Image.network(
                              _firstImageUrl!,
                              height: 200,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                            if (widget.destino.calificacionPromedio != null)
                              Positioned(
                                top: 10,
                                right: 10,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.7),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.star, color: Colors.amber, size: 16),
                                      const SizedBox(width: 4),
                                      Text(
                                        widget.destino.calificacionPromedio!.toStringAsFixed(1),
                                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                          ],
                        )
                      : const SizedBox(
                          height: 200,
                          child: Center(child: Text('No hay imágenes disponibles')),
                        ),
            ),

            // Contenido
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.destino.titulo,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${widget.destino.ciudad}, ${widget.destino.provincia}',
                    style: TextStyle(color: Colors.grey.shade700),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.attach_money, size: 18, color: Colors.deepPurple),
                      const SizedBox(width: 4),
                      Text(
                        '${widget.destino.precioNoche.toStringAsFixed(2)} / noche',
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.home_outlined, size: 18, color: Colors.deepPurple),
                      const SizedBox(width: 4),
                      Text(widget.destino.tipoAlojamiento),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined, size: 18, color: Colors.deepPurple),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          widget.destino.direccion,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: Colors.black87),
                        ),
                      ),
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
