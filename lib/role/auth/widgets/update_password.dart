import 'package:flutter/material.dart';
import 'package:desole_app/services/auth_service.dart';

class ActualizarPassword extends StatefulWidget {
  const ActualizarPassword({super.key});

  @override
  State<ActualizarPassword> createState() => _ActualizarPasswordState();
}

class _ActualizarPasswordState extends State<ActualizarPassword> {
  final _formKey = GlobalKey<FormState>();
  final _tokenController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  bool loading = false;
  final Color colorPrimary = const Color(0xFF001D5A);

  final authService = AuthService();

  void _actualizarPassword() async {
    if (!_formKey.currentState!.validate()) return;

    final password = _passwordController.text.trim();
    final confirm = _confirmController.text.trim();

    if (password != confirm) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Las contraseñas no coinciden'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    setState(() => loading = true);
    final success = await authService.updatePassword(_tokenController.text.trim(), password);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Contraseña actualizada correctamente'),
          backgroundColor: Colors.green,
        ),
      );
      // Opcional: redirigir al login u otra pantalla
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No se pudo actualizar la contraseña'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }

    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Actualizar Contraseña',style: TextStyle(color: Colors.white)),
        backgroundColor: colorPrimary,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Token de recuperación',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Por favor, ingrese el token que recibió en su correo para validar su identidad.',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _tokenController,
                        decoration: InputDecoration(
                          labelText: 'Token',
                          hintText: 'Ejemplo: 123abc456def',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          prefixIcon: const Icon(Icons.vpn_key_outlined),
                        ),
                        validator: (value) =>
                            value == null || value.isEmpty ? 'Ingrese el token' : null,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Nueva contraseña
                const Text(
                  'Nueva contraseña',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Contraseña',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: const Icon(Icons.lock_outline),
                  ),
                  validator: (value) =>
                      value == null || value.length < 6 ? 'Mínimo 6 caracteres' : null,
                ),
                const SizedBox(height: 24),

                // Confirmar contraseña
                const Text(
                  'Confirmar contraseña',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _confirmController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Confirmar contraseña',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: const Icon(Icons.lock_outline),
                  ),
                  validator: (value) =>
                      value == null || value.isEmpty ? 'Confirme su contraseña' : null,
                ),
                const SizedBox(height: 36),

                SizedBox(
                  height: 50,
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: loading ? null : _actualizarPassword,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 6,
                      shadowColor: colorPrimary.withOpacity(0.6),
                    ),
                    child: loading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            'Actualizar contraseña',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 1.1,
                            ),
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
