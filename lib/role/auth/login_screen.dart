// Archivo: LoginScreen.dart

import 'package:desole_app/data/security/AuthResponse.dart';
import 'package:desole_app/role/host/dashboard/host_dashboard.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/auth_service.dart';
import '../admin/dashboard/admin_dashboard.dart';
import '../guest/dashboard/guest_dashboard.dart';
import 'register_screen.dart';
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

  // Variables de estado para el mensaje flotante
  String? _mensaje;
  bool _isError = false;

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

    setState(() {
      loading = true;
      _mensaje = null;
    });

    try {
      final result = await authService.loginUser(email, password);

      if (result != null && result['token'] != null) {
        final loginResponse = LoginResponse.fromJson(result);

        // Guardar sesión en SharedPreferences
        await saveSession(loginResponse);

        // Actualizar provider con la sesión
        final sessionProvider = Provider.of<SessionProvider>(context, listen: false);
        final rol = loginResponse.usuario.rol.isNotEmpty ? loginResponse.usuario.rol.first : '';
        sessionProvider.login(
          loginResponse.usuario.id,
          loginResponse.usuario.email,
          loginResponse.usuario.nombre,
          rol,
        );

        // Mensaje de éxito
        setState(() {
          _mensaje = '¡Inicio de sesión exitoso!';
          _isError = false;
        });
        
        // Navegar después de un pequeño retraso para mostrar el mensaje
        Future.delayed(const Duration(seconds: 2), () {
          handleLoginSuccess(loginResponse.usuario);
        });
      } else if (result != null && result['status'] == 'error') {
        final message = result['message'] ?? result['msg'] ?? 'Error desconocido';
        setState(() {
          _mensaje = '$message';
          _isError = true;
        });
      } else {
        setState(() {
          _mensaje = 'Usuario o contraseña incorrectos';
          _isError = true;
        });
      }
    } catch (e) {
      setState(() {
        _mensaje = 'Error de autenticación: ${e.toString()}';
        _isError = true;
      });
    } finally {
      setState(() => loading = false);
    }
  }

  Future<void> saveSession(LoginResponse loginResponse) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('_usuario', jsonEncode(loginResponse.usuario.toJson()));
    await prefs.setString('token', loginResponse.token);
  }

  void handleLoginSuccess(UserBasic user) {
    final rol = user.rol.isNotEmpty ? user.rol.first : '';
    final Widget destination;
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
      );
    } else {
      destination = const LoginScreen();
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => destination),
    );
  }

  // Método para construir el mensaje flotante (copiado de EditReservationScreen)
  Widget _buildMensaje() {
    if (_mensaje == null) return const SizedBox.shrink();

    // Después de un tiempo, oculta el mensaje
    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) {
        setState(() {
          _mensaje = null;
        });
      }
    });

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
                  color: _isError ? Colors.red.shade700 : Colors.green.shade700,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Stack(
        children: [
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 12),
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
                    const SizedBox(height: 60),
                    // ... tus campos de texto y botón ...
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
          // Aquí se muestra el mensaje flotante
          _buildMensaje(),
        ],
      ),
    );
  }
}