import 'package:desole_app/role/host/dashboard/host_dashboard.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/auth_service.dart';
import '../admin/dashboard/admin_dashboard.dart';
import '../guest/dashboard/guest_dashboard.dart';
import 'register_screen.dart';
import '../../data/models/Usuarios.dart';
import 'dart:convert';
import 'package:desole_app/providers/session_provider.dart';
import 'package:provider/provider.dart';
import './widgets/recuperar_password.dart';
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final Color colorPrimary = const Color(0xFF001D5A);
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();

  final String phoneNumber = '593969939834';
  final String message = 'Necesito información de este alojamiento';
  final authService = AuthService();

  bool loading = false;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _emailFocusNode.addListener(() => setState(() {}));
    _passwordFocusNode.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  void login() async {
  if (!_formKey.currentState!.validate()) return;

  final email = _emailController.text.trim();
  final password = _passwordController.text.trim();
  // print('Datos enviados al loginUser: {email: $email, password: $password}');

  setState(() => loading = true);
  try {
    final result = await authService.loginUser(email, password);
   //  print('Respuesta login: $result');

    if (result != null && result['token'] != null ) {
      final user = Usuarios.fromJson(result);

      // Guardar sesión en SharedPreferences
      await saveSession(user);

      // Actualizar provider con la sesión
      final sessionProvider = Provider.of<SessionProvider>(context, listen: false);
      final rol = user.rol.isNotEmpty ? user.rol.first : '';
      sessionProvider.login(user.id ?? '', user.email ?? '', user.nombre ?? '', rol);

      // Navegar según rol
      handleLoginSuccess(user);

    } else if (result != null && result['status'] == 'error') {
  final message = result['message'] ?? result['msg'] ?? 'Error desconocido';

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text('❌ $message'),
      backgroundColor: Colors.redAccent,
      behavior: SnackBarBehavior.floating,
      duration: const Duration(seconds: 4),
    ),
  );
}
 else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Usuario o contraseña incorrectos')),
      );
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error de autenticación: ${e.toString()}')),
    );
    // print('Error de autenticación: ${e.toString()}');
  } finally {
    setState(() => loading = false);
  }
}


  Future<void> saveSession(Usuarios user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('_usuario', jsonEncode(user.toJson()));

    // Guarda el token por separado
    await prefs.setString('token', user.token ?? '');

    // Muestra en consola
   //  print('Token guardado: ${user.token}');
  }

  void handleLoginSuccess(Usuarios user) {
  final rol = user.rol.isNotEmpty ? user.rol.first : '';
  final Widget destination;

  // Obtener instancia del provider aquí
  final sessionProvider = Provider.of<SessionProvider>(context, listen: false);

  if (rol == 'admin') {
    destination = AdminDashboard(nombre: user.nombre, rol: rol);
  } else if (rol == 'huesped') {
    destination = GuestDashboard(nombre: user.nombre, rol: rol);
  } else if (rol == 'anfitrion') {
    destination = HostDashboard(
      nombre: user.nombre,
      rol: rol,
      hostId: sessionProvider.idUsuario ?? '',
 // Aquí usas el provider
    );
  } else {
    destination = const LoginScreen();
  }

  Navigator.pushReplacement(
    context,
    MaterialPageRoute(builder: (_) => destination),
  );
}


@override
Widget build(BuildContext context) {
  final screenHeight = MediaQuery.of(context).size.height;

  return Scaffold(
    backgroundColor: Colors.grey[100],
    body: SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 12),
              const Text(
                'HOTEL\'S',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 30),
              const Text(
                'Bienvenido de nuevo',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Inicia sesión con tu cuenta',
                style: TextStyle(color: Colors.black54, fontSize: 16),
              ),
              const SizedBox(height: 32),

              /// EMAIL
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                style: const TextStyle(fontSize: 16),
                decoration: InputDecoration(
                  labelText: 'Correo electrónico',
                  prefixIcon: const Icon(Icons.email_outlined),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Ingrese su correo';
                  if (!value.contains('@')) return 'Correo inválido';
                  return null;
                },
              ),
              const SizedBox(height: 24),

              /// PASSWORD
              TextFormField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                style: const TextStyle(fontSize: 16),
                decoration: InputDecoration(
                  labelText: 'Contraseña',
                  prefixIcon: const Icon(Icons.lock_outline),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(_obscurePassword
                        ? Icons.visibility
                        : Icons.visibility_off),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Ingrese su contraseña';
                  if (value.length < 6) return 'Mínimo 6 caracteres';
                  return null;
                },
              ),

              const SizedBox(height: 35),

              /// BOTÓN LOGIN
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: loading ? null : login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: loading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Ingresar',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 20),
              GestureDetector(
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const RecuperarPassword()),
    );
  },
  child: const Text(
    '¿Has olvidado tu contraseña?',
    style: TextStyle(
      color: Colors.black54,
      fontSize: 17,
      
    ),
  ),
),

              const SizedBox(height: 30),

              /// REGISTRO
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    '¿No tienes una cuenta? ',
                    style: TextStyle(color: Colors.black54, fontSize: 17),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const RegisterScreen()),
                      );
                    },
                    child: Text(
                      'Regístrate',
                      style: TextStyle(
                        color: colorPrimary,
                        fontWeight: FontWeight.bold,
                        fontSize: 17,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
}