import 'package:desole_app/data/models/Usuarios.dart';

class AuthResponse {
  final Usuarios usuario;
  final String token;

  AuthResponse({required this.usuario, required this.token});

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      usuario: Usuarios.fromJson(json['usuario']),
      token: json['token'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'usuario': usuario.toJson(),
      'token': token,
    };
  }
}
