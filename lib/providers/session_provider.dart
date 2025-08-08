import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
class SessionProvider with ChangeNotifier {
  bool _isLoggedIn = false;
  bool _isSessionLoaded = false;
  String? _idUsuario;
  String? _email;
  String? _rol;
  String? _fullName;

  // Getters
  bool get isLoggedIn => _isLoggedIn;
  bool get isSessionLoaded => _isSessionLoaded;
  String? get idUsuario => _idUsuario;
  String? get email => _email;
  String? get rol => _rol;
  String? get fullName => _fullName;

Future<bool> validarUsuarioExistente(String idUsuario) async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('token');

  if (token == null) return false;

  final dio = Dio();
  dio.options.headers['Authorization'] = 'Bearer $token';

  try {
    final response = await dio.get('https://hospedajes-4rmu.onrender.com/api/usuarios/perfil');
    return response.statusCode == 200;
  } catch (e) {
    return false;
  }
}



  // Login
  void login(String idUsuario, String email, String fullName, String rol) {
    _isLoggedIn = true;
    _idUsuario = idUsuario;
    _email = email;
    _rol = rol;
    _fullName = fullName;
    saveSessionToPrefs(idUsuario, email, fullName, rol);
    notifyListeners();
  }

  // Cargar sesión desde SharedPreferences
  Future<void> loadSessionFromPrefs() async {
  final prefs = await SharedPreferences.getInstance();

  _isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
  _idUsuario = prefs.getString('userId');
  _email = prefs.getString('userEmail');
  _fullName = prefs.getString('userName');
  _rol = prefs.getString('userRole');

  // Validar que el usuario aún exista en el backend
  if (_isLoggedIn && _idUsuario != null) {
    final existe = await validarUsuarioExistente(_idUsuario!);
    if (!existe) {
      logout(); // Cierra sesión si no existe
    }
  }

  _isSessionLoaded = true;
  notifyListeners();
}


  // Cerrar sesión
  void logout() {
    _isLoggedIn = false;
    _idUsuario = null;
    _email = null;
    _fullName = null;
    _rol = null;
    clearSessionPrefs();
    notifyListeners();
  }

  // Guardar sesión en SharedPreferences
  Future<void> saveSessionToPrefs(String idUsuario, String email, String nombre, String rol) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', true);
    await prefs.setString('userId', idUsuario);
    await prefs.setString('userEmail', email);
    await prefs.setString('userName', nombre);
    await prefs.setString('userRole', rol);
  }

  // Limpiar SharedPreferences
  Future<void> clearSessionPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
