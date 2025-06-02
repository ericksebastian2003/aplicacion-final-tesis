class Reportes {

  final String nombre;
  final String denunciante;
  final String descripcion;


  Reportes({
    required this.nombre,
    required this.denunciante,
    required this.descripcion,
  });
  factory Reportes.fromJson(Map<String,dynamic> json){
    return Reportes(
      nombre: json['name'],
      denunciante: json['gender'],
      descripcion :  'Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industrys standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. '

    );
  }
}