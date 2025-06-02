import 'package:flutter/material.dart';
/*
class CreateIntroImage extends StatelessWidget {
  const CreateIntroImage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Imagen del alojamiento'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Sube una imagen representativa de tu alojamiento.',
              style: TextStyle(fontSize: 20),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  backgroundColor: Colors.black,
                ),
                onPressed: () {
  print('Botón presionado');
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => CreateImage(
        onImageUploaded: (url) {
          print('Imagen subida con URL: $url');
        },
      ),
    ),
  );
},

                child: const Text(
                  'Siguiente',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w200,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
*/