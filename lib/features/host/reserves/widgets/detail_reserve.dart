import 'package:desole_app/data/models/Reservas.dart';
import 'package:flutter/material.dart';

class DetailReserve extends StatelessWidget {
  final Reservas reservas;
  const DetailReserve({
    super.key,
    required this.reservas,
  });

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: Text(
          reservas.nombreAlojamiento
        ),
      ),
      
    );

  }

}