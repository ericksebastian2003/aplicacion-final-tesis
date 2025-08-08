import 'package:desole_app/role/auth/widgets/update_password.dart';
import 'package:desole_app/services/auth_service.dart';
import 'package:flutter/material.dart';

class RecuperarPassword extends StatefulWidget {
  const RecuperarPassword({super.key});

  @override
  State<RecuperarPassword> createState() => _RecuperarPasswordState();
}

class _RecuperarPasswordState extends State<RecuperarPassword> {
  final Color colorPrimary = const Color(0xFF001D5A);
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _emailFocusNode = FocusNode();

  final authService = AuthService();
  bool loading = false;

  @override
  void initState() {
    super.initState();
    _emailFocusNode.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _emailController.dispose();
    _emailFocusNode.dispose();
    super.dispose();
  }

  void _recuperarContrasenia() async {
    if (!_formKey.currentState!.validate()) return;

    final email = _emailController.text.trim();

    setState(() => loading = true);
    try {
      final result = await authService.recuperarPassword(email);

      if (result != null && result['status'] != 'error') {
        final message = result['message'] ?? result['msg'] ?? 'Correo enviado';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ $message'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );

        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ActualizarPassword()),
        );
      } else {
        final message = result?['message'] ?? result?['msg'] ?? 'Error desconocido';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ $message'),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error inesperado: ${e.toString()}'),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Recuperar la contraseña'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: colorPrimary,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: colorPrimary.withOpacity(0.5),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.lock_reset_outlined,
                  color: Colors.white,
                  size: 48,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Recupera tu contraseña fácilmente',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              const Text(
                'Introduce tu correo electrónico para enviarte un enlace de recuperación.',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black54,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              Form(
                key: _formKey,
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _emailController,
                        focusNode: _emailFocusNode,
                        keyboardType: TextInputType.emailAddress,
                        style: const TextStyle(fontSize: 16),
                        decoration: InputDecoration(
                          labelText: 'Correo electrónico',
                          prefixIcon: const Icon(Icons.email_outlined),
                          filled: true,
                          fillColor: Colors.grey[100],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: colorPrimary, width: 2),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'Ingrese su correo';
                          if (!RegExp(r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$").hasMatch(value)) {
                            return 'Correo inválido';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 36),
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: loading ? null : _recuperarContrasenia,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: colorPrimary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 5,
                          ),
                          child: loading
                              ? const CircularProgressIndicator(color: Colors.white)
                              : const Text(
                                  'Recuperar contraseña',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
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
    );
  }
}
