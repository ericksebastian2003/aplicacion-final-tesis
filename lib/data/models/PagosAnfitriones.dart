
class PagosAnfitriones {
  final String id;
  final double montoTotal;
  final double comisionSistema;
  final double montoAnfitrion;
  final DateTime createdAt;

  PagosAnfitriones({
    required this.id,
    required this.montoTotal,
    required this.comisionSistema,
    required this.montoAnfitrion,
    required this.createdAt,
  });

  factory PagosAnfitriones.fromJson(Map<String, dynamic> json) {
    return PagosAnfitriones(
      id: json['_id'],
      montoTotal: (json['montoTotal'] as num).toDouble(),
      comisionSistema: (json['comisionSistema'] as num).toDouble(),
      montoAnfitrion: (json['montoAnfitrion'] as num).toDouble(),
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}
