import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';

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
  Future<bool> updateUserProfile(Map<String , dynamic> updateData) async{
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final userId = prefs.getString('userId');
    if(token == null || userId == null) return false;
    final _dio = Dio();
    _dio.options.headers['Authorization'] = 'Bearer $token';

    try{
      final response = await _dio.put('https://hospedajes-4rmu.onrender.com/api/usuarios/usuario/$userId' , data: updateData,
      );
      return response.statusCode == 200;
    }
  
    catch(e){
      
      print('Error actualizando perfil: $e');

      return  false;
  }
  }
}