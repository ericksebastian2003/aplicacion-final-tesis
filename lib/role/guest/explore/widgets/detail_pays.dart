import 'package:flutter/material.dart';
import '../../../../data/models/Alojamientos.dart';
/*
class DetailPays extends StatelessWidget {
  final Alojamiento destino;

  const DetailPays({
    super.key,
    required this.destino,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Información de reserva',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
             Text(
                      destino.nombre.toUpperCase(),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
                      ),
                    ),
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Información de pago',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('${destino.precio} x noche'),
                        const Text('\$40'), // Puedes calcular el total aquí si es necesario
                      ],
                    ),
                  ],
                ),
              ),
            ),
             SizedBox(
              width: double.infinity,
              child: OutlinedButton( 
                onPressed: () => print('Pago'),
                style:OutlinedButton.styleFrom(
                backgroundColor: Colors.lightGreen,
                  shape : RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Realizar pago',
                  style:  TextStyle(
                  color:  Colors.white,

                ) ,
                )
                ),
      

            )
          ],
        ),
      ),
    );
  }
}
*/