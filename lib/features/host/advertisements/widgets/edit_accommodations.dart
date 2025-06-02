import 'package:desole_app/services/accomodation_services.dart';
import 'package:flutter/material.dart';
import 'package:desole_app/data/models/Alojamientos.dart';

class EditAccommodationScreen extends StatefulWidget {
  final Alojamiento alojamiento;

  const EditAccommodationScreen({super.key, required this.alojamiento});

  @override
  State<EditAccommodationScreen> createState() => _EditAccommodationScreenState();
}

class _EditAccommodationScreenState extends State<EditAccommodationScreen> {
  final _service = AccomodationServices();

  late TextEditingController tituloController;
  late TextEditingController descripcionController;
  late TextEditingController tipoController;
  late TextEditingController precioController;
  late TextEditingController huespedesController;
  late TextEditingController ciudadController;
  late TextEditingController provinciaController;
  late TextEditingController paisController;
  late TextEditingController direccionController;
  late TextEditingController anfitrionController;

  @override
  void initState() {
    super.initState();
    tituloController = TextEditingController(text: widget.alojamiento.titulo);
    descripcionController = TextEditingController(text: widget.alojamiento.descripcion);
    tipoController = TextEditingController(text: widget.alojamiento.tipoAlojamiento);
    precioController = TextEditingController(text: widget.alojamiento.precioNoche.toString());
    huespedesController = TextEditingController(text: widget.alojamiento.maxHuespedes.toString());
    ciudadController = TextEditingController(text: widget.alojamiento.ciudad);
    provinciaController = TextEditingController(text: widget.alojamiento.provincia);
    paisController = TextEditingController(text: widget.alojamiento.pais);
    direccionController = TextEditingController(text: widget.alojamiento.direccion);
    anfitrionController = TextEditingController(text: widget.alojamiento.anfitrionId);
  }

  @override
  void dispose() {
    tituloController.dispose();
    descripcionController.dispose();
    tipoController.dispose();
    precioController.dispose();
    huespedesController.dispose();
    ciudadController.dispose();
    provinciaController.dispose();
    paisController.dispose();
    direccionController.dispose();
    anfitrionController.dispose();
    super.dispose();
  }

  void _saveChanges() async {
    // Construimos un nuevo objeto Alojamiento con los datos editados
    final updated = Alojamiento(
      id: widget.alojamiento.id,
      titulo: tituloController.text,
      descripcion: descripcionController.text,
      tipoAlojamiento: tipoController.text,
      precioNoche: int.tryParse(precioController.text) ?? 0,
      maxHuespedes: int.tryParse(huespedesController.text) ?? 0,
      ciudad: ciudadController.text,
      provincia: provinciaController.text,
      pais: paisController.text,
      direccion: direccionController.text,
      anfitrionId: anfitrionController.text,
    );

    // Imprimir objeto para debug
    print('🚀 Enviando alojamiento a editar: ${updated.toJsonForUpdate()}');

    try {
      final success = await _service.updateAccommodation(
          updated.id,
          updated,
        );



      if (success && mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al actualizar: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Editar alojamiento')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(controller: tituloController, decoration: const InputDecoration(labelText: 'Título')),
            TextField(controller: descripcionController, decoration: const InputDecoration(labelText: 'Descripción')),
            TextField(controller: tipoController, decoration: const InputDecoration(labelText: 'Tipo de alojamiento')),
            TextField(
              controller: precioController,
              decoration: const InputDecoration(labelText: 'Precio por noche'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: huespedesController,
              decoration: const InputDecoration(labelText: 'Máximo huéspedes'),
              keyboardType: TextInputType.number,
            ),
            TextField(controller: ciudadController, decoration: const InputDecoration(labelText: 'Ciudad')),
            TextField(controller: provinciaController, decoration: const InputDecoration(labelText: 'Provincia')),
            TextField(controller: paisController, decoration: const InputDecoration(labelText: 'País')),
            TextField(controller: direccionController, decoration: const InputDecoration(labelText: 'Dirección')),
            TextField(
              controller: anfitrionController,
              decoration: const InputDecoration(labelText: 'ID del Anfitrión'),
              enabled: false, // opcional: evita edición manual del ID
            ),
            const SizedBox(height: 20),
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
                onPressed: _saveChanges,
                child: const Text(
                  'Guardar cambios',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
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
