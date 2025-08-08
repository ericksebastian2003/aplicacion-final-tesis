class Anfitrion {
  final String id;
  final String nombre;

  Anfitrion({
    required this.id,
    required this.nombre,
  });

  factory Anfitrion.fromJson(Map<String, dynamic> json) {
    return Anfitrion(
      id: json['_id'] ?? '',
      nombre: json['nombre'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'nombre': nombre,
    };
  }
}
