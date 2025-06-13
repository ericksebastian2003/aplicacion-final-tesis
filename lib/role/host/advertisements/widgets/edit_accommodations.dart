import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:desole_app/data/models/Alojamientos.dart';
import 'package:desole_app/data/models/FotoAlojamientos.dart';
import 'package:desole_app/services/accomodation_services.dart';

class EditAccommodationScreen extends StatefulWidget {
  final Alojamiento alojamiento;

  const EditAccommodationScreen({super.key, required this.alojamiento});

  @override
  State<EditAccommodationScreen> createState() => _EditAccommodationScreenState();
}

class _EditAccommodationScreenState extends State<EditAccommodationScreen> {
  final _service = AccomodationServices();
  final ImagePicker _picker = ImagePicker();

  late TextEditingController tituloController;
  late TextEditingController descripcionController;
  late TextEditingController tipoController;
  late TextEditingController precioController;
  late TextEditingController huespedesController;
  late TextEditingController direccionController;
  late TextEditingController anfitrionController;

  late String paisSeleccionado;
  late String provinciaSeleccionada;
  late String ciudadSeleccionada;

  final List<String> paises = ['Ecuador'];

  final Map<String, List<String>> provinciasYCiudades = {
    'Azuay': ['Cuenca', 'Gualaceo', 'Paute', 'Sígsig', 'Chordeleg'],
    'Bolívar': ['Guaranda', 'Chillanes', 'Chimbo', 'Echeandía', 'Caluma'],
    'Cañar': ['Azogues', 'Biblián', 'Déleg', 'Suscal', 'La Troncal'],
    'Carchi': ['Tulcán', 'Bolívar', 'Espejo', 'Mira', 'Montúfar'],
    'Chimborazo': ['Riobamba', 'Guamote', 'Guano', 'Penipe', 'Colta'],
    'Cotopaxi': ['Latacunga', 'La Maná', 'Pangua', 'Salcedo', 'Sigchos'],
    'El Oro': ['Machala', 'Pasaje', 'Santa Rosa', 'Zaruma', 'Portovelo'],
    'Esmeraldas': ['Esmeraldas', 'Atacames', 'Muisne', 'Quinindé', 'Rioverde'],
    'Galápagos': ['Puerto Baquerizo Moreno', 'Puerto Villamil', 'Puerto Ayora'],
    'Guayas': ['Guayaquil', 'Daule', 'Samborondón', 'Durán', 'Milagro'],
    'Imbabura': ['Ibarra', 'Otavalo', 'Cotacachi', 'Pimampiro', 'Urcuquí'],
    'Loja': ['Loja', 'Catamayo', 'Zapotillo', 'Puyango', 'Calvas'],
    'Los Ríos': ['Babahoyo', 'Quevedo', 'Vinces', 'Montalvo', 'Palestina'],
    'Manabí': ['Portoviejo', 'Manta', 'Jipijapa', 'Montecristi', 'Bahía de Caráquez'],
    'Morona Santiago': ['Macas', 'Gualaquiza', 'Limón Indanza', 'Palora', 'Santiago'],
    'Napo': ['Tena', 'El Chaco', 'Archidona', 'Quijos', 'Carlos Julio Arosemena Tola'],
    'Orellana': ['Francisco de Orellana', 'La Joya de los Sachas', 'Loreto', 'Aguarico'],
    'Pastaza': ['Puyo', 'Mera', 'Santa Clara', 'Arajuno'],
    'Pichincha': ['Quito', 'Cayambe', 'Mejía', 'Rumiñahui', 'Pedro Moncayo'],
    'Santa Elena': ['Santa Elena', 'La Libertad', 'Salinas'],
    'Santo Domingo de los Tsáchilas': ['Santo Domingo', 'La Concordia'],
    'Sucumbíos': ['Nueva Loja', 'Cascales', 'Cuyabeno', 'Gonzalo Pizarro', 'Putumayo'],
    'Tungurahua': ['Ambato', 'Baños', 'Pelileo', 'Patate', 'Quero'],
    'Zamora Chinchipe': ['Zamora', 'Yantzaza', 'Yacuambi', 'Centinela del Cóndor', 'Paquisha'],
  };

  List<FotosAlojamientos> fotosExistentes = [];
  List<File> nuevasFotos = [];
  List<String> fotosEliminadasIds = [];

  @override
  void initState() {
    super.initState();
    tituloController = TextEditingController(text: widget.alojamiento.titulo);
    descripcionController = TextEditingController(text: widget.alojamiento.descripcion);
    tipoController = TextEditingController(text: widget.alojamiento.tipoAlojamiento);
    precioController = TextEditingController(text: widget.alojamiento.precioNoche.toString());
    huespedesController = TextEditingController(text: widget.alojamiento.maxHuespedes.toString());
    direccionController = TextEditingController(text: widget.alojamiento.direccion);
    anfitrionController = TextEditingController(text: widget.alojamiento.anfitrionId);

    paisSeleccionado = widget.alojamiento.pais;
    provinciaSeleccionada = widget.alojamiento.provincia;
    ciudadSeleccionada = widget.alojamiento.ciudad;

    _loadExistingPhotos();
  }

  Future<void> _loadExistingPhotos() async {
    try {
      final photos = await _service.getPhotosAccommodations(widget.alojamiento.id);
      setState(() {
        fotosExistentes = photos;
      });
    } catch (e) {
      print('Error cargando fotos: $e');
    }
  }

  Future<void> _pickNewPhoto() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        nuevasFotos.add(File(pickedFile.path));
      });
    }
  }

  void _removeExistingPhoto(String id) {
    setState(() {
      fotosExistentes.removeWhere((foto) => foto.id == id);
      fotosEliminadasIds.add(id);
    });
  }

  void _removeNewPhoto(File file) {
    setState(() {
      nuevasFotos.remove(file);
    });
  }

  void _saveChanges() async {
    final updated = Alojamiento(
      id: widget.alojamiento.id,
      titulo: tituloController.text,
      descripcion: descripcionController.text,
      tipoAlojamiento: tipoController.text,
      precioNoche: int.tryParse(precioController.text) ?? 0,
      maxHuespedes: int.tryParse(huespedesController.text) ?? 0,
      ciudad: ciudadSeleccionada,
      provincia: provinciaSeleccionada,
      pais: paisSeleccionado,
      direccion: direccionController.text,
      anfitrionId: anfitrionController.text,
      estadoAlojamiento: 'activo',
    );

    try {
      final success = await _service.updateAccommodation(updated.id, updated);
      if (!success) throw Exception('Error actualizando alojamiento');

      for (var idFoto in fotosEliminadasIds) {
        await _service.deletePhoto(idFoto);
      }

      for (var fotoFile in nuevasFotos) {
        await _service.updatePhoto(updated.id, fotoFile);
      }

      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al actualizar: $e')),
        );
      }
    }
  }

  Widget _buildPhotoCard(Widget imageWidget, VoidCallback onRemove) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: imageWidget,
        ),
        Positioned(
          right: 4,
          top: 4,
          child: GestureDetector(
            onTap: onRemove,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
              child: const Icon(Icons.close, color: Colors.white, size: 20),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    const borderStyle = OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12)));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Alojamiento', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: tituloController,
              decoration: const InputDecoration(labelText: 'Título', border: borderStyle),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: descripcionController,
              maxLines: 3,
              decoration: const InputDecoration(labelText: 'Descripción', border: borderStyle),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: tipoController,
              decoration: const InputDecoration(labelText: 'Tipo de Alojamiento', border: borderStyle),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: precioController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Precio por Noche', border: borderStyle),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: huespedesController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Máximo de Huéspedes', border: borderStyle),
            ),
            const SizedBox(height: 12),

            DropdownButtonFormField<String>(
              value: paisSeleccionado,
              items: paises.map((pais) {
                return DropdownMenuItem(value: pais, child: Text(pais));
              }).toList(),
              onChanged: (valor) {
                setState(() {
                  paisSeleccionado = valor!;
                });
              },
              decoration: const InputDecoration(labelText: 'País', border: borderStyle),
            ),
            const SizedBox(height: 12),

            DropdownButtonFormField<String>(
              value: provinciaSeleccionada,
              items: provinciasYCiudades.keys.map((prov) {
                return DropdownMenuItem(value: prov, child: Text(prov));
              }).toList(),
              onChanged: (valor) {
                setState(() {
                  provinciaSeleccionada = valor!;
                  ciudadSeleccionada = provinciasYCiudades[valor]!.first;
                });
              },
              decoration: const InputDecoration(labelText: 'Provincia', border: borderStyle),
            ),
            const SizedBox(height: 12),

            DropdownButtonFormField<String>(
              value: ciudadSeleccionada,
              items: provinciasYCiudades[provinciaSeleccionada]!.map((ciudad) {
                return DropdownMenuItem(value: ciudad, child: Text(ciudad));
              }).toList(),
              onChanged: (valor) {
                setState(() {
                  ciudadSeleccionada = valor!;
                });
              },
              decoration: const InputDecoration(labelText: 'Ciudad', border: borderStyle),
            ),

            const SizedBox(height: 12),
            TextField(
              controller: direccionController,
              decoration: const InputDecoration(labelText: 'Dirección', border: borderStyle),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: anfitrionController,
              enabled: false,
              decoration: const InputDecoration(labelText: 'ID del Anfitrión', border: borderStyle),
            ),
            const SizedBox(height: 20),
            Align(
              alignment: Alignment.centerLeft,
              child: Text('Fotos', style: Theme.of(context).textTheme.titleLarge),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 130,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  ...fotosExistentes.map((foto) => Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: _buildPhotoCard(
                          Image.network(foto.urlFoto, width: 120, height: 120, fit: BoxFit.cover),
                          () => _removeExistingPhoto(foto.id),
                        ),
                      )),
                  ...nuevasFotos.map((file) => Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: _buildPhotoCard(
                          Image.file(file, width: 120, height: 120, fit: BoxFit.cover),
                          () => _removeNewPhoto(file),
                        ),
                      )),
                  GestureDetector(
                    onTap: _pickNewPhoto,
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(12)),
                      child: const Icon(Icons.add_a_photo, size: 40, color: Colors.black54),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: _saveChanges,
                child: const Text('Actualizar alojamiento', style: TextStyle(color: Colors.white, fontSize: 18)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
