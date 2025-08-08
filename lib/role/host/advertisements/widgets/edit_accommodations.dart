import 'dart:io';
import 'package:desole_app/data/models/AlojamientosAnfitrion.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:desole_app/data/models/FotoAlojamientos.dart';
import 'package:desole_app/services/accomodation_services.dart';
import 'package:dio/dio.dart';

class EditAccommodationScreen extends StatefulWidget {
  final AlojamientoAnfitrion alojamiento;

  const EditAccommodationScreen({super.key, required this.alojamiento});

  @override
  State<EditAccommodationScreen> createState() => _EditAccommodationScreenState();
}

class _EditAccommodationScreenState extends State<EditAccommodationScreen> {
  final _service = AccomodationServices();
  final ImagePicker _picker = ImagePicker();

  late TextEditingController tituloController;
  late TextEditingController precioController;
  late TextEditingController anfitrionController;

  List<FotosAlojamientos> fotosExistentes = [];
  List<File> nuevasFotos = [];
  List<String> fotosEliminadasIds = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    tituloController = TextEditingController(text: widget.alojamiento.titulo);
    precioController = TextEditingController(text: widget.alojamiento.precioNoche.toString());
    _loadExistingPhotos();
  }

  // Nuevo widget para mostrar mensajes
  void _buildMensajes(String message, Color color, IconData icon) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  Future<void> _loadExistingPhotos() async {
    setState(() => _isLoading = true);
    try {
      final photos = await _service.getPhotosAccommodations(widget.alojamiento.id);
      setState(() {
        fotosExistentes = photos;
      });
    } catch (e) {
      _buildMensajes('Error al cargar las fotos: $e', Colors.red, Icons.error);
    } finally {
      setState(() => _isLoading = false);
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
    setState(() => _isLoading = true);

    final updated = AlojamientoAnfitrion(
      id: widget.alojamiento.id,
      titulo: tituloController.text,
      precioNoche: int.tryParse(precioController.text) ?? 0,
      calificacionPromedio: widget.alojamiento.calificacionPromedio,
      createdAt: DateTime.now(),
      estadoAlojamiento: 'activo',
    );

    try {
      // 1. Actualizar datos del alojamiento
      final updateMessage = await _service.updateAccommodation(updated.id, updated);
      if (updateMessage.contains('Error')) {
        _buildMensajes(updateMessage, Colors.red, Icons.error);
        return;
      }
      _buildMensajes(updateMessage, Colors.green, Icons.check_circle);

      // 2. Eliminar fotos
      for (var idFoto in fotosEliminadasIds) {
        final deleteMessage = await _service.deletePhoto(idFoto);
        if (deleteMessage.contains('Error')) {
          _buildMensajes(deleteMessage, Colors.red, Icons.warning);
        } else {
          _buildMensajes(deleteMessage, Colors.green, Icons.check);
        }
      }

      // 3. Subir nuevas fotos
      for (var fotoFile in nuevasFotos) {
        final uploadMessage = await _service.updatePhoto(updated.id, fotoFile);
        if (uploadMessage.contains('Error')) {
          _buildMensajes(uploadMessage, Colors.red, Icons.warning);
        } else {
          _buildMensajes(uploadMessage, Colors.green, Icons.check);
        }
      }

      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      _buildMensajes('Error inesperado: $e', Colors.red, Icons.error);
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
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
      body: _isLoading && fotosExistentes.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  TextField(
                    controller: tituloController,
                    decoration: const InputDecoration(labelText: 'Título', border: borderStyle),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: precioController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Precio por Noche', border: borderStyle),
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
                      onPressed: _isLoading ? null : _saveChanges,
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text('Actualizar alojamiento',
                              style: TextStyle(color: Colors.white, fontSize: 18)),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}