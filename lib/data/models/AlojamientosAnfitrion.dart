class AlojamientoAnfitrion {
  final String id;
  final String titulo;
  final int precioNoche;
  final String estadoAlojamiento;
  final double calificacionPromedio;
  final DateTime createdAt;

  AlojamientoAnfitrion({
    required this.id,
    required this.titulo,
    required this.precioNoche,
    required this.estadoAlojamiento,
    required this.calificacionPromedio,
    required this.createdAt,
  });

  factory AlojamientoAnfitrion.fromJson(Map<String, dynamic> json) {
    return AlojamientoAnfitrion(
      id: json['_id'] ?? '',
      titulo: json['titulo'] ?? '',
      precioNoche: json['precioNoche'] ?? 0,
      estadoAlojamiento: json['estadoAlojamiento'] ?? '',
      calificacionPromedio: (json['calificacionPromedio'] ?? 0).toDouble(),
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'titulo': titulo,
      'precioNoche': precioNoche,
      'estadoAlojamiento': estadoAlojamiento,
      'calificacionPromedio': calificacionPromedio,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
