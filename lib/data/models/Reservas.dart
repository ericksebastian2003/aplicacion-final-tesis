class Reservas {
  final String fechaInicio;
  final String fechaFinal;
  final String nombreHuesped;
  final String nombreAlojamiento;

  Reservas({
    required this.fechaFinal,
    required this.fechaInicio,
    required this.nombreHuesped,
    required this.nombreAlojamiento,
  });
  factory Reservas.fromFirestore(Map<String,dynamic> json){
    return Reservas(
      fechaFinal: json['fechaFinal'],
      fechaInicio: json['fechaInicio'], 
      nombreHuesped: json['nombreHuesped'],
      nombreAlojamiento: json['nombreAlojamiento'],
      );
  }
}