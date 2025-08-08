class PagosHuespedes {
  final String id;
  final String alojamientoTitulo;
  final String ciudad;
  final String fechaCheckIn;
  final String fechaCheckOut;
  final double montoTotal;
  final String createdAt;

  PagosHuespedes({
    required this.id,
    required this.alojamientoTitulo,
    required this.ciudad,
    required this.fechaCheckIn,
    required this.fechaCheckOut,
    required this.montoTotal,
    required this.createdAt,
  });

  factory PagosHuespedes.fromJson(Map<String, dynamic> json) {
    return PagosHuespedes(
      id: json['_id'] as String,
      alojamientoTitulo: json['reserva']?['alojamiento']?['titulo'] ?? 'Desconocido',
      ciudad: json['reserva']?['alojamiento']?['ciudad'] ?? 'Desconocido',
      fechaCheckIn: json['reserva']?['fechaCheckIn'] ?? '',
      fechaCheckOut: json['reserva']?['fechaCheckOut'] ?? '',
      montoTotal: (json['montoTotal'] ?? 0).toDouble(),
      createdAt: json['createdAt'] ?? '',
    );
  }
}
