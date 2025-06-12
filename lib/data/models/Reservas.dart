class Reservas {
  final String id;
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
    required this.tituloAlojamiento,
    required this.huespedId,
    required this.fechaCheckIn,
    required this.fechaCheckOut,
    required this.numeroHuespedes,
    required this.precioTotal,
    required this.estadoReserva,
    required this.estadoPago,
    required this.nombreHuesped,
    required this.emailHuesped,
  });

  factory Reservas.fromJson(Map<String, dynamic> json) {
    final huesped = json['huesped'];
    String huespedId = '';
    String? nombreHuesped;
    String? emailHuesped;

    if (huesped is String) {
      // Solo un ID
      huespedId = huesped;
    } else if (huesped is Map<String, dynamic>) {
      // Es un objeto con datos
      huespedId = huesped['_id'] ?? '';
      nombreHuesped = huesped['nombre'];
      emailHuesped = huesped['email'];
    }

    return Reservas(
      id: json['_id'] ?? '',
      tituloAlojamiento: json['alojamiento']?['titulo'] ?? '',
      huespedId: huespedId,
      fechaCheckIn: DateTime.parse(json['fechaCheckIn']),
      fechaCheckOut: DateTime.parse(json['fechaCheckOut']),
      numeroHuespedes: json['numeroHuespedes'] ?? 0,
      precioTotal: (json['precioTotal'] as num?)?.toDouble() ?? 0.0,
      estadoReserva: json['estadoReserva'] ?? '',
      estadoPago: json['estadoPago'] ?? '',
      nombreHuesped: nombreHuesped ?? '',
      emailHuesped: emailHuesped ?? '',
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
      'alojamiento': {'titulo': tituloAlojamiento},
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
