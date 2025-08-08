import '../../../../providers/form_alojamiento_provider.dart';
import 'package:desole_app/role/host/advertisements/widgets/create_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CreateAccomadationScreen extends StatefulWidget {
  const CreateAccomadationScreen({super.key});

  @override
  State<CreateAccomadationScreen> createState() =>
      _CreateAccomadationScreenState();
}

class _CreateAccomadationScreenState extends State<CreateAccomadationScreen> {
  int selected = -1;

  List<String> opcionesAlojamientos = [
    'Cabaña',
    'Habitación de hotel',
    'Casa',
    'Departamento',
  ];

  @override
  Widget build(BuildContext context) {
    final formProvider =
        Provider.of<FormAlojamientoProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Crear anuncio',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 20,
          horizontal: 10,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            const Text(
              '¿Cuál de estas opciones describe mejor tu alojamiento?',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: List.generate(opcionesAlojamientos.length, (index) {
                bool isSelected = selected == index;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selected = index;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 20,
                      horizontal: 10,
                    ),
                    width: double.infinity,
                    height: 100,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? Colors.black : Colors.white,
                        width: 2,
                      ),
                    ),
                    child: Text(
                      opcionesAlojamientos[index],
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: isSelected ? Colors.black : Colors.grey,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                  ),
                );
              }),
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
                onPressed: selected == -1
                    ? null
                    : () {
                        final tipoSeleccionado =
                            opcionesAlojamientos[selected];
                        formProvider.setTipoAlojamiento(tipoSeleccionado);

                        // Navegar a la pantalla de subir imágenes
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CreateImage(
                              onImageUploaded: (mensaje) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(mensaje)),
                                );
                              }, alojamientoId: '',
                            ),
                          ),
                        );
                      },
                child: const Text(
                  'Siguiente',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
