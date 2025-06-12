import 'package:desole_app/data/providers/form_alojamiento_provider.dart';
import 'package:desole_app/role/host/dashboard/host_dashboard.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CreateDetails extends StatefulWidget {
  const CreateDetails({super.key});

  @override
  State<CreateDetails> createState() => _CreateDetailsState();
}

class _CreateDetailsState extends State<CreateDetails> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _tituloController = TextEditingController();
  final TextEditingController _descripcionController = TextEditingController();
  final TextEditingController _ciudadController = TextEditingController();
  final TextEditingController _provinciaController = TextEditingController();
  final TextEditingController _paisController = TextEditingController();
  final TextEditingController _direccionController = TextEditingController();
  final TextEditingController _precioController = TextEditingController();
  final TextEditingController _maxHuespedesController = TextEditingController();

  bool _enviando = false;

  @override
  void dispose() {
    _tituloController.dispose();
    _descripcionController.dispose();
    _ciudadController.dispose();
    _provinciaController.dispose();
    _paisController.dispose();
    _direccionController.dispose();
    _precioController.dispose();
    _maxHuespedesController.dispose();
    super.dispose();
  }

  Future<void> _enviarFormulario() async {
    if (_formKey.currentState!.validate()) {
      final formProvider = Provider.of<FormAlojamientoProvider>(context, listen: false);

      // Guardar datos en el provider
      formProvider.setTitulo(_tituloController.text);
      formProvider.setDescripcion(_descripcionController.text);
      formProvider.setCiudad(_ciudadController.text);
      formProvider.setProvincia(_provinciaController.text);
      formProvider.setPais(_paisController.text);
      formProvider.setDireccion(_direccionController.text);
      formProvider.setPrecioNoche(int.parse(_precioController.text));
      formProvider.setMaxHuespedes(int.parse(_maxHuespedesController.text));

      final datos = formProvider.toJson();

      try {
        setState(() => _enviando = true);

        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString('token') ?? '';
        final hostId = prefs.getString('hostId') ?? '';

        print('📦 Datos a enviar: $datos');
        print('🔐 Token: $token');
        print('👤 HostId: $hostId');

        final dio = Dio();
        dio.options.headers['Authorization'] = 'Bearer $token';

        // Crear alojamiento
        final response = await dio.post(
          'https://hospedajes-4rmu.onrender.com/api/alojamientos/crear',
          data: datos,
        );

        print('✅ Respuesta statusCode: ${response.statusCode}');
        print('📨 Respuesta data: ${response.data}');

        if (response.statusCode == 201) {
          final alojamientoId = response.data['id'] ?? response.data['_id'] ?? null;

          if (alojamientoId == null) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Error: no se recibió el ID del alojamiento')),
            );
            setState(() => _enviando = false);
            return;
          }

          // Subir imágenes si hay 3 o más
          if (formProvider.imagenesSeleccionadas.length >= 3) {
            final exitoSubida = await _subirImagenes(alojamientoId, token, formProvider);
            if (!exitoSubida) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Error al subir imágenes')),
              );
              setState(() => _enviando = false);
              return;
            }
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Debe subir al menos 3 imágenes')),
            );
            setState(() => _enviando = false);
            return;
          }

          // Si todo bien
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Alojamiento creado con éxito')),
          );
          formProvider.reset();

          final nombre = prefs.getString('nombre') ?? 'Anfitrión';
          final rol = prefs.getString('rol') ?? 'host';

          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (context) => HostDashboard(
                rol: rol,
                nombre: nombre,
                hostId: hostId,
              ),
            ),
            (Route<dynamic> route) => false,
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Error al crear alojamiento')),
          );
        }
      } catch (e) {
        print('❌ Error al crear alojamiento: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      } finally {
        setState(() => _enviando = false);
      }
    }
  }

 Future<bool> _subirImagenes(String alojamientoId, String token, FormAlojamientoProvider formProvider) async {
  final dio = Dio();
  final formData = FormData();

  try {
    print('📤 Iniciando la preparación de imágenes para subir...');
   for (var image in formProvider.imagenesSeleccionadas) {
      final fileName = image.path.split('/').last;
      print('📤 Agregando imagen: $fileName, path: ${image.path}');
      formData.files.add(
        MapEntry(
          'imagenes', // nombre del campo esperado por el backend
          await MultipartFile.fromFile(image.path, filename: fileName),
        ),
      );
    }
    


    print('📦 FormData contiene ${formData.files.length} archivos.');
    for (var fileEntry in formData.files) {
      print(' - Key: ${fileEntry.key}, Filename: ${fileEntry.value.filename}');
    }

    final headers = {
      'Authorization': 'Bearer $token',
      // No establecer Content-Type para que Dio lo gestione
    };
    print('🔐 Headers configurados: $headers');
    print('🆔 Subiendo imágenes al alojamiento con ID: $alojamientoId');

    final response = await dio.post(
      'https://hospedajes-4rmu.onrender.com/api/alojamientos/fotos/$alojamientoId',
      data: formData,
      options: Options(
        headers: headers,
      
      ),
      onSendProgress: (int sent, int total) {
        print('⬆️ Progreso subida imágenes: $sent / $total bytes');
      },
    );

    print('📸 Respuesta subida fotos - StatusCode: ${response.statusCode}');
    print('📸 Respuesta subida fotos - Data: ${response.data}');
    return response.statusCode == 200 || response.statusCode == 201;
  } catch (e, stackTrace) {
    print('❌ Error al subir imágenes: $e');
    print('📄 StackTrace: $stackTrace');
    return false;
  }
}



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detalles del alojamiento')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildTextField(_tituloController, 'Título', 'Ingresa un título'),
              _buildTextField(_descripcionController, 'Descripción', 'Describe tu alojamiento'),
              _buildTextField(_ciudadController, 'Ciudad', 'Ingresa la ciudad'),
              _buildTextField(_provinciaController, 'Provincia', 'Ingresa la provincia'),
              _buildTextField(_paisController, 'País', 'Ingresa el país'),
              _buildTextField(_direccionController, 'Dirección', 'Ingresa la dirección'),
              _buildTextField(_precioController, 'Precio por noche', 'Solo números', isNumeric: true),
              _buildTextField(_maxHuespedesController, 'Máx. huéspedes', 'Solo números', isNumeric: true),
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
                  onPressed: _enviando ? null : _enviarFormulario,
                  child: _enviando
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Siguiente',
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
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, String hint, {bool isNumeric = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14.0),
      child: TextFormField(
        controller: controller,
        keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          border: const OutlineInputBorder(),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) return 'Este campo es obligatorio';
          return null;
        },
      ),
    );
  }
}
