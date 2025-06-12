import 'package:desole_app/data/models/Pagos.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
import 'package:desole_app/data/models/Reservas.dart';

class PaysServices {
  final String baseUrl = 'https://hospedajes-4rmu.onrender.com/api';
  final Dio dio = Dio();

  Future<Pagos?> createPay(String idReserva) async {
    print('📡 [CREATE PAY] Iniciando solicitud de pago...');
    print('🧾 [ID RESERVA] => $idReserva');

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      print('❌ [ERROR] No se encontró el token en SharedPreferences');
      return null;
    }

    dio.options.headers['Authorization'] = 'Bearer $token';
    print('🔐 [TOKEN USADO] => $token');

    try {
      final response = await dio.post('$baseUrl/pagos/$idReserva');

      print('📥 [STATUS CODE] => ${response.statusCode}');
      print('📦 [RESPONSE BODY] => ${response.data}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final pago = Pagos.fromJson(response.data['pago']);
        print('✅ [PAGO CREADO] => ${pago.toJson()}');
        return pago;
      } else {
        print('⚠️ [ERROR] Respuesta inesperada del servidor (status code: ${response.statusCode})');
        return null;
      }
    } on DioException catch (dioError) {
      print('❌ [DIO ERROR] => ${dioError.message}');
      if (dioError.response != null) {
        print('📛 [DIO RESPONSE STATUS] => ${dioError.response?.statusCode}');
        print('📛 [DIO RESPONSE BODY] => ${dioError.response?.data}');
      }
      return null;
    } catch (e, stackTrace) {
      print('❌ [ERROR DESCONOCIDO] => $e');
      print('📌 [STACKTRACE] => $stackTrace');
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

Future<List<Pagos>> getPagosComoHuesped() async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('token');
  final userId = prefs.getString('userId');

  if (token == null || userId == null) {
    print('❌ [ERROR] Token o userId no encontrados');
    return [];
  }

  dio.options.headers['Authorization'] = 'Bearer $token';

  try {
    final response = await dio.get('$baseUrl/pagos');

    if (response.statusCode == 200) {
      print('📦 [RESPUESTA JSON] => ${response.data}');

      final data = response.data;

      if (data is List) {
        final pagos = data
            .whereType<Map<String, dynamic>>()
            .map((e) => Pagos.fromJson(e))
            .toList();

        // Filtrar pagos donde el id del huesped dentro de reserva coincide con userId
        final comoHuesped = pagos.where((pago) {
          final reserva = pago.reserva;
          // Asegurar que reserva y reserva.huesped no sean nulos
          if (reserva != null && reserva.huespedId != null) {
            return reserva.huespedId == userId;
          }
          return false;
        }).toList();

        print('✅ [PAGOS COMO HUÉSPED] => ${comoHuesped.length}');
        return comoHuesped;
      } else {
        print('❌ [ERROR] El formato del JSON no contiene una lista de pagos');
        return [];
      }
    } else {
      print('⚠️ [ERROR] Código de estado: ${response.statusCode}');
      return [];
    }
  } catch (e) {
    print('❌ [ERROR GET COMO HUÉSPED] => $e');
    return [];
  }
}
}