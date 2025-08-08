import 'package:desole_app/data/models/Calificacion.dart';
import 'package:desole_app/data/models/Reservas.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
class ReservesServices {
  final Dio _dio = Dio();

  Future<List<Reservas>> getReservationsForAdmin() async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('token');

  print('🔐 [TOKEN] => $token');

  if (token == null) {
    print('❌ [ERROR] No se encontró el token');
    return [];
  }

  _dio.options.headers['Authorization'] = 'Bearer $token';

  try {
    final response = await _dio.get(
      'https://hospedajes-4rmu.onrender.com/api/reservas',
    );

    print('✅ [RESPONSE STATUS] => ${response.statusCode}');
    print('📥 [RESPONSE DATA] => ${response.data}');

    if (response.statusCode == 200) {
      final List<dynamic> reservasJson = response.data;

      print('🔄 [MAPPED RESERVAS]');
      for (var i = 0; i < reservasJson.length; i++) {
        print('👉 Reserva #$i => ${reservasJson[i]}');
      }

      final reservasList = reservasJson.map((json) => Reservas.fromJson(json)).toList();

      print('✅ [FINAL RESERVAS PARSEADAS] => ${reservasList.length}');
      return reservasList;
    }
  } catch (e, stackTrace) {
    print('❌ [EXCEPTION] $e');
    print('📌 [STACKTRACE] $stackTrace');
  }

  return [];
}
  Future<List<Reservas>> getReservationsForHost() async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('token');

  print('🔐 [TOKEN] => $token');

  if (token == null) {
    print('❌ [ERROR] No se encontró el token');
    return [];
  }

  _dio.options.headers['Authorization'] = 'Bearer $token';

  try {
    final response = await _dio.get(
      'https://hospedajes-4rmu.onrender.com/api/reservas/anfitrion',
    );

    print('✅ [RESPONSE STATUS] => ${response.statusCode}');
    print('📥 [RESPONSE DATA] => ${response.data}');

    if (response.statusCode == 200) {
      final List<dynamic> reservasJson = response.data;

      print('🔄 [MAPPED RESERVAS]');
      for (var i = 0; i < reservasJson.length; i++) {
        print('👉 Reserva #$i => ${reservasJson[i]}');
      }

      final reservasList = reservasJson.map((json) => Reservas.fromJson(json)).toList();

      print('✅ [FINAL RESERVAS PARSEADAS] => ${reservasList.length}');
      return reservasList;
    }
  } catch (e, stackTrace) {
    print('❌ [EXCEPTION] $e');
    print('📌 [STACKTRACE] $stackTrace');
  }

  return [];
}
  Future<List<Calificacion>> getScoreForGuest(String idAlojamiento) async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('token');

  print('🔐 [TOKEN] => $token');

  if (token == null) {
    print('❌ [ERROR] No se encontró el token');
    return [];
  }

  _dio.options.headers['Authorization'] = 'Bearer $token';

  try {
    final response = await _dio.get(
      'https://hospedajes-4rmu.onrender.com/api/calificacion/$idAlojamiento',
    );

    print('✅ [RESPONSE STATUS] => ${response.statusCode}');
    print('📥 [RESPONSE DATA] => ${response.data}');

    if (response.statusCode == 200) {
      final List<dynamic> califcaciones = response.data;

      final calificacionesList = califcaciones
          .map((json) => Calificacion.fromJson(json))
          .toList();

      print('✅ [Calificaciones parseadas] => ${calificacionesList.length}');
      return calificacionesList;
    }
  } catch (e, stackTrace) {
    print('❌ [EXCEPTION] $e');
    print('📌 [STACKTRACE] $stackTrace');
  }

  return [];
}


  Future<List<Reservas>> getReservationsForGuest() async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('token');

  print('🔐 [TOKEN] => $token');

  if (token == null) {
    print('❌ [ERROR] No se encontró el token');
    return [];
  }

  _dio.options.headers['Authorization'] = 'Bearer $token';

  try {
    final response = await _dio.get(
      'https://hospedajes-4rmu.onrender.com/api/reservas/huesped',
    );

    print('✅ [RESPONSE STATUS] => ${response.statusCode}');
    print('📥 [RESPONSE DATA] => ${response.data}');

    if (response.statusCode == 200) {
      final List<dynamic> reservasJson = response.data;

      print('🔄 [MAPPED RESERVAS]');
      for (var i = 0; i < reservasJson.length; i++) {
        print('👉 Reserva #$i => ${reservasJson[i]}');
      }

      final reservasList = reservasJson.map((json) => Reservas.fromJson(json)).toList();

      print('✅ [FINAL RESERVAS PARSEADAS] => ${reservasList.length}');
      return reservasList;
    }
  } catch (e, stackTrace) {
    print('❌ [EXCEPTION] $e');
    print('📌 [STACKTRACE] $stackTrace');
  }

  return [];
}
//Elimnar los reservas
Future<bool> delereservations(String idReserva) async{
  try{
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';
    _dio.options.headers['Authorization'] = 'Bearer $token';
    final response = await _dio.delete('https://hospedajes-4rmu.onrender.com/api/reservas/borrar/$idReserva');
     print('🗑️ Eliminando foto ID: $idReserva');
    print('📤 Status: ${response.statusCode}');
    return response.statusCode == 200;
  }
  catch(e){
    print('❌ Error al eliminar la foto: $e');
    return false;
  }
}
Future<String?> updateReservationsForGuest(String idReserva, Map<String, dynamic> updateData) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        return 'Error: Token de autenticación no encontrado.';
      }
      
      _dio.options.headers['Authorization'] = 'Bearer $token';

      final response = await _dio.put(
        'https://hospedajes-4rmu.onrender.com/api/reservas/actualizar/$idReserva',
        data: updateData,
      );

      print('📝 Actualizando: $idReserva');
      print('📦 Body: $updateData');
      print('📤 Status: ${response.statusCode}');
      print('📩 Respuesta: ${response.data}');

      // ✅ CLAVE: Verificamos si la respuesta exitosa tiene un campo 'msg'
      if (response.statusCode == 200 && response.data is Map && response.data.containsKey('msg')) {
        return response.data['msg'];
      }
      
      return 'Reserva actualizada correctamente.'; // Mensaje de éxito por defecto

    } on DioException catch (e) {
      print('❌ Error de Dio al actualizar reserva: $e');
      // ✅ CLAVE: Verificamos si el error tiene un campo 'msg'
      if (e.response != null && e.response!.data is Map && e.response!.data.containsKey('msg')) {
        return e.response!.data['msg'];
      }
      return 'Error al conectar con el servidor.';
    } catch (e) {
      print('❌ Error inesperado al actualizar reserva: $e');
      return 'Ocurrió un error inesperado.';
    }
  }
Future<bool> updateReservationsForHost(String idReserva, Reservas reservationUpdate) async{
  try{
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    _dio.options.headers['Authorization'] = 'Bearer $token';
    final response = await _dio.put(
      'https://hospedajes-4rmu.onrender.com/api/reservas/actualizar/$idReserva',
      data: reservationUpdate.toJsonForUpdateHost(),
    );

   print('📝 Actualizando ID: $idReserva');
    print('📦 Body: ${reservationUpdate}');
    print('📤 Status: ${response.statusCode}');
    return response.statusCode == 200;
  } catch (e) {
    print('❌ Error al actualizar : $e');
    return false;
  }
}
//Calificar alojamientos
Future<dynamic> qualifyreservationsForGuest(String idReserva, Map<String, dynamic> data) async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    _dio.options.headers['Authorization'] = 'Bearer $token';
    _dio.options.headers['Content-Type'] = 'application/json';

    print('📝 ID Reserva: $idReserva');
    print('📦 Datos a enviar: $data');

    final response = await _dio.post(
      'https://hospedajes-4rmu.onrender.com/api/calificacion/crear/$idReserva',
      data: data,
    );

    print('📤 Status: ${response.statusCode}');
    print('📥 Response: ${response.data}');

    if (response.statusCode == 200 || response.statusCode == 201) {
      // Si se incluye detalle de la reserva en la respuesta
      return {
        'success': true,
        'detalle': response.data['detalleReserva'] ?? null,
        'msg': response.data['msg'] ?? 'Calificación enviada correctamente.',
      };
    } else {
      return {
        'success': false,
        'msg': response.data['msg'] ?? 'Error desconocido al calificar.',
      };
    }
  } on DioException catch (e) {
    print('❌ DioException al calificar: $e');

    final msg = e.response?.data is Map && e.response?.data['msg'] != null
        ? e.response?.data['msg']
        : e.message ?? 'Error inesperado al calificar';

    return {
      'success': false,
      'msg': msg,
    };
  } catch (e) {
    print('❌ Error inesperado al calificar: $e');
    return {
      'success': false,
      'msg': e.toString(),
    };
  }
}




}