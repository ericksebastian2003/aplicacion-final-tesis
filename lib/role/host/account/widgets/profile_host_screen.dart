import 'package:desole_app/services/users_services.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class ProfileHostScreen extends StatefulWidget{
  const ProfileHostScreen({
    super.key,
  });
  @override
  State<ProfileHostScreen> createState() => _ProfileHostScreenState();

}
class _ProfileHostScreenState extends State<ProfileHostScreen>{
  final _userServices = UsersServices();
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _apellidoController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _cedulaController = TextEditingController();
  final TextEditingController _telefonoController = TextEditingController();
  File? _profileImage;
  bool _isLoading = false;
  @override
  void initState(){
    super.initState();
    _loadUserData();
  }
  @override
  void dispose(){
    _nombreController.dispose();
    _apellidoController.dispose();
    _emailController.dispose();
    _cedulaController.dispose();
    _telefonoController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async{
      final user = await _userServices.getUserProfile();
      print('👤 Datos del usuario: $user');
      if( user != null){

          _nombreController.text = user['nombre'];
          _apellidoController.text = user['apellido'];
          _emailController.text = user['email'];
         _cedulaController.text = user['cedula'];
         _telefonoController.text = user['telefono'];


        }
       
  }
  Future<void> _updateProfile() async{
    setState(() => _isLoading = true);
    final updateData = {
      'nombre' : _nombreController.text.trim(),
      'apellido': _apellidoController.text.trim(),
      'email' : _emailController.text.trim(),
      'cedula' : _cedulaController.text.trim(),
      'telefono' : _telefonoController.text.trim(),
    };
    final success = await _userServices.updateUserProfile(updateData);

    if(mounted){

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success 
               ? 'Perfil actualizado correctamente'
               : 'No se ha actualizado correctamente',
          ),
          ),
        );
    }
    
    setState(() => _isLoading = false);
  }
  Future<void> _pickImage() async{
    final picker = ImagePicker();
    final picked = await picker.pickImage(source : ImageSource.gallery);
    if(picked != null ){
      setState(() {
        _profileImage = File(picked.path);
      });
      //Llamar al backend
      //await _userServices.uploadProfileImage(_profileImage!);
    }
  }
  void _removeImage(){
    setState(() {
       // await _userServices.deleteProfileImage();
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Editar Perfil')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            GestureDetector(
              onTap: _pickImage,
              onLongPress: () {
                showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text('¿Eliminar foto de perfil?'),
                    actions: [
                      TextButton(
                        onPressed: () {
                          _removeImage();
                          Navigator.pop(context);
                        },
                        child: const Text('Eliminar'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancelar'),
                      ),
                    ],
                  ),
                );
              },
              child: CircleAvatar(
                radius: 60,
                backgroundImage: _profileImage != null
                    ? FileImage(_profileImage!)
                    : const AssetImage('assets/default_profile.png') as ImageProvider,
                child: _profileImage == null
                    ? const Icon(Icons.camera_alt, size: 32, color: Colors.white)
                    : null,
              ),
            ),
            const SizedBox(height: 20),
            _buildTextField(_nombreController, 'Nombre', 'Ingresa el nombre'),
            _buildTextField(_apellidoController, 'Apellido', 'Ingrese el apellido'),
            _buildTextField(_emailController, 'Correo electrónico', 'Ingresa el correo electrónico'),
            _buildTextField(_cedulaController, 'Cédula', 'Ingresa la cédula'),
            _buildTextField(_telefonoController, 'Teléfono', 'Ingresa el teléfono'),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _updateProfile,
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Guardar Cambios',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget _buildTextField(
  TextEditingController controller,
  String label,
  String hint, {
  bool isNumeric = false,
}) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 14.0),
    child: TextFormField(
      controller: controller,
      keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: const OutlineInputBorder(),
      ),
    ),
  );
}