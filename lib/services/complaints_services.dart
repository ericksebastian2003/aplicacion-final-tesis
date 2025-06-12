import 'dart:convert';

import 'package:desole_app/data/models/Reportes.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
class ComplaintsServices {
  final Dio _dio = Dio();

  // Obtener reportes para el admin
  Future<List<Reportes>> getComplaintsForAdmin(String tipo) async {
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
        'https://hospedajes-4rmu.onrender.com/api/reportes?tipo=$tipo',
      );

      print('✅ [RESPONSE STATUS] => ${response.statusCode}');
      print('📥 [RESPONSE DATA] => ${response.data}');

      if (response.statusCode == 200) {
        final List<dynamic> reportes = response.data;

        final reportesList =
            reportes.map((json) => Reportes.fromJson(json)).toList();

        print('✅ [REPORTES PARSEADOS] => ${reportesList.length}');
        return reportesList;
      }
    } catch (e, stackTrace) {
      print('❌ [EXCEPTION] $e');
      print('📌 [STACKTRACE] $stackTrace');
    }

    return [];
  }

  // Cambiar estado del reporte
  Future<bool> changeStatusComplaints(String idReporte) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';
      _dio.options.headers['Authorization'] = 'Bearer $token';

      final response = await _dio.put(
        'https://hospedajes-4rmu.onrender.com/api/reportes/estado/$idReporte',
      );

      print('📤 Cambiar estado ID: $idReporte');
      print('📤 Status: ${response.statusCode}');

      return response.statusCode == 200;
    } catch (e) {
      print('❌ Error al cambiar el estado del reporte: $e');
      return false;
    }
  }

  // Crear reporte como huésped
  Future<bool> createComplaintsForGuest(Map<String, dynamic> data) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        print('❌ [ERROR] No se encontró el token');
        return false;
      }

      _dio.options.headers['Authorization'] = 'Bearer $token';

      final response = await _dio.post(
        'https://hospedajes-4rmu.onrender.com/api/reportes/crear',
        data: data,
      );

      print('📦 Body: $data');
      print('📤 Status: ${response.statusCode}');

      return response.statusCode == 200;
    } catch (e) {
      print('❌ Error al crear el reporte: $e');
      return false;
    }
  }


  // Obtener reportes para el huesped
  Future<List<Reportes>> getComplaintsForGuest() async {
try {
  final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

    
      _dio.options.headers['Authorization'] = 'Bearer $token';
  final response = await _dio.get('https://hospedajes-4rmu.onrender.com/api/reportes/usuario'); // Ajusta el endpoint real

      print("✅ [RESPONSE STATUS] => ${response.statusCode}");
      print("📥 [RESPONSE DATA] => ${response.data}");
  
     final List<dynamic> jsonList =
        jsonDecode(jsonEncode(response.data));

    print("🧩 [PARSED JSON LIST] => $jsonList");

    final reportesList = jsonList
        .map((json) => Reportes.fromJson(json))
        .toList();

    print("📦 [REPORTES LIST LENGTH] => ${reportesList.length}");

    return reportesList;
  } catch (e, stacktrace) {
    print("❌ [EXCEPTION] ${e.toString()}");
    print("📌 [STACKTRACE] $stacktrace");
    throw Exception("Error al obtener reportes");
  }
}
}