import 'ReportanteModel.dart';

class Reportes {
  final String id;
  final dynamic reportante; // Puede ser String (ID) o ReportanteModel
  final String tipoReportado;
  final String idReportado;
  final String motivo;
  final String estado;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String v;

  Reportes({
    required this.id,
    required this.reportante,
    required this.tipoReportado,
    required this.idReportado,
    required this.motivo,
    required this.estado,
    required this.createdAt,
    required this.updatedAt,
    required this.v,
  });

  factory Reportes.fromJson(Map<String, dynamic> json) {
    final reportanteData = json['reportante'];
    dynamic reportante;

    if (reportanteData is String) {
      reportante = reportanteData; // solo ID
    } else if (reportanteData is Map<String, dynamic>) {
      reportante = ReportanteModel.fromJson(reportanteData); // objeto completo
    }

    return Reportes(
      id: json['_id'],
      reportante: reportante,
      tipoReportado: json['tipoReportado'],
      idReportado: json['idReportado'],
      motivo: json['motivo'],
      estado: json['estado'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      v: json['__v'].toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'reportante': reportante is ReportanteModel
          ? reportante.toJson()
          : reportante, // solo ID si es String
      'tipoReportado': tipoReportado,
      'idReportado': idReportado,
      'motivo': motivo,
      'estado': estado,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      '__v': v,
    };
  }
}
