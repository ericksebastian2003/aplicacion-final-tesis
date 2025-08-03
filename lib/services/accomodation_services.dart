import 'dart:async';
import 'package:desole_app/data/models/Alojamientos.dart';
import 'package:desole_app/data/models/FotoAlojamientos.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
class AccomodationServices {
  final Dio _dio = Dio();
  final String baseUrl = "https://hospedajes-4rmu.onrender.com/api/alojamientos";

  AccomodationServices() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final prefs = await SharedPreferences.getInstance();
          final token = prefs.getString('token');

         // print('👉 PETICIÓN: ${options.method} ${options.uri}');
         // print('👉 Headers antes del token: ${options.headers}');

          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
            //print('🔐 Se agregó el token: $token');
          } else {
           // print('❌ No se encontró token en SharedPreferences');
          }

          return handler.next(options);
        },
        onResponse: (response, handler) {
          //print('✅ RESPUESTA [${response.statusCode}]: ${response.requestOptions.uri}');
          //print('📦 Body: ${response.data}');
          return handler.next(response);
        },
        onError: (DioError e, handler) {
          //print('❗ ERROR EN LA RESPUESTA:');
          //print('🔗 URI: ${e.requestOptions.uri}');
        /*print('📥 HEADERS: ${e.requestOptions.headers}');
          print('📤 BODY: ${e.response?.data}');
          print('🧾 STATUS CODE: ${e.response?.statusCode}');
          */
          return handler.next(e);
        },
      ),
    );
  }

  // Obtener un alojamiento por ID
  Future<Alojamiento> getAccommodation(String id) async {
    try {
      final response = await _dio.get('$baseUrl/ver/$id');
      //print("🟢 Respuesta del servidor: ${response.data}");

      if (response.statusCode == 200) {
        final data = response.data;
        if (data != null) {
          return Alojamiento.fromJson(data);
        } else {
          throw Exception('El alojamiento no fue encontrado.');
        }
      } else {
        throw Exception('Error al obtener alojamiento: ${response.statusCode}');
      }
    } catch (e) {
      //print("❌ Error al obtener detalle del alojamiento: $e");
      throw Exception('Error al obtener alojamiento: $e');
    }
  }

  // Obtener todos los alojamientos
  Future<List<Alojamiento>> getAllAccommodations() async {
    try {
      final response = await _dio.get(baseUrl);
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => Alojamiento.fromJson(json)).toList();
      } else {
        throw Exception('Error en la respuesta del servidor: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error al cargar alojamientos: $e');
    }
  }
  // Obtener todos los alojamientos
  Future<List<Alojamiento>> getAllAccommodationsHost() async {
    try {
      final response = await _dio.get('$baseUrl/anfitrion');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => Alojamiento.fromJson(json)).toList();
      } else {
        throw Exception('Error en la respuesta del servidor: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error al cargar alojamientos: $e');
    }
  }

  // Actualizar alojamiento
  Future<bool> updateAccommodation(String id, Alojamiento alojamiento) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';
      _dio.options.headers['Authorization'] = 'Bearer $token';

      final response = await _dio.put(
        '$baseUrl/actualizar/$id',
        data: alojamiento.toJson(),
      );
      return response.statusCode == 200;
    } catch (e) {
      throw Exception('Error al actualizar alojamiento: $e');
    }
  }

  // Eliminar alojamiento
  Future<bool> deleteAccommodation(String id) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';
      //print(token);
      _dio.options.headers['Authorization'] = 'Bearer $token';

      final response = await _dio.delete('$baseUrl/borrar/$id');
      return response.statusCode == 200;
    } catch (e) {
      //print('Error en deleteAccommodation: $e');
      return false;
    }
  }

  // Obtener fotos por alojamiento
  Future<List<FotosAlojamientos>> getPhotosAccommodations(String id) async {
    final url = '$baseUrl/fotos/$id';
    print('🔍 Llamando a: $url');

    try {
      final response = await _dio.get(url);
      //print('📥 Respuesta completa: ${response.data}');

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
       // print('📸 Número de fotos recibidas: ${data.length}');
        return data.map((json) => FotosAlojamientos.fromJson(json)).toList();
      } else {
       // print('⚠️ Código de estado inesperado: ${response.statusCode}');
        throw Exception('Error en la respuesta del servidor: ${response.statusCode}');
      }
    } catch (e) {
      //print('❌ Error al cargar las fotos de los alojamientos: $e');
      throw Exception('Error al cargar las fotos de los alojamientos: $e');
    }
  }

  // Eliminar foto de alojamiento
  Future<bool> deletePhoto(String idFoto) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';
      _dio.options.headers['Authorization'] = 'Bearer $token';

      final response = await _dio.delete('$baseUrl/fotos/$idFoto');
      //print('🗑️ Eliminando foto ID: $idFoto');
      //print('📤 Status: ${response.statusCode}');
      return response.statusCode == 200;
    } catch (e) {
      //print('❌ Error al eliminar la foto: $e');
      return false;
    }
  }

  // Actualizar foto del alojamiento
  Future<bool> updatePhoto(String alojamientoId, File fotoFile) async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';
    _dio.options.headers['Authorization'] = 'Bearer $token';

    String fileName = fotoFile.path.split('/').last;

    FormData formData = FormData.fromMap({
      'foto': await MultipartFile.fromFile(fotoFile.path, filename: fileName),
    });

    final response = await _dio.put(
      '$baseUrl/fotos/$alojamientoId', // o la ruta que sea para subir fotos
      data: formData,
      options: Options(contentType: 'multipart/form-data'),
    );

    return response.statusCode == 201 || response.statusCode == 200;
  } catch (e) {
    //print('Error al subir foto: $e');
    return false;
  }
}
Future<List<Alojamiento>> getAccommodationsFiltered({
  String? provincia,
  String? tipoAlojamiento,
  double? precioMin,
  double? precioMax,
  double? calificacion,
}) async {
  try {
    final Map<String, dynamic> queryParams = {};

    // Solo agregar si no es nulo y tiene valor significativo
    if (provincia != null && provincia.isNotEmpty) queryParams['provincia'] = provincia;
    if (tipoAlojamiento != null && tipoAlojamiento.isNotEmpty) queryParams['tipoAlojamiento'] = tipoAlojamiento;
    if (precioMin != null && precioMin > 0) queryParams['precioMin'] = precioMin;
    if (precioMax != null && precioMax > 0) queryParams['precioMax'] = precioMax;
    if (calificacion != null && calificacion > 0) queryParams['calificacion'] = calificacion;

    print('🔍 Enviando parámetros filtrados: $queryParams');

    final response = await _dio.get(
      baseUrl,
      queryParameters: queryParams,
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = response.data;
      return data.map((e) => Alojamiento.fromJson(e)).toList();
    } else {
      throw Exception('Error al obtener alojamientos filtrados: ${response.statusCode}');
    }
  } catch (e) {
    throw Exception('Error al conectar con el servidor: $e');
  }
}




  // Obtener alojamiento con sus fotos
  Future<Map<String, dynamic>> getAlojamientoConFotos(String id) async {
    try {
      final alojamiento = await getAccommodation(id);
      final fotos = await getPhotosAccommodations(id);

      return {
        'alojamiento': alojamiento,
        'fotos': fotos,
      };
    } catch (e) {
      //print('❌ Error al obtener alojamiento con fotos: $e');
      throw Exception('Error al obtener alojamiento con fotos: $e');
    }
  }

}