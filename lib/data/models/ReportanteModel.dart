class ReportanteModel {
  final String id;
  final String nombre;
  final String apellido;
  final String email;

  ReportanteModel({
    required this.id,
    required this.nombre,
    required this.apellido,
    required this.email,
  });

  factory ReportanteModel.fromJson(Map<String, dynamic> json) {
    return ReportanteModel(
      id: json['_id'],
      nombre: json['nombre'],
      apellido: json['apellido'],
      email: json['email'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'nombre': nombre,
      'apellido': apellido,
      'email': email,
    };
  }
}
