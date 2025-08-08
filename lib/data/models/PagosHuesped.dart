class PagosHuesped {
  final String id;
  final Reserva reserva;
  final double montoTotal;
  final DateTime createdAt;

  PagosHuesped({
    required this.id,
    required this.reserva,
    required this.montoTotal,
    required this.createdAt,
  });

  factory PagosHuesped.fromJson(Map<String, dynamic> json) {
    return PagosHuesped(
      id: json['_id'],
      reserva: Reserva.fromJson(json['reserva']),
      montoTotal: (json['montoTotal'] as num).toDouble(),
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}

class Reserva {
  final String id;
  final Alojamiento alojamiento;
  final DateTime fechaCheckIn;
  final DateTime fechaCheckOut;

  Reserva({
    required this.id,
    required this.alojamiento,
    required this.fechaCheckIn,
    required this.fechaCheckOut,
  });

  factory Reserva.fromJson(Map<String, dynamic> json) {
    return Reserva(
      id: json['_id'],
      alojamiento: Alojamiento.fromJson(json['alojamiento']),
      fechaCheckIn: DateTime.parse(json['fechaCheckIn']),
      fechaCheckOut: DateTime.parse(json['fechaCheckOut']),
    );
  }
}

class Alojamiento {
  final String id;
  final String titulo;
  final String ciudad;

  Alojamiento({
    required this.id,
    required this.titulo,
    required this.ciudad,
  });

  factory Alojamiento.fromJson(Map<String, dynamic> json) {
    return Alojamiento(
      id: json['_id'],
      titulo: json['titulo'],
      ciudad: json['ciudad'],
    );
  }
}
