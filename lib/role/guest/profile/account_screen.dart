import 'dart:convert';
import 'package:desole_app/role/guest/dashboard/guest_dashboard.dart';
import 'package:desole_app/role/guest/pays/my_pays.dart';
import 'package:desole_app/role/guest/profile/widgets/deposit_balance.dart';
import 'package:desole_app/role/guest/profile/widgets/my_balance.dart';
import 'package:desole_app/role/guest/profile/widgets/my_complaints.dart';
import 'package:desole_app/role/guest/profile/widgets/profile_guest_screen.dart';
import 'package:desole_app/providers/session_provider.dart';
import 'package:desole_app/services/users_services.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
import 'package:provider/provider.dart';
import '../../auth/login_screen.dart';
import '../../host/dashboard/host_dashboard.dart';

class AccountScreen extends StatefulWidget {
  final String nombre;
  final String rol;

  const AccountScreen({super.key, required this.rol, required this.nombre});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  final UsersServices usersServices = UsersServices();
  Map<String, dynamic>? userData;
  bool _isLoading = true;
  late String _rolActual;
  String? profileImageUrl;

  final Color colorPrimary = const Color(0xFF001D5A);
  final Dio dio = Dio();

  @override
  void initState() {
    super.initState();
    _rolActual = widget.rol;
    loadUserData();
  }

  Future<void> loadUserData() async {
    final data = await usersServices.getUserProfile();
    if (data != null) {
      setState(() {
        userData = data;
        profileImageUrl = userData?['urlFotoPerfil'];
        _isLoading = false;
      });
    } else {
      print('No se pudo obtener el perfil');
    }
  }

  Future<void> logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  Future<void> _cambiarRol() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Token no encontrado. Vuelve a iniciar sesión.')),
      );
      return;
    }

    final nuevoRol = _rolActual == 'huesped' ? 'anfitrion' : 'huesped';

    try {
      final response = await dio.put(
        'https://hospedajes-4rmu.onrender.com/api/usuarios/rol',
        data: {'rol': nuevoRol},
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.statusCode == 200) {
        await prefs.setString('rol', nuevoRol);

        if (!mounted) return;

        final sessionProvider = Provider.of<SessionProvider>(context, listen: false);
        final hostId = sessionProvider.idUsuario ?? '';

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (_) => nuevoRol == 'anfitrion'
                ? HostDashboard(
                    nombre: widget.nombre,
                    rol: nuevoRol,
                    hostId: hostId,
                  )
                : GuestDashboard(nombre: widget.nombre, rol: nuevoRol),
          ),
          (route) => false,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cambiar rol: ${response.statusMessage}')),
        );
      }
    } on DioException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.response?.data ?? e.message}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Cuenta',
          style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundImage: profileImageUrl != null && profileImageUrl!.isNotEmpty
                            ? NetworkImage(profileImageUrl!)
                            : const AssetImage('assets/default_profile.png') as ImageProvider,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${userData?['nombre'] ?? ''} ${userData?['apellido'] ?? ''}',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Rol actual: $_rolActual',
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Opciones de Usuario',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.person),
                    title: const Text('Editar Perfil'),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => ProfileGuestScreen()),
                      );
                    },
                  ),
          
                  const SizedBox(height: 10),
                  const Text(
                    'Opciones de pago',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.attach_money_rounded),
                    title: const Text('Mi saldo'),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => SaldoPage()),
                      );
                    }
                    ),
                  
                   ListTile(
                    leading: const Icon(Icons.payments_rounded),
                    title: const Text('Mis pagos'),
                    onTap:  () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => MyPaysScreen()),
                      );
                    }
                    ),
                   const SizedBox(height: 10),
                  const Text(
                    'Opciones de reportes',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                  const Divider(),
                   ListTile(
                    leading: const Icon(Icons.report_problem),
                    title: const Text('Mis reportes'),
                    onTap:  () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => ReportesGuestScreen()),
                      );
                    }
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Cerrar sesión',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.logout_outlined),
                    title: const Text('Cerrar sesión'),
                    onTap: () => logout(context),
                  ),
                ],
              ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        onPressed: _cambiarRol,
        foregroundColor: Colors.white,
        backgroundColor: Colors.black,
        icon: const Icon(Icons.swap_horiz),
        label: Text('Cambiar a ${_rolActual == 'huesped' ? 'Anfitrión' : 'Huésped'}'),
      ),
    );
  }
}
