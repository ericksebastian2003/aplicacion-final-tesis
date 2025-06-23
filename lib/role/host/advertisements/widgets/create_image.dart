import 'dart:io';
import 'package:desole_app/role/host/advertisements/widgets/create_details.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:dotted_border/dotted_border.dart';
import '../../../../providers/form_alojamiento_provider.dart';
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
    _selectedImages = formProvider.imagenesSeleccionadas;
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
    //formProvider.setImagenes(_selectedImages);

    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => CreateDetails()),
    );
  }

  ButtonStyle _buttonStyle() {
    return ElevatedButton.styleFrom(
      backgroundColor: Colors.black,
      padding: const EdgeInsets.symmetric(vertical: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      textStyle: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool cumpleMinimo = _selectedImages.length >= 3;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Detalles del alojamiento',
          style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
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

            // Grid con imágenes y botón agregar
            Expanded(
              child: GridView.builder(
                itemCount: _selectedImages.length + 1,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3, // 3 imágenes por fila
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1,
                ),
                itemBuilder: (context, index) {
                  if (index == 0) {
                    // Botón para agregar imágenes
                    return GestureDetector(
  onTap: _pickImages,
  child: DottedBorder(
    borderType: BorderType.RRect,
    radius: const Radius.circular(12),
    dashPattern: const [6, 3], // 6 pixeles línea, 3 pixeles espacio
    color: Colors.white.withOpacity(0.5), // blanco muy suave
    strokeWidth: 2,
    child: Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1), // fondo blanco muy transparente
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Center(
        child: Icon(
          Icons.add,
          size: 50,
          color: Colors.black,
        ),
      ),
    ),
  ),
);
                  }

                  final imageIndex = index - 1;
                  return Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(
                          File(_selectedImages[imageIndex].path),
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                        ),
                      ),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: GestureDetector(
                          onTap: () => _removeImage(imageIndex),
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.black54,
                              border: Border.all(color: Colors.white, width: 1.5),
                            ),
                            child: const Icon(Icons.close, color: Colors.white, size: 22),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),

            const SizedBox(height: 16),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: _buttonStyle(),
                onPressed: cumpleMinimo ? _guardarEnProvider : null, // deshabilita botón si no cumple
                child: const Text(
                  'Siguiente',
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
