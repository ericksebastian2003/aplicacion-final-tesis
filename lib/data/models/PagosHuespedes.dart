class PagosHuespedes {
  final String id;
  final Reserva? reserva;
  final String huesped;
  final Anfitrion anfitrion;
  final double montoTotal;
  final double comisionSistema;
  final double montoAnfitrion;
  final DateTime createdAt;

  PagosHuespedes({
    required this.id,
    this.reserva,
    required this.huesped,
    required this.anfitrion,
    required this.montoTotal,
    required this.comisionSistema,
    required this.montoAnfitrion,
    required this.createdAt,
  });

  factory PagosHuespedes.fromJson(Map<String, dynamic> json) {
    return PagosHuespedes(
      id: json['_id'] as String,
      reserva: json['reserva'] != null ? Reserva.fromJson(json['reserva']) : null,
      huesped: json['huesped'] as String,
      anfitrion: Anfitrion.fromJson(json['anfitrion']),
      montoTotal: (json['montoTotal'] ?? 0).toDouble(),
      comisionSistema: (json['comisionSistema'] ?? 0).toDouble(),
      montoAnfitrion: (json['montoAnfitrion'] ?? 0).toDouble(),
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}

class Reserva {
  final String id;
  final String huesped;
  final Alojamiento alojamiento;
  final DateTime fechaCheckIn;
  final DateTime fechaCheckOut;
  final int numeroHuespedes;
  final double precioTotal;
  final String estadoReserva;
  final String estadoPago;
  final DateTime createdAt;

  Reserva({
    required this.id,
    required this.huesped,
    required this.alojamiento,
    required this.fechaCheckIn,
    required this.fechaCheckOut,
    required this.numeroHuespedes,
    required this.precioTotal,
    required this.estadoReserva,
    required this.estadoPago,
    required this.createdAt,
  });

  factory Reserva.fromJson(Map<String, dynamic> json) {
    return Reserva(
      id: json['_id'] as String,
      huesped: json['huesped'] as String,
      alojamiento: Alojamiento.fromJson(json['alojamiento']),
      fechaCheckIn: DateTime.parse(json['fechaCheckIn']),
      fechaCheckOut: DateTime.parse(json['fechaCheckOut']),
      numeroHuespedes: json['numeroHuespedes'] as int,
      precioTotal: (json['precioTotal'] ?? 0).toDouble(),
      estadoReserva: json['estadoReserva'] as String,
      estadoPago: json['estadoPago'] as String,
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}

class Alojamiento {
  final String id;
  final String anfitrion;
  final String titulo;
  final String descripcion;
  final String tipoAlojamiento;
  final double precioNoche;
  final int maxHuespedes;
  final String estadoAlojamiento;
  final String? ciudad;
  final String? provincia;
  final String? pais;
  final String? direccion;
  final DateTime createdAt;

  Alojamiento({
    required this.id,
    required this.anfitrion,
    required this.titulo,
    required this.descripcion,
    required this.tipoAlojamiento,
    required this.precioNoche,
    required this.maxHuespedes,
    required this.estadoAlojamiento,
    this.ciudad,
    this.provincia,
    this.pais,
    this.direccion,
    required this.createdAt,
  });

  factory Alojamiento.fromJson(Map<String, dynamic> json) {
    return Alojamiento(
      id: json['_id'] as String,
      anfitrion: json['anfitrion'] as String,
      titulo: json['titulo'] as String,
      descripcion: json['descripcion'] as String,
      tipoAlojamiento: json['tipoAlojamiento'] as String,
      precioNoche: (json['precioNoche'] ?? 0).toDouble(),
      maxHuespedes: json['maxHuespedes'] as int,
      estadoAlojamiento: json['estadoAlojamiento'] as String,
      ciudad: json['ciudad'] as String?,
      provincia: json['provincia'] as String?,
      pais: json['pais'] as String?,
      direccion: json['direccion'] as String?,
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}

class Anfitrion {
  final String id;
  final String nombre;
  final String apellido;
  final String email;

  Anfitrion({
    required this.id,
    required this.nombre,
    required this.apellido,
    required this.email,
  });

  factory Anfitrion.fromJson(Map<String, dynamic> json) {
    return Anfitrion(
      id: json['_id'] as String,
      nombre: json['nombre'] as String,
      apellido: json['apellido'] as String,
      email: json['email'] as String,
    );
  }
}
