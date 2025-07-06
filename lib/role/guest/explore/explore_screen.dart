import 'package:flutter/material.dart';
import 'package:desole_app/services/accomodation_services.dart';
import 'package:desole_app/role/guest/explore/widgets/detail_screen.dart';
import '../../../data/models/Alojamientos.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  final AccomodationServices _service = AccomodationServices();
  late Future<List<Alojamiento>> _futureAccommodations;

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
    _futureAccommodations = _service.getAllAccommodations();
    _futureAccommodations.then((alojamientos) {
      final activos = alojamientos
          .where((a) => a.estadoAlojamiento.toLowerCase() == 'activo')
          .toList();
      setState(() {
        _todosLosAlojamientos = activos;
        _alojamientosFiltrados = activos;
      });
    });
  }

  void _aplicarFiltros() {
    List<Alojamiento> filtrados = _todosLosAlojamientos.where((a) {
      final coincideProvincia = _provinciaSeleccionada == null || a.provincia == _provinciaSeleccionada;
      final coincideTipo = _tipoSeleccionado == null || a.tipoAlojamiento == _tipoSeleccionado;
      final coincidePrecioMin = _precioMin == null || a.precioNoche >= _precioMin!;
      final coincidePrecioMax = _precioMax == null || a.precioNoche <= _precioMax!;
      final coincideCalificacion = _calificacionMinima == null || (a.calificacionPromedio ?? 0) >= _calificacionMinima!;
      return coincideProvincia && coincideTipo && coincidePrecioMin && coincidePrecioMax && coincideCalificacion;
    }).toList();

    setState(() {
      _alojamientosFiltrados = filtrados;
    });
  }

  List<String> get provinciasUnicas =>
      _todosLosAlojamientos.map((a) => a.provincia).toSet().toList()..sort();

  List<String> get tiposUnicos =>
      _todosLosAlojamientos.map((a) => a.tipoAlojamiento).toSet().toList()..sort();

  void _mostrarDialogoProvincia() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        String? seleccionTemporal = _provinciaSeleccionada;

        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Seleccionar provincia", style: TextStyle(fontSize: 18)),
              const SizedBox(height: 10),
              DropdownButton<String>(
                isExpanded: true,
                value: seleccionTemporal,
                hint: const Text("Selecciona una provincia"),
                items: provinciasUnicas.map((provincia) {
                  return DropdownMenuItem<String>(
                    value: provincia,
                    child: Text(provincia),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _provinciaSeleccionada = value;
                    Navigator.pop(context);
                    _aplicarFiltros();
                  });
                },
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () {
                  setState(() {
                    _provinciaSeleccionada = null;
                    Navigator.pop(context);
                    _aplicarFiltros();
                  });
                },
                child: const Text("Quitar filtro"),
              ),
            ],
          ),
        );
      },
    );
  }

  void _mostrarDialogoPrecio() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Rango de precios", style: TextStyle(fontSize: 18)),
              const SizedBox(height: 10),
              TextField(
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Precio mínimo'),
                onChanged: (value) => _precioMin = double.tryParse(value),
              ),
              TextField(
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Precio máximo'),
                onChanged: (value) => _precioMax = double.tryParse(value),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _aplicarFiltros();
                },
                child: const Text("Aplicar"),
              ),
            ],
          ),
        );
      },
    );
  }

  void _mostrarDialogoCalificacion() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Calificación mínima", style: TextStyle(fontSize: 18)),
              const SizedBox(height: 10),
              TextField(
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Mínimo de estrellas'),
                onChanged: (value) => _calificacionMinima = double.tryParse(value),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _aplicarFiltros();
                },
                child: const Text("Aplicar"),
              ),
            ],
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
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  FiltroChip(
                    icono: Icons.location_on,
                    texto: _provinciaSeleccionada ?? "Provincia",
                    activo: _provinciaSeleccionada != null,
                    onTap: _mostrarDialogoProvincia,
                  ),
                  for (var tipo in tiposUnicos)
                    FiltroChip(
                      icono: Icons.home_work,
                      texto: tipo,
                      activo: _tipoSeleccionado == tipo,
                      onTap: () {
                        setState(() {
                          _tipoSeleccionado = (_tipoSeleccionado == tipo) ? null : tipo;
                        });
                      },
                    ),
                  FiltroChip(
                    icono: Icons.price_change,
                    texto: "Precio",
                    activo: _precioMin != null || _precioMax != null,
                    onTap: _mostrarDialogoPrecio,
                  ),
                  FiltroChip(
                    icono: Icons.star,
                    texto: "Calificación",
                    activo: _calificacionMinima != null,
                    onTap: _mostrarDialogoCalificacion,
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton.icon(
                onPressed: _aplicarFiltros,
                icon: const Icon(Icons.filter_alt),
                label: const Text('Aplicar Filtros'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ),
          Expanded(
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
        ],
      ),
    );
  }
}

// CHIP DE FILTRO PERSONALIZADO
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
