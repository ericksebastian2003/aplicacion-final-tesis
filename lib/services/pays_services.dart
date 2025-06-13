import 'package:desole_app/data/models/PagoResponmse.dart';
import 'package:desole_app/data/models/Pagos.dart';
import 'package:desole_app/data/models/PagosAnfitriones.dart';
import 'package:desole_app/data/models/PagosHuespedes.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
import 'package:desole_app/data/models/Reservas.dart';
  import 'dart:convert';

class PaysServices {
  final String baseUrl = 'https://hospedajes-4rmu.onrender.com/api';
  final Dio dio = Dio();


Future<PagoResponse?> createPay(String idReserva) async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      print('❌ [ERROR] Token no encontrado');
      return null;
    }

    dio.options.headers['Authorization'] = 'Bearer $token';

    print('📡 [CREATE PAY] Enviando solicitud POST a $baseUrl/pagos/$idReserva');
    print('🧾 [ID RESERVA] => $idReserva');

    final response = await dio.post('$baseUrl/pagos/$idReserva');

    print('📥 [STATUS CODE] => ${response.statusCode}');
    print('📦 [RESPONSE BODY] => ${response.data}');

    if (response.statusCode == 201) {
      final data = response.data is String ? jsonDecode(response.data) : response.data;

      final pagoResponse = PagoResponse.fromJson(data);

      print('✅ [MSG] => ${pagoResponse.msg}');
      print('💰 [MONTO TOTAL] => ${pagoResponse.pago.montoTotal}');
      print('🏠 [ALOJAMIENTO ID] => ${pagoResponse.pago.reserva}');
      
      return pagoResponse;
    } else {
      print('❌ [ERROR] Código de estado no esperado: ${response.statusCode}');
      return null;
    }
  } catch (e, stack) {
    print('❌ [ERROR DESCONOCIDO] => $e');
    print('📌 [STACKTRACE] => $stack');
    return null;
  }
}


  Future<List<Pagos>> getPagosComoAnfitrion() async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('token');
  final userId = prefs.getString('userId'); // ← importante que esté guardado

  if (token == null || userId == null) {
    print('❌ [ERROR] Token o userId no encontrados');
    return [];
  }

  dio.options.headers['Authorization'] = 'Bearer $token';

  try {
    final response = await dio.get('$baseUrl/pagos');

    if (response.statusCode == 200) {
      final List<dynamic> data = response.data['pagos'];
      final pagos = data.map((e) => Pagos.fromJson(e)).toList();
      final comoAnfitrion = pagos.where((p) => p.anfitrion == userId).toList();
      print('✅ [PAGOS COMO ANFITRIÓN] => ${comoAnfitrion.length}');
      return comoAnfitrion;
    } else {
      print('⚠️ [ERROR] Código de estado: ${response.statusCode}');
      return [];
    }
  } catch (e) {
    print('❌ [ERROR GET COMO ANFITRIÓN] => $e');
    return [];
  }
}

Future<List<PagosHuespedes>> getPagosByHuesped() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    dio.options.headers['Authorization'] = 'Bearer $token';

    final response = await dio.get('$baseUrl/pagos/huesped/pagos');

    if (response.statusCode == 200 && response.data['pagos'] != null) {
      final List<dynamic> pagosJson = response.data['pagos'];
      // Convertimos cada elemento JSON en un objeto PagosHuespedes
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