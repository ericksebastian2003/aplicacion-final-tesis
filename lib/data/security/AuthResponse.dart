class LoginResponse {
  final String token;
  final UserBasic usuario;

  LoginResponse({
    required this.token,
    required this.usuario,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      token: json['token'] ?? '',
      usuario: UserBasic.fromJson(json['usuario'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'token': token,
      'usuario': usuario.toJson(),
    };
  }
}

class UserBasic {
  final String id;
  final String nombre;
  final String apellido;
  final String email;
  final List<String> rol;
  final String? urlFotoPerfil;

  UserBasic({
    required this.id,
    required this.nombre,
    required this.apellido,
    required this.email,
    required this.rol,
    this.urlFotoPerfil,
  });

  factory UserBasic.fromJson(Map<String, dynamic> json) {
    return UserBasic(
      id: json['_id'] ?? '',
      nombre: json['nombre'] ?? '',
      apellido: json['apellido'] ?? '',
      email: json['email'] ?? '',
      rol: List<String>.from(json['rol'] ?? []),
      urlFotoPerfil: json['urlFotoPerfil'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'nombre': nombre,
      'apellido': apellido,
      'email': email,
      'rol': rol,
      'urlFotoPerfil': urlFotoPerfil,
    };
  }
}
