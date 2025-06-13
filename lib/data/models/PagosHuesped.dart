class PagosHuesped {
  final String id;
  final String reserva;
  final String huesped;
  final String anfitrion;
  final double montoTotal;
  final double comisionSistema;
  final double montoAnfitrion;
  final DateTime createdAt;
  final DateTime updatedAt;

  PagosHuesped({
    required this.id,
    required this.reserva,
    required this.huesped,
    required this.anfitrion,
    required this.montoTotal,
    required this.comisionSistema,
    required this.montoAnfitrion,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PagosHuesped.fromJson(Map<String, dynamic> json) {
    return PagosHuesped(
      id: json['_id'],
      reserva: json['reserva'],
      huesped: json['huesped'],
      anfitrion: json['anfitrion'],
      montoTotal: (json['montoTotal'] as num).toDouble(),
      comisionSistema: (json['comisionSistema'] as num).toDouble(),
      montoAnfitrion: (json['montoAnfitrion'] as num).toDouble(),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
}
