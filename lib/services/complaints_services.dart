import 'dart:convert';
import 'package:desole_app/data/models/Reportes.dart';
import 'package:desole_app/data/models/ReportesAdmin.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
class ComplaintsServices {
  final Dio _dio = Dio();

 // Método corregido
  Future<List<ReporteAdmin>?> getComplaintsForAdmin(String tipoSeleccionado) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) return null;

      _dio.options.headers['Authorization'] = 'Bearer $token';

      final response = await _dio.get(
        'https://hospedajes-4rmu.onrender.com/api/reportes?tipo=$tipoSeleccionado',
      );

      print('✅ [RESPONSE STATUS] => ${response.statusCode}');
      print('📥 [RESPONSE DATA] => ${response.data}');

      if (response.statusCode == 200 && response.data is Map<String, dynamic> && response.data.containsKey('reportes')) {
        final reportesResponse = ReportesResponse.fromJson(response.data);
        return reportesResponse.reportes;
      }

      return null;
    } catch (e) {
      print('❌ [EXCEPTION] $e');
      return null;
    }
  }
Future<String?> changeStatusComplaints(String idReporte, String estado) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';

      if (token.isEmpty) {
        return 'Token de autenticación no encontrado. Vuelve a iniciar sesión.';
      }

      _dio.options.headers['Authorization'] = 'Bearer $token';

      final response = await _dio.put(
        'https://hospedajes-4rmu.onrender.com/api/reportes/estado/$idReporte',
        data: {
          'estado': estado
        }
      );
      print('📤 Cambiar estado ID: $idReporte');
      print('📤 Status: ${response.statusCode}');
      print('📩 Respuesta: ${response.data}');
      if (response.statusCode == 200 && response.data is Map && response.data.containsKey('msg')) {
        return response.data['msg']; // Devolver el mensaje del backend
      }
      
      return 'Estado actualizado correctamente.'; // Mensaje por defecto si no hay 'msg'
      
    } on DioException catch (e) {
      print('❌ Error de Dio al cambiar el estado del reporte: $e');
      // Devolvemos un mensaje de error del backend si está disponible
      if (e.response != null && e.response!.data is Map && e.response!.data.containsKey('msg')) {
        return e.response!.data['msg'];
      }
      return 'Error desconocido al cambiar el estado.';
    } catch (e) {
      print('❌ Error al cambiar el estado del reporte: $e');
      return 'Ocurrió un error inesperado.';
    }
  }



// Crear reporte como huésped
  Future<String?> createComplaintsForGuest(Map<String, dynamic> data) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token == null) return 'No se pudo autenticar. Vuelve a iniciar sesión.';

      _dio.options.headers['Authorization'] = 'Bearer $token';

      final response = await _dio.post(
        'https://hospedajes-4rmu.onrender.com/api/reportes/crear',
        data: data,
      );

      print('📦 Body: $data');
      print('📤 Status: ${response.statusCode}');
      print('📩 Respuesta: ${response.data}');

      if (response.data is Map && response.data.containsKey('msg')) {
        return response.data['msg'];
      }
      return null;
    } on DioException catch (e) {
      print('❌ Error de Dio al crear el reporte: $e');
      if (e.response != null && e.response!.data is Map && e.response!.data.containsKey('msg')) {
        // Devuelve el mensaje de error del servidor
        return e.response!.data['msg'];
      }
      return 'Error desconocido al crear el reporte';
    } catch (e) {
      print('❌ Error al crear el reporte: $e');
      return 'Error inesperado. Intenta de nuevo más tarde.';
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