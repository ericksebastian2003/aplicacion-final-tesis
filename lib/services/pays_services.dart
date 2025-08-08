import 'package:desole_app/data/models/Pagos.dart';
import 'package:desole_app/data/models/PagosAnfitriones.dart';
import 'package:desole_app/data/models/PagosHuespedes.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';

class PaysServices {
  final String baseUrl = 'https://hospedajes-4rmu.onrender.com/api';
  final Dio dio = Dio();


Future<Map<String, dynamic>?> createPay(String idReserva) async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      return {'success': false, 'msg': 'Token no encontrado'};
    }

    dio.options.headers['Authorization'] = 'Bearer $token';

    final response = await dio.post('$baseUrl/pagos/$idReserva');

    final backendMsg = response.data['msg'] ?? 'No se recibió mensaje del backend';
    print(backendMsg);
    if (response.statusCode == 201) {
      return {'success': true, 'msg': backendMsg};
    } else {
      return {'success': false, 'msg': backendMsg};
    }
  } catch (e) {
    return {'success': false, 'msg': 'Error al procesar el pago: $e'};
  }
}

Future<List<PagosHuespedes>> getPagosByHuesped() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      print('❌ [ERROR] Token no encontrado');
      return [];
    }

    dio.options.headers['Authorization'] = 'Bearer $token';

    final response = await dio.get('$baseUrl/pagos/huesped/pagos');

    if (response.statusCode == 200 && response.data['pagos'] != null) {
      final List<dynamic> pagosJson = response.data['pagos'];
      List<PagosHuespedes> pagosList = pagosJson.map((p) => PagosHuespedes.fromJson(p)).toList();
      return pagosList;
    } else {
      print('❌ [ERROR] El formato del JSON no contiene una lista de pagos');
      return [];
    }
  } catch (e) {
    print('❌ [EXCEPCIÓN getPagosByHuesped] => $e');
    return [];
  }
}

Future<List<PagosAnfitriones>> getPagosPorReserva(String idReserva) async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    dio.options.headers['Authorization'] = 'Bearer $token';

    final response = await dio.get('$baseUrl/pagos/$idReserva');
    print('$baseUrl/pagos/$idReserva');


    if (response.statusCode == 200) {
      final data = response.data;

      // Si `data` es una lista
      if (data is List) {
        return data.map((e) => PagosAnfitriones.fromJson(e)).toList();
      }

      // Si es un solo pago (objeto único)
      return [PagosAnfitriones.fromJson(data)];
    } else {
      print('❌ [ERROR] Estado no 200');
      return [];
    }
  } catch (e) {
    print('❌ [EXCEPCIÓN getPagosPorReserva] => $e');
    return [];
  }
}
}