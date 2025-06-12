import 'package:desole_app/role/host/dashboard/host_dashboard.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/auth_service.dart';
import '../admin/dashboard/admin_dashboard.dart';
import 'package:url_launcher/url_launcher.dart';
import '../guest/dashboard/guest_dashboard.dart';
import 'register_screen.dart';
import '../../data/models/Usuarios.dart';
import 'dart:convert';
import 'package:desole_app/providers/session_provider.dart';

import 'package:provider/provider.dart';

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
  print('Datos enviados al loginUser: {email: $email, password: $password}');

  setState(() => loading = true);
  try {
    final result = await authService.loginUser(email, password);
    print('Respuesta login: $result');

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

    } else if (result != null && result['error'] != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['error'])),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Usuario o contraseña incorrectos')),
      );
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error de autenticación: ${e.toString()}')),
    );
    print('Error de autenticación: ${e.toString()}');
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
    print('Token guardado: ${user.token}');
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


  void openWhatsApp() async {
    final url = 'https://wa.me/$phoneNumber?text=${Uri.encodeComponent(message)}';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo abrir WhatsApp')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E2A5A),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 30),
                  color: const Color(0xFF1E2A5A),
                  child: Column(
                    children: const [
                      Icon(Icons.hotel, color: Colors.white, size: 60),
                      SizedBox(height: 10),
                      Text(
                        "HOTEL'S",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.all(20),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE0E0E0),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        const Text(
                          'INICIAR SESIÓN',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E2A5A),
                          ),
                        ),
                        const SizedBox(height: 25),
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            labelText: 'Correo electrónico',
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Ingrese su correo';
                            }
                            if (!value.contains('@')) {
                              return 'Correo inválido';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          decoration: InputDecoration(
                            labelText: 'Contraseña',
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword ? Icons.visibility : Icons.visibility_off,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Ingrese su contraseña';
                            }
                            if (value.length < 6) {
                              return 'Mínimo 6 caracteres';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 30),
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton(
                            onPressed: loading ? null : login,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF1E2A5A),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                            child: loading
                                ? const CircularProgressIndicator(
                                    color: Colors.white,
                                  )
                                : const Text(
                                    'INGRESAR',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: Colors.white,
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'Si aún no tienes una cuenta,',
                          style: TextStyle(color: Colors.black54),
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          width: double.infinity,
                          height: 45,
                          child: OutlinedButton(
                            onPressed: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(builder: (_) => const RegisterScreen()),
                              );
                            },
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Color(0xFF1E2A5A), width: 2),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                            child: const Text(
                              'CREAR UNA CUENTA',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Color(0xFF1E2A5A),
                              ),
                            ),
                          ),
                        ),
                      ],
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
}
