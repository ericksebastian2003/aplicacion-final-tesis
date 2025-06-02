import 'package:cross_file/cross_file.dart';  // Cambié la importación para XFile correcta
import 'package:desole_app/data/models/FotoAlojamientos.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'dart:io';
import 'package:path/path.dart' as path;

class FormAlojamientoProvider with ChangeNotifier {
  String _tipoAlojamiento = '';
  String _titulo = '';
  String _descripcion = '';
  String _ciudad = '';
  String _provincia = '';
  String _pais = '';
  String _direccion = '';
  int _precioNoche = 0;
  int _maxHuespedes = 0;
  String _estadoAlojamiento = 'activo';
  String _anfitrionId = '';
  String? _token;

  // Lista para almacenar las imágenes seleccionadas como XFile
  List<XFile> _imagenesSeleccionadas = [];

  // Getters
  String get tipoAlojamiento => _tipoAlojamiento;
  String get titulo => _titulo;
  String get descripcion => _descripcion;
  String get ciudad => _ciudad;
  String get provincia => _provincia;
  String get pais => _pais;
  String get direccion => _direccion;
  int get precioNoche => _precioNoche;
  int get maxHuespedes => _maxHuespedes;
  String get estadoAlojamiento => _estadoAlojamiento;
  String get anfitrionId => _anfitrionId;
  String? get token => _token;
  List<XFile> get imagenesSeleccionadas => _imagenesSeleccionadas;

  // Setters
  void setTipoAlojamiento(String tipo) {
    _tipoAlojamiento = tipo;
    notifyListeners();
  }

  void setTitulo(String titulo) {
    _titulo = titulo;
    notifyListeners();
  }

  void setDescripcion(String descripcion) {
    _descripcion = descripcion;
    notifyListeners();
  }

  void setCiudad(String ciudad) {
    _ciudad = ciudad;
    notifyListeners();
  }

  void setProvincia(String provincia) {
    _provincia = provincia;
    notifyListeners();
  }

  void setPais(String pais) {
    _pais = pais;
    notifyListeners();
  }

  void setDireccion(String direccion) {
    _direccion = direccion;
    notifyListeners();
  }

  void setPrecioNoche(int precio) {
    _precioNoche = precio;
    notifyListeners();
  }

  void setMaxHuespedes(int max) {
    _maxHuespedes = max;
    notifyListeners();
  }

  void setEstadoAlojamiento(String estado) {
    _estadoAlojamiento = estado;
    notifyListeners();
  }

  void setAnfitrionId(String id) {
    _anfitrionId = id;
    notifyListeners();
  }

  void setToken(String token) {
    _token = token;
    notifyListeners();
  }

  // Manejo imágenes
  void agregarImagen(XFile imagen) {
    _imagenesSeleccionadas.add(imagen);
    notifyListeners();
  }

  void eliminarImagen(XFile imagen) {
    _imagenesSeleccionadas.removeWhere((xfile) => xfile.path == imagen.path);
    notifyListeners();
  }

  void limpiarImagenes() {
    _imagenesSeleccionadas.clear();
    notifyListeners();
  }

  void setImagenes(List<XFile> selectedImages) {
    _imagenesSeleccionadas = selectedImages;
    notifyListeners();
  }

  // Para limpiar el formulario después de enviarlo
  void reset() {
    _tipoAlojamiento = '';
    _titulo = '';
    _descripcion = '';
    _ciudad = '';
    _provincia = '';
    _pais = '';
    _direccion = '';
    _precioNoche = 0;
    _maxHuespedes = 0;
    _estadoAlojamiento = 'activo';
    _anfitrionId = '';
    _token = null;
    limpiarImagenes();
    notifyListeners();
  }

  // Método para generar el JSON que se enviará a la API
  Map<String, dynamic> toJson() {
    return {
      "tipoAlojamiento": _tipoAlojamiento,
      "titulo": _titulo,
      "descripcion": _descripcion,
      "ciudad": _ciudad,
      "provincia": _provincia,
      "pais": _pais,
      "direccion": _direccion,
      "precioNoche": _precioNoche,
      "maxHuespedes": _maxHuespedes,
      "estadoAlojamiento": _estadoAlojamiento,
      "anfitrion": _anfitrionId,
    };
  }

  // Método para crear alojamiento (retorna el id)
  Future<String?> crearAlojamiento() async {
    try {
      final dio = Dio();

      final options = Options(
        headers: _token != null
            ? {
                'Authorization': 'Bearer $_token',
                'Content-Type': 'application/json',
              }
            : {
                'Content-Type': 'application/json',
              },
      );

      final response = await dio.post(
        'https://hospedajes-4rmu.onrender.com/api/alojamientos/crear',
        data: toJson(),
        options: options,
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final alojamientoId = response.data['_id'] ?? response.data['id'];
        return alojamientoId;
      } else {
        print('Error al crear alojamiento: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error en la solicitud: $e');
      return null;
    }
  }

  // Método para subir imágenes al alojamiento creado
  Future<void> _subirImagenes(String alojamientoId) async {
  final dio = Dio();
  final url = 'https://hospedajes-4rmu.onrender.com/api/alojamientos/fotos/$alojamientoId';

  for (var i = 0; i < _imagenesSeleccionadas.length; i++) {
    final imagen = _imagenesSeleccionadas[i];
    final nombreArchivo = path.basename(imagen.path);
    final esPrincipal = i == 0; // Marcar la primera como principal

    final formData = FormData.fromMap({
      'foto': await MultipartFile.fromFile(imagen.path, filename: nombreArchivo),
      'fotoPrincipal': esPrincipal.toString(),
    });

    // 📸 Imprimir datos que se enviarán
    print('📤 Enviando imagen:');
    print('📁 Nombre archivo: $nombreArchivo');
    print('📍 Path: ${imagen.path}');
    print('📌 Foto Principal: $esPrincipal');
    print('📦 FormData:');
    for (var field in formData.fields) {
      print(' - ${field.key}: ${field.value}');
    }

    try {
      final response = await dio.post(
        url,
        data: formData,
        options: Options(
          headers: {
            if (_token != null) 'Authorization': 'Bearer $_token',
          },
          validateStatus: (status) => status != null && status < 500,
        ),
      );

      print('📨 Respuesta status: ${response.statusCode}');
      print('📨 Respuesta data: ${response.data}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final foto = FotosAlojamientos.fromJson(response.data);
        print('✅ Imagen subida correctamente: ${foto.urlFoto}');
      } else {
        print('❌ Error en respuesta del servidor: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Excepción al subir imagen $nombreArchivo: $e');
    }
  }
}


}
