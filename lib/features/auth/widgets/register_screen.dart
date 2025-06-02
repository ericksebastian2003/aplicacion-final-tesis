import 'package:desole_app/services/auth_service.dart';
import 'package:desole_app/features/auth/widgets/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final Color colorPrimary = const Color(0xFF001D5A);
  final Map<String, TextEditingController> _controllers = {
    'nombre': TextEditingController(),
    'apellido': TextEditingController(),
    'telefono': TextEditingController(),
    'email': TextEditingController(),
    'cedula' : TextEditingController(),
    'password': TextEditingController(),
  };
  final authService = AuthService();
  final Map<String, FocusNode> _focusNodes = {
    'nombre': FocusNode(),
    'apellido': FocusNode(),
    'telefono': FocusNode(),
    'email': FocusNode(),
    'cedula' : FocusNode(),
    'password': FocusNode(),
  };

  DateTime? _dateSelected;
  bool loading = false;

  /*Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      helpText: 'Selecciona tu fecha de nacimiento',
    );
    if (picked != null && picked != _dateSelected) {
      setState(() {
        _dateSelected = picked;
      });
    }
  }
  */

  void register(String nombre, String apellido, String telefono, String cedula, String email, String password) async {
  setState(() => loading = true);

  final userData = {
    'nombre': nombre.trim(),
    'apellido': apellido.trim(),
    'telefono': telefono.trim(),
    'email': email.trim(),
    'cedula': cedula.trim(),
    'password': password.trim(),
  };

  print('🔐 Datos enviados para registro: $userData');

  final response = await authService.register(userData);

  print('✅ Respuesta del servicio: $response');

  setState(() => loading = false);

  if (response['status'] == 'success') {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(response['msg'] ?? 'Cuenta creada correctamente')),
    );
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(response['msg'] ?? 'Error al registrar usuario')),
    );
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const SizedBox(height: 20),
              Text(
                'Crear Cuenta',
                style: TextStyle(
                  fontSize: 34,
                  color: colorPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 25),
              Row(
                children: [
                  Expanded(child: _buildPlainField('nombre', 'Nombres', Icon(Icons.person))),
                  const SizedBox(width: 10),
                  Expanded(child: _buildPlainField('apellido', 'Apellidos', Icon(Icons.person))),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(child: _buildPlainField('telefono', 'Número de teléfono', Icon(Icons.phone))),
                  const SizedBox(width: 10),
                  Expanded(child: _buildPlainField('cedula', 'Numero de cédula', Icon(Icons.numbers))),
                ],
              ),
              const SizedBox(height: 10),
              _buildPlainField('email', 'Correo electrónico', Icon(Icons.email)),
              const SizedBox(height: 10),
              _buildPasswordField('password', 'Contraseña', Icon(Icons.lock)),
              const SizedBox(height: 30),
              Center(
                child: loading
                    ? const CircularProgressIndicator()
                    : SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: ElevatedButton(
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              final nombre = _controllers['nombre']!.text.trim();
                              final apellido = _controllers['apellido']!.text.trim();
                              final telefono = _controllers['telefono']!.text.trim();
                              final email = _controllers['email']!.text.trim();
                              final password = _controllers['password']!.text.trim();
                              final cedula = _controllers['cedula']!.text.trim();

                              register(nombre, apellido, telefono, cedula, email, password);
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: colorPrimary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Registrar',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlainField(String key, String hint, Icon? iconField) {
    return TextFormField(
      controller: _controllers[key],
      focusNode: _focusNodes[key],
      decoration: InputDecoration(
        prefixIcon: iconField,
        hintText: hint,
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.grey),
        ),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Este campo es obligatorio';
        }
        return null;
      },
    );
  }

  Widget _buildPasswordField(String key, String hint, Icon? iconField) {
    return TextFormField(
      controller: _controllers[key],
      focusNode: _focusNodes[key],
      obscureText: true,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.white,
        prefixIcon: iconField,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      validator: (value) =>
          value == null || value.isEmpty ? 'Este campo es obligatorio' : null,
    );
  }
}
