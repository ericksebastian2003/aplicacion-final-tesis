import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
import 'dart:io';
class UsersServices {
  final Dio _dio = Dio();
  Future<Map<String , dynamic>?> getUserProfile() async{
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      
  print('⏳ Cargando perfil...');
  print('🔐 Token: $token');
  print('🆔 ID guardado: ${prefs.getString('userId')}');


      print('token $token');
      if(token == null) return null;


      _dio.options.headers['Authorization'] = 'Bearer $token';
       try{
        final response = await _dio.get(
          'https://hospedajes-4rmu.onrender.com/api/usuarios/perfil'
        );
        print('✅ Código de respuesta: ${response.statusCode}');
    print('📥 Respuesta del servidor: ${response.data}');
        if(response.statusCode == 200){
          final user = response.data;
          print('Usuario es : $user');
          if (user != null) {
          return Map<String, dynamic>.from(user);
        } else {
          return Map<String, dynamic>.from(user); // si no hay "usuario"
        }

        }
       }
       catch(e){
            print('❌ Error al obtener perfil: $e');       
        }
        return null;
  }


 Future<String?> updateUserProfile(Map<String, dynamic> updateData) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final userId = prefs.getString('userId');

    print('Token: $token');
    print('User ID: $userId');

    if (token == null || userId == null) {
      return 'Error: Token o ID de usuario no encontrados.';
    }

    _dio.options.headers['Authorization'] = 'Bearer $token';

    try {
      final response = await _dio.put(
        'https://hospedajes-4rmu.onrender.com/api/usuarios/usuario/$userId',
        data: updateData,
      );

      // Verificamos si la respuesta contiene un mensaje en caso de éxito.
      if (response.statusCode == 200 && response.data is Map && response.data.containsKey('msg')) {
        return response.data['msg']; // Retorna el mensaje del backend.
      }

      return 'Perfil actualizado correctamente.'; // Mensaje por defecto en caso de éxito.
    } on DioException catch (e) {
      print('❌ Error actualizando perfil (DioException): $e');
      // Verificamos si la respuesta de error contiene un mensaje.
      if (e.response != null && e.response!.data is Map && e.response!.data.containsKey('msg')) {
        return e.response!.data['msg'];
      }
      return 'Error al conectar con el servidor.'; // Mensaje genérico para error de Dio.
    } catch (e) {
      print('❌ Error actualizando perfil: $e');
      return 'Ocurrió un error inesperado.'; // Mensaje genérico para cualquier otro error.
    }
  }

Future<Map<String, dynamic>?> getBalanceForHost() async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('token');

  if (token == null) return null;

  _dio.options.headers['Authorization'] = 'Bearer $token';

  try {
    final response = await _dio.get('https://hospedajes-4rmu.onrender.com/api/pagos/anfitrion/saldo');

    if (response.statusCode == 200) {
      final data = response.data;
      if (data != null) {
        // Retornas todo el mapa con saldoGenerado y pagos
        return Map<String, dynamic>.from(data);
      }
    }
  } catch (e) {
    print('❌ Error al obtener perfil: $e');
  }
  return null;
}





  Future<bool> uploadProfileImage (File? profileImage) async{
      if (profileImage == null) return false;

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final idUser = prefs.getString('userId');

    final _dio = Dio();
    _dio.options.headers['Authorization'] = 'Bearer $token';
    try {
    final fileName = profileImage.path.split('/').last;

    final formData = FormData.fromMap({
      'fotoPerfil': await MultipartFile.fromFile(
        profileImage.path,
        filename: fileName,
      ),
    });
    
      final response = await _dio.post('https://hospedajes-4rmu.onrender.com/api/usuarios/perfil/foto/$idUser' , data: formData,
      );
      // print(response);
      return response.statusCode == 200;
    }
  
    catch(e){
      
      // print('Error actualizando la foto de perfil: $e');
      return false;

    }

  }
  Future<bool> deleteProfileImage() async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('token');

  print('📦 Token encontrado en SharedPreferences: $token');

  if (token == null) {
    print('❌ Token no encontrado. Cancelando operación.');
    return false;
  }

  final dio = Dio();
  dio.options.headers['Authorization'] = 'Bearer $token';
  dio.options.headers['Content-Type'] = 'application/json';

  try {
    print('📤 Enviando solicitud DELETE a: https://hospedajes-4rmu.onrender.com/api/usuarios/perfil/foto/borrar');
    print('🧾 Headers: ${dio.options.headers}');

    final response = await dio.delete(
      'https://hospedajes-4rmu.onrender.com/api/usuarios/perfil/foto/borrar',
    );

    print('✅ Código de respuesta: ${response.statusCode}');
    print('📨 Cuerpo de respuesta: ${response.data}');

    return response.statusCode == 200;
  } catch (e) {
    if (e is DioException) {
      print('❌ DioException atrapada');
      print('📛 Código de error: ${e.response?.statusCode}');
      print('📨 Cuerpo de error: ${e.response?.data}');
      print('🧾 Headers de error: ${e.response?.headers}');
    } else {
      print('❌ Error inesperado: $e');
    }
    return false;
  }
}
Future<Map<String, dynamic>> depositBalance(Map<String, dynamic> dataBalance) async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('token');
  final userId = prefs.getString('userId');
  if (token == null || userId == null) return {'success': false, 'msg': 'Token o userId no encontrado'};

  _dio.options.headers['Authorization'] = 'Bearer $token';

  try {
    final response = await _dio.post(
      'https://hospedajes-4rmu.onrender.com/api/usuarios/depositar/$userId',
      data: dataBalance,
    );
    print("Reespuesta reponse ${response}");

    if (response.statusCode == 200) {
      return {
        'success': true,
        'msg': response.data['msg'] ?? 'Depósito exitoso',
      };
    } else {
      return {
        'success': false,
        'msg': response.data['msg'] ?? 'Error en el depósito',
      };
    }
  } catch (e) {
    print('Error en realizar el deposito: $e');
    return {
      'success': false,
      'msg': 'Error inesperado al realizar el depósito',
    };
  }
}
}