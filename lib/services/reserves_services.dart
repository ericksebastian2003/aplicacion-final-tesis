import 'package:desole_app/data/models/Reservas.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
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
Future<bool> updateReservationsForGuest(String idReserva, Reservas reservaActualizada) async{
  try{
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    _dio.options.headers['Authorization'] = 'Bearer $token';
    final response = await _dio.put(
      'https://hospedajes-4rmu.onrender.com/api/reservas/actualizar/$idReserva',
      data: reservaActualizada.toJsonForUpdateGuest(),
    );

   print('📝 Actualizando : $idReserva');
    print('📦 Body: ${reservaActualizada}');
    print('📤 Status: ${response.statusCode}');
    return response.statusCode == 200;
  } catch (e) {
    print('❌ Error al actualizar: $e');
    return false;
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


}