import 'package:desole_app/data/models/FotoAlojamientos.dart';
import 'package:desole_app/features/guest/explore/widgets/detail_pays.dart';
import 'package:desole_app/services/accomodation_services.dart';
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
            FutureBuilder<List<FotosAlojamientos>>(
  future: AccomodationServices().getPhotosAccomadations(destino.id), // tu método
  builder: (context, snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const Center(child: CircularProgressIndicator());
    } else if (snapshot.hasError) {
      return Text('Error: ${snapshot.error}');
    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
      return const Text('No hay fotos disponibles');
    } else {
      final fotos = snapshot.data!;
      return SizedBox(
        height: 200,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: fotos.length,
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  fotos[index].urlFoto,
                  width: 300,
                  fit: BoxFit.cover,
                ),
              ),
            );
          },
        ),
      );
    }
  },
),



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
               
                
              onPressed: () => print("Reservar"),
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
