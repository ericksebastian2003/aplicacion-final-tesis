class FotosAlojamientos {
  final String id;
  final String? alojamiento;
  final String urlFoto;
  final String publicId;
  final bool fotoPrincipal;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int v;

  FotosAlojamientos({
    required this.id,
    this.alojamiento,
    required this.urlFoto,
    required this.publicId,
    required this.fotoPrincipal,
    required this.createdAt,
    required this.updatedAt,
    required this.v,
  });

  factory FotosAlojamientos.fromJson(Map<String, dynamic> json) {
    return FotosAlojamientos(
      id: json['_id'],
      alojamiento: json['alojamiento'],
      urlFoto: json['urlFoto'],
      publicId: json['public_id'],
      fotoPrincipal: json['fotoPrincipal'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      v: json['__v'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'alojamiento': alojamiento,
      'urlFoto': urlFoto,
      'public_id': publicId,
      'fotoPrincipal': fotoPrincipal,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      '__v': v,
    };
  }
}
