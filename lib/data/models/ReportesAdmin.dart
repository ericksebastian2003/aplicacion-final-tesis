import 'dart:convert';
class Reportante {
  final String? id;
  final String? nombre;
  final String? apellido;
  final String? email;

  Reportante({
    this.id,
    this.nombre,
    this.apellido,
    this.email,
  });

  factory Reportante.fromJson(Map<String, dynamic> json) {
    return Reportante(
      id: json['_id'],
      nombre: json['nombre'],
      apellido: json['apellido'],
      email: json['email'],
    );
  }
}
class ReporteAdmin{
  final String id;
  final Reportante? reportante;
  final String tipoReportado;
  final String motivo;
  final String estado;
  final DateTime createdAt;

  ReporteAdmin({
    required this.id,
    this.reportante,
    required this.tipoReportado,
    required this.motivo,
    required this.estado,
    required this.createdAt,
  });

  factory ReporteAdmin.fromJson(Map<String, dynamic> json) {
    return ReporteAdmin(
      id: json['_id'] as String,
      reportante: json['reportante'] != null && json['reportante'] is Map<String, dynamic>
          ? Reportante.fromJson(json['reportante'])
          : null,
      tipoReportado: json['tipoReportado'] as String,
      motivo: json['motivo'] as String,
      estado: json['estado'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}
// Modelo para manejar la respuesta completa de la API, incluyendo la paginación
class ReportesResponse {
  final List<ReporteAdmin> reportes;
  final Pagination pagination;

  ReportesResponse({
    required this.reportes,
    required this.pagination,
  });

  factory ReportesResponse.fromJson(Map<String, dynamic> json) {
    return ReportesResponse(
      reportes: (json['reportes'] as List)
          .map((item) => ReporteAdmin.fromJson(item as Map<String, dynamic>))
          .toList(),
      pagination: Pagination.fromJson(json['pagination'] as Map<String, dynamic>),
    );
  }
}

// Modelo para la información de paginación
class Pagination {
  final int page;
  final int limit;
  final int total;
  final int totalPages;

  Pagination({
    required this.page,
    required this.limit,
    required this.total,
    required this.totalPages,
  });

  factory Pagination.fromJson(Map<String, dynamic> json) {
    return Pagination(
      page: json['page'] as int,
      limit: json['limit'] as int,
      total: json['total'] as int,
      totalPages: json['totalPages'] as int,
    );
  }
}

// Función de ayuda para decodificar desde un string JSON
ReportesResponse reportesResponseFromJson(String str) {
  final jsonData = json.decode(str);
  return ReportesResponse.fromJson(jsonData);
}