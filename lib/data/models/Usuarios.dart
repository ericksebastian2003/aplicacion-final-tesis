class Usuarios {
  final String id;
  final List<String> rol;
  final String nombre;
  final String apellido;
  final String email;
  final String telefono;
  final String? urlFotoPerfil;
  final String estadoCuenta;
  final double saldo;

  Usuarios({
    required this.id,
    required this.rol,
    required this.nombre,
    required this.apellido,
    required this.email,
    required this.telefono,
    this.urlFotoPerfil,
    required this.estadoCuenta,
    required this.saldo,
  });

  factory Usuarios.fromJson(Map<String, dynamic> json) {
    return Usuarios(
      id: json['_id'] ?? '',
      rol: List<String>.from(json['rol'] ?? []),
      nombre: json['nombre'] ?? '',
      apellido: json['apellido'] ?? '',
      email: json['email'] ?? '',
      telefono: json['telefono'] ?? '',
      urlFotoPerfil: json['urlFotoPerfil'],
      estadoCuenta: json['estadoCuenta'] ?? '',
      saldo: (json['saldo'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'rol': rol,
      'nombre': nombre,
      'apellido': apellido,
      'email': email,
      'telefono': telefono,
      'urlFotoPerfil': urlFotoPerfil,
      'estadoCuenta': estadoCuenta,
      'saldo': saldo,
    };
  }
}
