import 'dart:async';

import 'package:desole_app/data/models/Alojamientos.dart';
import 'package:desole_app/data/models/FotoAlojamientos.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';


class AccomodationServices {
  final Dio _dio = Dio();
  final String baseUrl = "https://hospedajes-4rmu.onrender.com/api/alojamientos";
  AccomodationServices() {
    // Interceptor para agregar el token Authorization en cada solicitud
    _dio.interceptors.add(InterceptorsWrapper(
  onRequest: (options, handler) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    print('👉 PETICIÓN: ${options.method} ${options.uri}');
    print('👉 Headers antes del token: ${options.headers}');

    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
      print('🔐 Se agregó el token: $token');
    } else {
      print('❌ No se encontró token en SharedPreferences');
    }

    return handler.next(options);
  },
  onResponse: (response, handler) {
    print('✅ RESPUESTA [${response.statusCode}]: ${response.requestOptions.uri}');
    print('📦 Body: ${response.data}');
    return handler.next(response);
  },
  onError: (DioError e, handler) {
    print('❗ ERROR EN LA RESPUESTA:');
    print('🔗 URI: ${e.requestOptions.uri}');
    print('📥 HEADERS: ${e.requestOptions.headers}');
    print('📤 BODY: ${e.response?.data}');
    print('🧾 STATUS CODE: ${e.response?.statusCode}');
    return handler.next(e);
  },
));
  }

  
Future<Alojamiento> getAccommodationById(String id) async {
  try {
    final response = await _dio.get('$baseUrl/ver/$id');
    print("🟢 Respuesta del servidor: ${response.data}");

    if (response.statusCode == 200) {
      final data = response.data;
      if (data != null) {
        return Alojamiento.fromJson(data); // <- Aquí usamos directamente el JSON plano
      } else {
        throw Exception('El alojamiento no fue encontrado.');
      }
    } else {
      throw Exception('Error al obtener alojamiento: ${response.statusCode}');
    }
  } catch (e) {
    print("❌ Error al obtener detalle del alojamiento: $e");
    throw Exception('Error al obtener alojamiento: $e');
  }
}


  // Obtener alojamientos creados por un anfitrión específico (filtrado por hostId)
  /*Future<List<Alojamiento>> getAccommodationsByHostId(String hostId) async {
    try {
      final response = await _dio.get(baseUrl);
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;

        // Filtrar alojamientos por anfitrión ID
        final filtered = data.where((json) {
          final anfitrion = json['anfitrion'];
          return anfitrion != null && anfitrion['_id'] == hostId;
        }).toList();

        return filtered.map((json) {
          return Alojamiento(
            id: json['id'] ?? '',
            titulo: json['titulo'] ?? '',
            descripcion: json['descripcion'] ?? '',
            tipoAlojamiento: json['tipoAlojamiento'] ?? '',
            precioNoche: json['precioNoche'] ?? 0,
            maxHuespedes: json['maxHuespedes'] ?? 0,
            ciudad: json['ciudad'] ?? '',
            provincia: json['provincia'] ?? '',
            pais: json['pais'] ?? '',
            direccion: json['direccion'] ?? '',
            anfitrion: json['anfitrion']?['nombre'] ?? '',
          );
        }).toList();
      } else {
        throw Exception('Error en la respuesta del servidor: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error al cargar alojamientos por anfitrión: $e');
    }
  }
*/
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
      print(token);
      _dio.options.headers['Authorization'] = 'Bearer $token';

      final response = await _dio.delete('https://hospedajes-4rmu.onrender.com/api/alojamientos/borrar/$id');

      return response.statusCode == 200;
    } catch (e) {
      print('Error en deleteAccommodation: $e');
      return false;
    }
  }


  // Obtener todos los alojamientos
  Future<List<Alojamiento>> getAccommodations() async {
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

  Future<List<FotosAlojamientos>> getPhotosAccomadations(String id) async {
  final url = 'https://hospedajes-4rmu.onrender.com/api/alojamientos/fotos/$id';
  print('🔍 Llamando a: $url');

  try {
    final response = await _dio.get(url);

    print('📥 Respuesta completa: ${response.data}');
    if (response.statusCode == 200) {
      final List<dynamic> data = response.data;
      print('📸 Número de fotos recibidas: ${data.length}');
      return data.map((json) => FotosAlojamientos.fromJson(json)).toList();
    } else {
      print('⚠️ Código de estado inesperado: ${response.statusCode}');
      throw Exception('Error en la respuesta del servidor: ${response.statusCode}');
    }
  } catch (e) {
    print('❌ Error al cargar las fotos de los alojamientos: $e');
    throw Exception('Error al cargar las fotos de los alojamientos: $e');
  }
  
}
//ERliminar la fotografia del alojamiento
Future<bool> deletePhotos(String idFoto) async{
  try{
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';
    _dio.options.headers['Authorization'] = 'Bearer $token';
    final response = await _dio.delete('https://hospedajes-4rmu.onrender.com/api/alojamientos/fotos/$idFoto');
     print('🗑️ Eliminando foto ID: $idFoto');
    print('📤 Status: ${response.statusCode}');
    return response.statusCode == 200;
  }
  catch(e){
    print('❌ Error al eliminar la foto: $e');
    return false;
  }
}
//Actualizar foto del alojamiento
Future<bool> updatePhoto(String idFoto , FotosAlojamientos fotoActualizada) async{
  try{
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    _dio.options.headers['Authorization'] = 'Bearer $token';
    final response = await _dio.put(
      'https://hospedajes-4rmu.onrender.com/api/alojamientos/fotos/$idFoto',
      data: fotoActualizada.toJson(),
    );

   print('📝 Actualizando foto ID: $idFoto');
    print('📦 Body: ${fotoActualizada.toJson()}');
    print('📤 Status: ${response.statusCode}');
    return response.statusCode == 200;
  } catch (e) {
    print('❌ Error al actualizar la foto: $e');
    return false;
  }
}

 
}