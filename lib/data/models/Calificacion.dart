class Calificacion {
  final String id;
  final String huespedId;
  final String? huespedNombre;
  final String alojamiento;
  final String reserva;
  late int estrellas;
  late String comentario;
  final DateTime createdAt;
  final DateTime updatedAt;

  Calificacion({
    required this.id,
    required this.huespedId,
    this.huespedNombre,
    required this.alojamiento,
    required this.reserva,
    required this.estrellas,
    required this.comentario,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Calificacion.fromJson(Map<String, dynamic> json) {
    final huespedData = json['huesped'];
    String huespedId = '';
    String? huespedNombre;

    if (huespedData is Map<String, dynamic>) {
      huespedId = huespedData['_id'];
      huespedNombre = huespedData['nombre'];
    } else if (huespedData is String) {
      huespedId = huespedData;
    }

    return Calificacion(
      id: json['_id'],
      huespedId: huespedId,
      huespedNombre: huespedNombre,
      alojamiento: json['alojamiento'],
      reserva: json['reserva'],
      estrellas: json['estrellas'],
      comentario: json['comentario'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'huesped': huespedId,
      'alojamiento': alojamiento,
      'reserva': reserva,
      'estrellas': estrellas,
      'comentario': comentario,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// Para creación desde el huésped
  Map<String, dynamic> toJsonForCreate() {
    return {
      'estrellas': estrellas,
      'comentario': comentario,
    };
  }
}
