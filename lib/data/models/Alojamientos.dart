
class Alojamiento {
  final String id;
  final String titulo;
  final String? tipoAlojamiento; // opcional, porque no viene en JSON
  final double precioNoche;
  final int maxHuespedes; // coincide con el JSON: maxHuespedes
  final double calificacionPromedio;
  final String ciudad;
  final String provincia;
  final Anfitrion anfitrion;

  Alojamiento({
    required this.id,
    required this.titulo,
    this.tipoAlojamiento,
    required this.precioNoche,
    required this.calificacionPromedio,
    required this.ciudad,
    required this.provincia,
    required this.anfitrion,
    required this.maxHuespedes,
  });

  factory Alojamiento.fromJson(Map<String, dynamic> json) {
    return Alojamiento(
      id: json['_id'] as String,
      titulo: json['titulo'] as String,
      tipoAlojamiento: json['tipoAlojamiento'] as String?, // nullable
      precioNoche: (json['precioNoche'] as num).toDouble(),
      calificacionPromedio: (json['calificacionPromedio'] as num).toDouble(),
      ciudad: json['ciudad'] as String,
      provincia: json['provincia'] as String,
      maxHuespedes: json['maxHuespedes'] is int
          ? json['maxHuespedes'] as int
          : (json['maxHuespedes'] as num).toInt(),
      anfitrion: Anfitrion.fromJson(json['anfitrion'] as Map<String, dynamic>),
    );
  }
}

class Anfitrion {
  final String id;
  final String nombre;

  Anfitrion({
    required this.id,
    required this.nombre,
  });

  factory Anfitrion.fromJson(Map<String, dynamic> json) {
    return Anfitrion(
      id: json['_id'] as String,
      nombre: json['nombre'] as String,
    );
  }
}
