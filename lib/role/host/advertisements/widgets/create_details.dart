import '../../../../providers/form_alojamiento_provider.dart';
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
  String _paisSeleccionado = 'Ecuador';
  String? _provinciaSeleccionada;
  String? _ciudadSeleccionada;

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

  final _formKey = GlobalKey<FormState>();

  final TextEditingController _tituloController = TextEditingController();
  final TextEditingController _descripcionController = TextEditingController();
  final TextEditingController _direccionController = TextEditingController();
  final TextEditingController _precioController = TextEditingController();
  final TextEditingController _maxHuespedesController = TextEditingController();

  bool _enviando = false;

  @override
  void dispose() {
    _tituloController.dispose();
    _descripcionController.dispose();
    _direccionController.dispose();
    _precioController.dispose();
    _maxHuespedesController.dispose();
    super.dispose();
  }

  // NUEVO: Widget para mostrar mensajes de retroalimentación
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

  Future<void> _enviarFormulario() async {
    if (_formKey.currentState!.validate()) {
      final formProvider = Provider.of<FormAlojamientoProvider>(context, listen: false);

      // Guardar datos en el provider
      formProvider.setTitulo(_tituloController.text);
      formProvider.setDescripcion(_descripcionController.text);
      formProvider.setCiudad(_ciudadSeleccionada ?? '');
      formProvider.setProvincia(_provinciaSeleccionada ?? '');
      formProvider.setPais(_paisSeleccionado);
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
          final alojamientoId = response.data['id'] ?? response.data['_id'];

          if (alojamientoId == null) {
            _buildMensajes('Error: no se recibió el ID del alojamiento', Colors.red, Icons.error);
            setState(() => _enviando = false);
            return;
          }

          // Subir imágenes si hay 3 o más
          if (formProvider.imagenesSeleccionadas.length >= 3) {
            final exitoSubida = await _subirImagenes(alojamientoId, token, formProvider);
            if (!exitoSubida) {
              _buildMensajes('Error al subir imágenes', Colors.red, Icons.warning);
              setState(() => _enviando = false);
              return;
            }
          } else {
            _buildMensajes('Debe subir al menos 3 imágenes', Colors.red, Icons.warning);
            setState(() => _enviando = false);
            return;
          }

          // Si todo bien
          _buildMensajes('Alojamiento creado con éxito', Colors.green, Icons.check_circle);
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
          _buildMensajes('Error al crear alojamiento', Colors.red, Icons.error);
        }
      } catch (e) {
        print('❌ Error al crear alojamiento: $e');
        _buildMensajes('Error: $e', Colors.red, Icons.error);
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
        // No establecer Content-Type para que Dio lo gestione automáticamente
      };
      print('🔐 Headers para subida: $headers');

      final response = await dio.post(
        'https://hospedajes-4rmu.onrender.com/api/alojamientos/fotos/$alojamientoId',
        data: formData,
        options: Options(headers: headers),
      );

      print('📨 Respuesta de la subida imágenes: ${response.statusCode}');
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print('❌ Error subiendo imágenes: $e');
      return false;
    }
  }

  List<String> get _provincias => provinciasYCiudades.keys.toList();

  List<String> get _ciudades {
    if (_provinciaSeleccionada == null) return [];
    return provinciasYCiudades[_provinciaSeleccionada!] ?? [];
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required String? Function(String?) validator,
    TextInputType keyboardType = TextInputType.text,
    int? maxCaracteres, // NUEVO: Parámetro para el máximo de caracteres
  }) {
    return TextFormField(
      controller: controller,
      maxLength: maxCaracteres, // Usando el nuevo parámetro
      maxLines: keyboardType == TextInputType.multiline ? null : 1,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        counterText: maxCaracteres != null ? '${controller.text.length}/$maxCaracteres' : null, // Muestra el contador de caracteres
      ),
      keyboardType: keyboardType,
      validator: validator,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detalles del alojamiento',
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            )),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildTextField(
                label: 'Título',
                controller: _tituloController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa un título';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 18),
              _buildTextField(
                label: 'Descripción',
                controller: _descripcionController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa una descripción';
                  }
                  return null;
                },
                keyboardType: TextInputType.multiline,
                maxCaracteres: 250, // AQUÍ: Se establece el límite de 250 caracteres
              ),
              const SizedBox(height: 18),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Provincia',
                  border: OutlineInputBorder(),
                ),
                value: _provinciaSeleccionada,
                items: _provincias
                    .map((provincia) => DropdownMenuItem(
                          value: provincia,
                          child: Text(provincia),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _provinciaSeleccionada = value;
                    _ciudadSeleccionada = null;
                  });
                },
                validator: (value) => value == null ? 'Selecciona una provincia' : null,
              ),
              const SizedBox(height: 18),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Ciudad',
                  border: OutlineInputBorder(),
                ),
                value: _ciudadSeleccionada,
                items: _ciudades
                    .map((ciudad) => DropdownMenuItem(
                          value: ciudad,
                          child: Text(ciudad),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _ciudadSeleccionada = value;
                  });
                },
                validator: (value) => value == null ? 'Selecciona una ciudad' : null,
              ),
              const SizedBox(height: 18),
              _buildTextField(
                label: 'Dirección',
                controller: _direccionController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa una dirección';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 18),
              _buildTextField(
                label: 'Precio por noche',
                controller: _precioController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa un precio';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Ingrese un número válido';
                  }
                  return null;
                },
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 18),
              _buildTextField(
                label: 'Máximo de huéspedes',
                controller: _maxHuespedesController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa la cantidad máxima de huéspedes';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Ingrese un número válido';
                  }
                  return null;
                },
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 25),
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
                          'Crear alojamiento',
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
}