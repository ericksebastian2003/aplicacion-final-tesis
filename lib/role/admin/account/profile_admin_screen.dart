import 'package:desole_app/services/users_services.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class ProfileAdminScreen extends StatefulWidget {
  const ProfileAdminScreen({
    super.key,
  });
  @override
  State<ProfileAdminScreen> createState() => _ProfileAdminScreenState();
}

class _ProfileAdminScreenState extends State<ProfileAdminScreen> {
  final _userServices = UsersServices();
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _apellidoController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _telefonoController = TextEditingController();
  File? _profileImage;
  String? _profileImageUrl;
  bool _isLoading = false;

  String? _mensaje;
  bool _isError = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _apellidoController.dispose();
    _emailController.dispose();
    _telefonoController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    final user = await _userServices.getUserProfile();
    print('👤 Datos del usuario: $user');
    if (user != null) {
      setState(() {
        _nombreController.text = user['nombre'];
        _apellidoController.text = user['apellido'];
        _emailController.text = user['email'];
        _telefonoController.text = user['telefono'];
        if (user['urlFotoPerfil'] != null && user['urlFotoPerfil'].toString().isNotEmpty) {
          _profileImageUrl = user['urlFotoPerfil'];
        }
      });
    }
  }

  Widget _buildMensaje() {
    if (_mensaje == null) return const SizedBox.shrink();

    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        child: AnimatedOpacity(
          opacity: _mensaje != null ? 1 : 0,
          duration: const Duration(milliseconds: 300),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 8,
                  offset: Offset(0, 3),
                )
              ],
            ),
            constraints: const BoxConstraints(minWidth: 200),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _isError ? Icons.error_outline : Icons.check_circle_outline,
                  color: _isError ? Colors.red.shade700 : Colors.black87,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _mensaje!,
                    style: const TextStyle(
                      color: Colors.black87,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _updateProfile() async {
    setState(() {
      _isLoading = true;
      _mensaje = null; // Limpiar mensaje anterior
    });
    
    final updateData = {
      'nombre': _nombreController.text.trim(),
      'apellido': _apellidoController.text.trim(),
      'email': _emailController.text.trim(),
      'telefono': _telefonoController.text.trim(),
    };

    final message = await _userServices.updateUserProfile(updateData);
    
    if (mounted) {
      setState(() {
        _isLoading = false;
        if (message != null) {
          _mensaje = message;
          _isError = false; 
        } else {
          _mensaje = 'Error inesperado al actualizar el perfil.';
          _isError = true;
        }
      });
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _profileImage = File(picked.path);
      });
      await _userServices.uploadProfileImage(_profileImage);
    }
  }

  void _removeImage() async {
    setState(() {
      _profileImage = null;
      _profileImageUrl = null;
    });
    await _userServices.deleteProfileImage();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Editar perfil',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                GestureDetector(
                  onTap: _pickImage,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      CircleAvatar(
                        radius: 60,
                        backgroundImage: _profileImage != null
                            ? FileImage(_profileImage!)
                            : (_profileImageUrl != null
                                ? NetworkImage(_profileImageUrl!)
                                : const AssetImage('assets/default_profile.png')) as ImageProvider,
                      ),
                      if (_profileImage == null && _profileImageUrl == null)
                        const Icon(Icons.camera_alt, size: 32, color: Colors.white),
                      if (_profileImage != null || _profileImageUrl != null)
                        Positioned(
                          top: 0,
                          right: 0,
                          child: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: _removeImage,
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                _buildTextField(_nombreController, 'Nombre', 'Ingresa el nombre'),
                _buildTextField(_apellidoController, 'Apellido', 'Ingrese el apellido'),
                _buildTextField(_emailController, 'Correo electrónico', 'Ingresa el correo electrónico'),
                _buildTextField(_telefonoController, 'Teléfono', 'Ingresa el teléfono'),
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
                    onPressed: _isLoading ? null : _updateProfile,
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            'Actualizar perfil',
                            style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                  ),
                ),
              ],
            ),
          ),
          _buildMensaje(),
        ],
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