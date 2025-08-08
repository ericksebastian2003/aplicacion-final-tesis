import 'package:desole_app/role/admin/account/profile_admin_screen.dart';
import 'package:desole_app/services/users_services.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
import '../../auth/login_screen.dart';

class AccountAdminScreen extends StatefulWidget {
  final String nombre;
  final String rol;

  const AccountAdminScreen({super.key, required this.rol, required this.nombre});

  @override
  State<AccountAdminScreen> createState() => _AccountAdminScreenState();
}

class _AccountAdminScreenState extends State<AccountAdminScreen> {
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



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cuenta',
          style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
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
                        MaterialPageRoute(builder: (context) => ProfileAdminScreen()),
                      );
                    },
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
      
    );
  }
}
