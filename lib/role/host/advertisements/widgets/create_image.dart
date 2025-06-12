import 'dart:io';
import 'package:desole_app/role/host/advertisements/widgets/create_details.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../../../data/providers/form_alojamiento_provider.dart';

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
    formProvider.setImagenes(_selectedImages);

    widget.onImageUploaded("Imágenes guardadas temporalmente.");
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => CreateDetails()),
    );
  }

  // Estilo común para botones: negro, con borde redondeado
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
          SizedBox(
            height: 140,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _selectedImages.length + 1,  // +1 para el botón "+"
              itemBuilder: (context, index) {
                if (index == 0) {
                  // Botón para agregar imágenes (cuadrado con borde y ícono +)
                  return GestureDetector(
                    onTap: _pickImages,
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.black87, width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 6,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.add,
                          size: 50,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  );
                }

                // Mostrar imágenes seleccionadas
                final imageIndex = index - 1;
                return Stack(
                  children: [
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        image: DecorationImage(
                          image: FileImage(File(_selectedImages[imageIndex].path)),
                          fit: BoxFit.cover,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 6,
                            offset: const Offset(0, 3),
                          ),
                        ],
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
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: _buttonStyle(),
              onPressed: _guardarEnProvider,
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

