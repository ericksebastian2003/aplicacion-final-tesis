import 'dart:io';
import 'package:desole_app/role/host/advertisements/widgets/create_details.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../../../data/providers/form_alojamiento_provider.dart';  // Importa tu provider

class CreateImage extends StatefulWidget {
  final void Function(String) onImageUploaded;
  final String alojamientoId;

  const CreateImage({
    Key? key,
    required this.onImageUploaded,
    required this.alojamientoId,
  }) : super(key: key);

  @override
  State<CreateImage> createState() => _CreateImageState();
}

class _CreateImageState extends State<CreateImage> {
  final ImagePicker _picker = ImagePicker();
  List<XFile> _selectedImages = [];

  @override
  void initState() {
    super.initState();
    final formProvider = Provider.of<FormAlojamientoProvider>(context, listen: false);
    _selectedImages = formProvider.imagenesSeleccionadas; // Cargar imágenes previas si hay
  }

  Future<void> _pickImages() async {
    final List<XFile>? images = await _picker.pickMultiImage();
    if (images != null) {
      if (images.length + _selectedImages.length > 5) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Solo puedes seleccionar hasta 5 imágenes')),
        );
        return;
      }
      setState(() {
        _selectedImages.addAll(images);
      });
    }
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  void _guardarEnProvider() {
    if (_selectedImages.length < 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Debes seleccionar al menos 3 imágenes')),
      );
      return;
    }

    final formProvider = Provider.of<FormAlojamientoProvider>(context, listen: false);
    formProvider.setImagenes(_selectedImages);

    widget.onImageUploaded("Imágenes guardadas temporalmente.");
    Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => CreateDetails()
              ),
            );
  }

  @override
  Widget build(BuildContext context) {
    final bool cumpleMinimo = _selectedImages.length >= 3;

    return Scaffold(
      appBar: AppBar(title: const Text('Subir imágenes del alojamiento')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ElevatedButton.icon(
              onPressed: _pickImages,
              icon: const Icon(Icons.photo_library),
              label: const Text('Seleccionar imágenes'),
            ),
            const SizedBox(height: 10),
            Text(
              'Imágenes seleccionadas: ${_selectedImages.length} / 5',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: cumpleMinimo ? Colors.green : Colors.red,
              ),
            ),
            const SizedBox(height: 10),
            _selectedImages.isNotEmpty
                ? SizedBox(
                    height: 140,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _selectedImages.length,
                      itemBuilder: (context, index) {
                        return Stack(
                          children: [
                            Container(
                              margin: const EdgeInsets.symmetric(horizontal: 8),
                              width: 120,
                              height: 120,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                image: DecorationImage(
                                  image: FileImage(File(_selectedImages[index].path)),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            Positioned(
                              top: 0,
                              right: 0,
                              child: GestureDetector(
                                onTap: () => _removeImage(index),
                                child: Container(
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.black54,
                                  ),
                                  child: const Icon(Icons.close, color: Colors.white, size: 20),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  )
                : const Text('No has seleccionado imágenes.'),
            const Spacer(),
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
                onPressed: _guardarEnProvider,
                child: const Text(
                  'Guardar imágenes',
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
    );
  }
}
  
