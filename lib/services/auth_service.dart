import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final Dio _dio =Dio(
    BaseOptions(
      baseUrl: 'https://hospedajes-4rmu.onrender.com/api/usuarios',
      headers: {
        'Content-Type' : 'application/json',
      }
    )

  );

  // Método para login
  Future<Map<String, dynamic>?> loginUser(String email, String password) async {
  try {
    final data ={
      'email': email, 
      'password': password
    };

    //print('📨 Body: $data');

    final response = await _dio.post('/login' , data : data);

    //print('🔙 Código de estado: ${response.statusCode}');
    //print('📬 Respuesta: ${response.data}');


    if (response.statusCode == 200) {
      return response.data;
    } else if (response.statusCode == 401) {
      return {'msg': 'Credenciales incorrectas'};
    } else {
      return {'msg': 'Error inesperado: ${response.statusCode}'};
    }
  }
  on DioException catch(e) {
  print('❌ DioException: ${e.message}');
  if (e.response != null) {
    //print('❌ Código de estado (error): ${e.response?.statusCode}');
    //print('❌ Respuesta del servidor: ${e.response?.data}');
    return {
      'status': 'error',
      'message': e.response?.data['msg'] ?? 'Error desconocido',
      'code': e.response?.statusCode
    };
  }
  return {'status': 'error', 'message': 'Error de conexión: ${e.message}'};
}

  catch (e) {
    //print('❌ Excepción durante la conexión: $e');
    return {'error': 'Error de conexión: $e'};
  }
}


  // Método para registrar usuario
  Future<Map<String, dynamic>> register(Map<String, String> userData) async {
  try {
    if (userData['email'] == null || userData['password'] == null) {
      return {'status': 'error', 'msg': 'Campos vacíos'};
    }

    final response = await _dio.post(
      '/registro',
      data: userData,
      options: Options(
          headers: {'Content-Type': 'application/json'},
        ),
    );

    //print('🔙 Código de estado: ${response.statusCode}');
    //print('📬 Respuesta: ${response.data}');
    //print('📦 Headers: ${response.headers}');

    if (response.statusCode == 201) {
      final msg = response.data['msg'] ;
      return {'status': 'success', 'msg': msg};    } else {
      return {'status': 'error', 'msg': 'Error al registrar usuario'};
    }
  } 
  on DioException catch(e) {
  //print('❌ DioException: ${e.message}');
  if (e.response != null) {
    //print('❌ Código de estado (error): ${e.response?.statusCode}');
    //print('❌ Respuesta del servidor: ${e.response?.data}');
    return {
      'status': 'error',
      'msg': e.response?.data['msg'] ?? 'Error desconocido',
      'code': e.response?.statusCode
    };
  }
  return {'status': 'error', 'msg': 'Error de conexión: ${e.message}'};
}

  catch (e) {
    return {'status': 'error', 'msg': 'Error: ${e.toString()}'};
  }
}
   // Método para cerrar sesión
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('_usuario');
    await prefs.remove('token');
    //print('✅ Usuario ha cerrado sesión correctamente');
  }
  // Obtener el nombre del usuario logueado
  Future<String?> getLoggedUserName() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString('_usuario');
    if (userJson != null) {
      final user = jsonDecode(userJson);
      return user['nombre'];
    }
    return null;
  }

  // Obtener el rol del usuario logueado
  Future<String?> getUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString('_usuario');
    if (userJson != null) {
      final user = jsonDecode(userJson);
      List<dynamic> roles = user['rol'];
      return roles.isNotEmpty ? roles[0] : null;
    }
    return null;
  }

   Future<Map<String, dynamic>?> recuperarPassword(String email) async {
  final Dio _dio = Dio();

  try {
    final response = await _dio.post(
      'https://hospedajes-4rmu.onrender.com/api/usuarios/recuperar-password',
      data: {'email': email},
    );

    // Devuelve el mapa con mensaje y estado
    return response.data;
  } catch (e) {
    print('Error enviando solicitud de recuperación: $e');
    return {
      'status': 'error',
      'msg': 'Error al enviar la solicitud. Verifica el correo o intenta más tarde.'
    };
  }
}

Future<bool> updatePassword(String token ,  String password) async {
  

  final Dio _dio = Dio();
  _dio.options.headers['Authorization'] = 'Bearer $token';

  try {
    final response = await _dio.post(
      'https://hospedajes-4rmu.onrender.com/api/usuarios/recuperar-password/$token',
      data: {
        'password': password,
      },
    );

    return true;
  } catch (e) {
    print('Error actualizando la contraseña: $e');
    return false;
  }
}


}