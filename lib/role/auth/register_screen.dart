import 'package:desole_app/services/auth_service.dart';
import 'package:desole_app/role/auth/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final Color primaryColor = const Color(0xFF001D5A);
  bool loading = false;
  bool showPassword = false;
  bool _aceptTerms = false;

  final Map<String, TextEditingController> _controllers = {
    'nombre': TextEditingController(),
    'apellido': TextEditingController(),
    'telefono': TextEditingController(),
    'cedula': TextEditingController(),
    'email': TextEditingController(),
    'password': TextEditingController(),
  };

  final authService = AuthService();

  void register() async {
    if (!_formKey.currentState!.validate()) return;

    if (!_aceptTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Debes aceptar los Términos y Condiciones')),
      );
      return;
    }

    setState(() => loading = true);

    final userData = {
      'nombre': _controllers['nombre']!.text.trim(),
      'apellido': _controllers['apellido']!.text.trim(),
      'telefono': _controllers['telefono']!.text.trim(),
      'cedula': _controllers['cedula']!.text.trim(),
      'email': _controllers['email']!.text.trim(),
      'password': _controllers['password']!.text.trim(),
    };

    final response = await authService.register(userData);
    setState(() => loading = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(response['msg'] ?? 'Cuenta creada correctamente')),
    );

    if (response['status'] == 'success') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.black87),
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                    );
                  },
                ),
                const SizedBox(height: 10),
                Center(
                  child: Text(
                    'Crear Cuenta',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                _buildTextField('nombre', 'Nombres', Icons.person,
                    pattern: r'^[a-zA-ZáéíóúÁÉÍÓÚñÑ ]+$', errorMessage: 'Solo letras'),
                const SizedBox(height: 16),
                _buildTextField('apellido', 'Apellidos', Icons.person_outline,
                    pattern: r'^[a-zA-ZáéíóúÁÉÍÓÚñÑ ]+$', errorMessage: 'Solo letras'),
                const SizedBox(height: 16),
                _buildTextField('telefono', 'Teléfono', Icons.phone,
                    isNumeric: true, exactLength: 10),
                const SizedBox(height: 16),
                _buildTextField('cedula', 'Cédula', Icons.badge,
                    isNumeric: true, exactLength: 10),
                const SizedBox(height: 16),
                _buildTextField('email', 'Correo Electrónico', Icons.email),
                const SizedBox(height: 16),
                _buildPasswordField(),
                const SizedBox(height: 16),

                Row(
                  children: [
                    Checkbox(
                      value: _aceptTerms,
                      onChanged: (value) => setState(() => _aceptTerms = value ?? false),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () async {
                          const url = 'https://desoletravels.netlify.app/terminos-y-condiciones';
                          if (await canLaunchUrl(Uri.parse(url))) {
                            await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('No se pudo abrir el enlace')),
                            );
                          }
                        },
                        child: RichText(
                          text: TextSpan(
                            text: 'He leído y acepto los ',
                            style: const TextStyle(color: Colors.black87),
                            children: [
                              TextSpan(
                                text: 'Términos y Condiciones',
                                style: TextStyle(
                                  color: primaryColor,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                loading
                    ? const Center(child: CircularProgressIndicator())
                    : SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: register,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            elevation: 4,
                          ),
                          child: const Text(
                            'Registrar',
                            style: TextStyle(fontSize: 18, color: Colors.white),
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

  Widget _buildTextField(
    String key,
    String label,
    IconData icon, {
    bool isNumeric = false,
    int? exactLength,
    String? pattern,
    String? errorMessage,
  }) {
    return TextFormField(
      controller: _controllers[key],
      keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(
        prefixIcon: Icon(icon),
        hintText: label,
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Este campo es obligatorio';
        }
        if (exactLength != null && value.trim().length != exactLength) {
          return 'Debe tener exactamente $exactLength dígitos';
        }
        if (pattern != null && !RegExp(pattern).hasMatch(value.trim())) {
          return errorMessage ?? 'Formato inválido';
        }
        return null;
      },
    );
  }

  Widget _buildPasswordField() {
    return TextFormField(
      controller: _controllers['password'],
      obscureText: !showPassword,
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.lock),
        hintText: 'Contraseña',
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        suffixIcon: IconButton(
          icon: Icon(showPassword ? Icons.visibility_off : Icons.visibility),
          onPressed: () => setState(() => showPassword = !showPassword),
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
}
