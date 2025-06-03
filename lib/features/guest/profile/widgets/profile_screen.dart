import 'package:desole_app/services/users_services.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
class ProfileScreen extends StatefulWidget{
  const ProfileScreen({
    super.key,
  });
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();

}
class _ProfileScreenState extends State<ProfileScreen>{
  final _userServices = UsersServices();
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _apellidoController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _cedulaController = TextEditingController();
  final TextEditingController _telefonoController = TextEditingController();


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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Editar Perfil'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildTextField(_nombreController , 'Nombre' , 'Ingresa el nombre'),
            _buildTextField(_apellidoController , 'Apellido' , 'Ingrese el apellido'),
            _buildTextField(_emailController , 'Correo electrónico','Ingresa el correo electrónico'),
            _buildTextField(_cedulaController , 'Cédula','Ingresa la cédula'),
            _buildTextField(_telefonoController , 'Teléfono','Ingresa el teléfono'),

            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _updateProfile,
                child: _isLoading 
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Editar Perfil' ,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                      ),
              ),
            )
          ],

        ),
      ),
    );
  }
}

Widget _buildTextField(TextEditingController controller , String label , String hint , {bool isNumeric = false}){
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
      validator: (value){
        if(value == null || value.isEmpty) return 'Este campo es obligatorio';
      },
    ),
  );
}