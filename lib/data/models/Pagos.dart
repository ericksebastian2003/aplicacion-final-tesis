import 'package:desole_app/data/models/Reservas.dart';
import 'package:desole_app/data/models/Usuarios.dart';

class Pagos {
  final Reservas reserva;
  final Usuarios huesped;
  final Usuarios anfitrion;
  final double montoFinal;
  final double comisionSistema;
  final double montoAnfitrion;
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int v;

  Pagos({
    required this.reserva,
    required this.huesped,
    required this.anfitrion,
    required this.montoFinal,
    required this.comisionSistema,
    required this.montoAnfitrion,
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.v,
  });

  factory Pagos.fromJson(Map<String, dynamic> json) {
    return Pagos(
      reserva: Reservas.fromJson(json['reserva']),
      huesped: Usuarios.fromJson(json['huesped']),
      anfitrion: Usuarios.fromJson(json['anfitrion']),
      montoFinal: (json['montoTotal'] ?? 0).toDouble(),
      comisionSistema: (json['comisionSistema'] ?? 0).toDouble(),
      montoAnfitrion: (json['montoAnfitrion'] ?? 0).toDouble(),
      id: json['_id'] ?? '',
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt'] ?? '') ?? DateTime.now(),
      v: json['__v'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'reserva': reserva.toJson(),
      'huesped': huesped.toJson(),
      'anfitrion': anfitrion.toJson(),
      'montoTotal': montoFinal,
      'comisionSistema': comisionSistema,
      'montoAnfitrion': montoAnfitrion,
      '_id': id,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      '__v': v,
    };
  }

  Map<String, List<Pagos>> filtrarPagosComoAnfitrionYHuespedModel(List<Pagos> pagos, String miId) {
    final comoAnfitrion = pagos.where((p) => p.anfitrion.id == miId).toList();
    final comoHuesped = pagos.where((p) => p.huesped.id == miId).toList();

    return {
      'comoAnfitrion': comoAnfitrion,
      'comoHuesped': comoHuesped,
    };
  }
}
