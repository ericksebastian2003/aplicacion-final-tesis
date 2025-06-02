class Usuarios {
  final String id;
  final List<String> rol;
  final String nombre;
  final String apellido;
  final int cedula;
  final String email;
  final String? password;
  final String? urlFotoPerfil;
  final String? estadoCuenta;
  final int? saldoAnfitrion;
  final String token;
  final int telefono;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Usuarios({
    required this.id,
    required this.rol,
    required this.nombre,
    required this.apellido,
    required this.cedula,
    required this.email,
    this.password,
    this.urlFotoPerfil,
    this.estadoCuenta,
    this.saldoAnfitrion,
    required this.token,
    required this.telefono,
    this.createdAt,
    this.updatedAt,
  });

  factory Usuarios.fromJson(Map<String, dynamic> json) {
    return Usuarios(
      id: json['_id'] is Map ? json['_id']['\$oid'] ?? '' : json['_id'] ?? '',
      rol: json['rol'] is List
          ? List<String>.from(json['rol'])
          : [json['rol'].toString()],
      nombre: json['nombre'] ?? '',
      apellido: json['apellido'] ?? '',
      cedula: int.tryParse(json['cedula'].toString()) ?? 0,
      email: json['email'] ?? '',
      password: json['password'],
      urlFotoPerfil: json['urlFotoPerfil'],
      estadoCuenta: json['estadoCuenta'],
      saldoAnfitrion: json['saldoAnfitrion'] != null
          ? int.tryParse(json['saldoAnfitrion'].toString())
          : null,
      token: json['token'] ?? '',
      telefono: int.tryParse(json['telefono'].toString()) ?? 0,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(
              json['createdAt'] is Map
                  ? json['createdAt']['\$date']
                  : json['createdAt'].toString())
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(
              json['updatedAt'] is Map
                  ? json['updatedAt']['\$date']
                  : json['updatedAt'].toString())
          : null,
    );
  }

  Usuarios copyWith({
    String? id,
    String? nombre,
    String? email,
  }) {
    return Usuarios(
      id: id ?? this.id,
      rol: rol,
      nombre: nombre ?? this.nombre,
      apellido: apellido,
      cedula: cedula,
      email: email ?? this.email,
      password: password,
      urlFotoPerfil: urlFotoPerfil,
      estadoCuenta: estadoCuenta,
      saldoAnfitrion: saldoAnfitrion,
      token: token,
      telefono: telefono,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'rol': rol,
      'nombre': nombre,
      'apellido': apellido,
      'cedula': cedula,
      'email': email,
      'password': password,
      'urlFotoPerfil': urlFotoPerfil,
      'estadoCuenta': estadoCuenta,
      'saldoAnfitrion': saldoAnfitrion,
      'token': token,
      'telefono': telefono,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
}
