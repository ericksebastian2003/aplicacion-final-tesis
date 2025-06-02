import 'package:desole_app/features/guest/explore/widgets/detail_pays.dart';
import 'package:flutter/material.dart';

import '../../../../data/models/Alojamientos.dart';
class DetailScreen extends StatelessWidget{
  final Alojamiento destino;
  const DetailScreen({
    super.key,
    required this.destino,
  });
  /*void reserveDestine(BuildContext context)  {
     Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => DetailPays(destino: destino)),
    );
        
    }
*/
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(destino.titulo),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            Text(
              destino.titulo.toUpperCase(),
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold
              ),
            

              ),
                const SizedBox( height: 12
            ),
            Text(destino.descripcion,
            style: const TextStyle(
              fontSize: 16,
            ),),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 55, 
              child: OutlinedButton(
                
                style:OutlinedButton.styleFrom(
                  shape : RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
               
                
              onPressed: () => print("Reserrvar"),
              //reserveDestine(context) , 
              child:  Text(
                'Reservar',
                style:  TextStyle(
                  color:  Colors.black,

                ) ,
              )
              )
              )

          ],
        ),
      ),
    );
  }
}
