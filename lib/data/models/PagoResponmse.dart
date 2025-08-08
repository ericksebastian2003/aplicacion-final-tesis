import 'package:desole_app/data/models/PagosHuesped.dart';

class PagoResponse {
  final String msg;
  final PagosHuesped pago;

  PagoResponse({required this.msg, required this.pago});

  factory PagoResponse.fromJson(Map<String, dynamic> json) {
    return PagoResponse(
      msg: json['msg'],
      pago: PagosHuesped.fromJson(json['pago']),
    );
  }
}
