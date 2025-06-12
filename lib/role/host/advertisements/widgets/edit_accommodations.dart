import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:desole_app/data/models/FotoAlojamientos.dart';
import 'package:desole_app/services/accomodation_services.dart';
import 'package:flutter/material.dart';
import 'package:desole_app/data/models/Alojamientos.dart';

class EditAccommodationScreen extends StatefulWidget {
  final Alojamiento alojamiento;

  const EditAccommodationScreen({super.key, required this.alojamiento});

  @override
  State<EditAccommodationScreen> createState() => _EditAccommodationScreenState();
}

class _EditAccommodationScreenState extends State<EditAccommodationScreen> {
  final _service = AccomodationServices();

  // Controllers existentes
  late TextEditingController tituloController;
  late TextEditingController descripcionController;
  late TextEditingController tipoController;
  late TextEditingController precioController;
  late TextEditingController huespedesController;
  late TextEditingController ciudadController;
  late TextEditingController provinciaController;
  late TextEditingController paisController;
  late TextEditingController direccionController;
  late TextEditingController anfitrionController;

  // Fotos actuales y nuevas fotos seleccionadas
  List<FotosAlojamientos> fotosExistentes = [];
  List<File> nuevasFotos = [];
  List<String> fotosEliminadasIds = [];

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    tituloController = TextEditingController(text: widget.alojamiento.titulo);
    descripcionController = TextEditingController(text: widget.alojamiento.descripcion);
    tipoController = TextEditingController(text: widget.alojamiento.tipoAlojamiento);
    precioController = TextEditingController(text: widget.alojamiento.precioNoche.toString());
    huespedesController = TextEditingController(text: widget.alojamiento.maxHuespedes.toString());
    ciudadController = TextEditingController(text: widget.alojamiento.ciudad);
    provinciaController = TextEditingController(text: widget.alojamiento.provincia);
    paisController = TextEditingController(text: widget.alojamiento.pais);
    direccionController = TextEditingController(text: widget.alojamiento.direccion);
    anfitrionController = TextEditingController(text: widget.alojamiento.anfitrionId);

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

  @override
  void dispose() {
    tituloController.dispose();
    descripcionController.dispose();
    tipoController.dispose();
    precioController.dispose();
    huespedesController.dispose();
    ciudadController.dispose();
    provinciaController.dispose();
    paisController.dispose();
    direccionController.dispose();
    anfitrionController.dispose();
    super.dispose();
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
      fotosEliminadasIds.add(id); // Guardamos para eliminar en backend
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
      ciudad: ciudadController.text,
      provincia: provinciaController.text,
      pais: paisController.text,
      direccion: direccionController.text,
      anfitrionId: anfitrionController.text,
    );

    print('🚀 Enviando alojamiento a editar: ${updated.toJsonForUpdate()}');
    print('Fotos a eliminar: $fotosEliminadasIds');
    print('Número de fotos nuevas: ${nuevasFotos.length}');

    try {
      // Actualizar datos alojamiento
      final success = await _service.updateAccommodation(updated.id, updated);

      if (!success) {
        throw Exception('Error actualizando alojamiento');
      }

      // Eliminar fotos removidas en backend
      for (var idFoto in fotosEliminadasIds) {
        await _service.deletePhoto(idFoto);
      }

      // Subir fotos nuevas
      for (var fotoFile in nuevasFotos) {
        await _service.updatePhoto(updated.id, fotoFile);
      }


      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al actualizar: $e')),
        );
      }
    }
  }

  Widget _buildExistingPhotoCard(FotosAlojamientos foto) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.network(
            foto.urlFoto,
            width: 120,
            height: 120,
            fit: BoxFit.cover,
          ),
        ),
        Positioned(
          right: 0,
          top: 0,
          child: GestureDetector(
            onTap: () => _removeExistingPhoto(foto.id),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black54,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNewPhotoCard(File file) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.file(
            file,
            width: 120,
            height: 120,
            fit: BoxFit.cover,
          ),
        ),
        Positioned(
          right: 0,
          top: 0,
          child: GestureDetector(
            onTap: () => _removeNewPhoto(file),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black54,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Editar alojamiento')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Form fields
            TextField(controller: tituloController, decoration: const InputDecoration(labelText: 'Título')),
            TextField(controller: descripcionController, decoration: const InputDecoration(labelText: 'Descripción')),
            TextField(controller: tipoController, decoration: const InputDecoration(labelText: 'Tipo de alojamiento')),
            TextField(
              controller: precioController,
              decoration: const InputDecoration(labelText: 'Precio por noche'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: huespedesController,
              decoration: const InputDecoration(labelText: 'Máximo huéspedes'),
              keyboardType: TextInputType.number,
            ),
            TextField(controller: ciudadController, decoration: const InputDecoration(labelText: 'Ciudad')),
            TextField(controller: provinciaController, decoration: const InputDecoration(labelText: 'Provincia')),
            TextField(controller: paisController, decoration: const InputDecoration(labelText: 'País')),
            TextField(controller: direccionController, decoration: const InputDecoration(labelText: 'Dirección')),
            TextField(
              controller: anfitrionController,
              decoration: const InputDecoration(labelText: 'ID del Anfitrión'),
              enabled: false,
            ),
            const SizedBox(height: 20),

            // Fotos sección
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
                  ...fotosExistentes.map(_buildExistingPhotoCard),
                  ...nuevasFotos.map(_buildNewPhotoCard),
                  GestureDetector(
                    onTap: _pickNewPhoto,
                    child: Container(
                      width: 120,
                      height: 120,
                      margin: const EdgeInsets.only(left: 8),
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.add_a_photo, size: 40, color: Colors.black54),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

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
                onPressed: _saveChanges,
                child: const Text(
                  'Guardar cambios',
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
    );
  }
}
