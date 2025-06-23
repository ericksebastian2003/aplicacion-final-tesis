class Reservas {
  final String id;
  final String alojamientoId;
  final String tituloAlojamiento;
  final String huespedId;
  final DateTime fechaCheckIn;
  final DateTime fechaCheckOut;
  final int numeroHuespedes;
  final double precioTotal;
  final String estadoReserva;
  final String estadoPago;
  final String? nombreHuesped;
  final String? emailHuesped;

  Reservas({
    required this.id,
    required this.alojamientoId,
    required this.tituloAlojamiento,
    required this.huespedId,
    required this.fechaCheckIn,
    required this.fechaCheckOut,
    required this.numeroHuespedes,
    required this.precioTotal,
    required this.estadoReserva,
    required this.estadoPago,
    this.nombreHuesped,
    this.emailHuesped,
  });

  factory Reservas.fromJson(Map<String, dynamic> json) {
    // Parse huesped
    final huesped = json['huesped'];
    String huespedId = '';
    String? nombreHuesped;
    String? emailHuesped;

    if (huesped is String) {
      huespedId = huesped;
    } else if (huesped is Map<String, dynamic>) {
      huespedId = huesped['_id'] ?? '';
      nombreHuesped = huesped['nombre'];
      emailHuesped = huesped['email'];
    }

    // Parse alojamiento (puede ser String o Map)
    final alojamiento = json['alojamiento'];
    String alojamientoId = '';
    String tituloAlojamiento = '';

    if (alojamiento is String) {
      alojamientoId = alojamiento;
    } else if (alojamiento is Map<String, dynamic>) {
      alojamientoId = alojamiento['_id'] ?? '';
      tituloAlojamiento = alojamiento['titulo'] ?? '';
    }

    return Reservas(
      id: json['_id'] ?? '',
      alojamientoId: alojamientoId,
      tituloAlojamiento: tituloAlojamiento,
      huespedId: huespedId,
      fechaCheckIn: DateTime.parse(json['fechaCheckIn']),
      fechaCheckOut: DateTime.parse(json['fechaCheckOut']),
      numeroHuespedes: json['numeroHuespedes'] ?? 0,
      precioTotal: (json['precioTotal'] as num?)?.toDouble() ?? 0.0,
      estadoReserva: json['estadoReserva'] ?? '',
      estadoPago: json['estadoPago'] ?? '',
      nombreHuesped: nombreHuesped,
      emailHuesped: emailHuesped,
    );
  }

  Map<String, dynamic> toJsonForUpdateGuest() {
    return {
      'numeroHuespedes': numeroHuespedes,
    };
  }

  Map<String, dynamic> toJsonForUpdateHost() {
    return {
      'estadoPago': estadoPago,
      'estadoReserva': estadoReserva,
    };
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'alojamiento': {
        '_id': alojamientoId,
        'titulo': tituloAlojamiento,
      },
      'huesped': huespedId,
      'fechaCheckIn': fechaCheckIn.toIso8601String(),
      'fechaCheckOut': fechaCheckOut.toIso8601String(),
      'numeroHuespedes': numeroHuespedes,
      'precioTotal': precioTotal,
      'estadoReserva': estadoReserva,
      'estadoPago': estadoPago,
    };
  }
}
