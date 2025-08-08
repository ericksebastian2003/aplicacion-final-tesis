class FotosAlojamientos {
  final String id;
  final String urlFoto;
  final bool fotoPrincipal;

  FotosAlojamientos({
    required this.id,
    required this.urlFoto,
    required this.fotoPrincipal,

  });

  factory FotosAlojamientos.fromJson(Map<String, dynamic> json) {
    return FotosAlojamientos(
      id: json['_id'],
      urlFoto: json['urlFoto'],
      fotoPrincipal: json['fotoPrincipal'],
    );
  }

  get firstPhoto => null;

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'urlFoto': urlFoto,
      'fotoPrincipal': fotoPrincipal,
    };
  }
}
