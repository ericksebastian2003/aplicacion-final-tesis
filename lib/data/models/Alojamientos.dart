class Alojamiento {
  final String id;
  final String titulo;
  final String descripcion;
  final String tipoAlojamiento;
  final int precioNoche;
  final int maxHuespedes;
  final double? calificacionPromedio;
  final String ciudad;
  final String provincia;
  final String pais;
  final String estadoAlojamiento;
  final String direccion;
  final String anfitrionId; // Solo el ID del anfitrión

  Alojamiento({
    required this.id,
    required this.titulo,
    required this.descripcion,
    required this.tipoAlojamiento,
    required this.precioNoche,
    required this.maxHuespedes,
    required this.ciudad,
    required this.calificacionPromedio,
    required this.provincia,
    required this.pais,
    required this.direccion,
    required this.estadoAlojamiento,
    required this.anfitrionId,
  });

  factory Alojamiento.fromJson(Map<String, dynamic> json) {
    return Alojamiento(
      id: json['_id'] ?? '',
      titulo: json['titulo'] ?? '',
      descripcion: json['descripcion'] ?? '',
      tipoAlojamiento: json['tipoAlojamiento'] ?? '',
      precioNoche: int.tryParse(json['precioNoche'].toString()) ?? 0,
      maxHuespedes: int.tryParse(json['maxHuespedes'].toString()) ?? 0,
      ciudad: json['ciudad'] ?? '',
      provincia: json['provincia'] ?? '',
      estadoAlojamiento: json['estadoAlojamiento'],
      pais: json['pais'] ?? '',
      direccion: json['direccion'] ?? '',
      calificacionPromedio: json['calificacionPromedio']?.toDouble(),
      anfitrionId: json['anfitrion'] is String
          ? json['anfitrion']
          : (json['anfitrion']?['_id'] ?? ''),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'titulo': titulo,
      'descripcion': descripcion,
      'tipoAlojamiento': tipoAlojamiento,
      'precioNoche': precioNoche,
      'maxHuespedes': maxHuespedes,
      'ciudad': ciudad,
      'provincia': provincia,
      'pais': pais,
      'direccion': direccion,
      'anfitrion': anfitrionId,
      'estadoAlojamiento' : estadoAlojamiento,
    };
  }

  Map<String, dynamic> toJsonForUpdate() {
    return {
      'titulo': titulo,
      'descripcion': descripcion,
      'tipoAlojamiento': tipoAlojamiento,
      'precioNoche': precioNoche,
      'maxHuespedes': maxHuespedes,
      'ciudad': ciudad,
      'provincia': provincia,
      'pais': pais,
      'direccion': direccion,
      'anfitrion': anfitrionId,
    };
  }
}
