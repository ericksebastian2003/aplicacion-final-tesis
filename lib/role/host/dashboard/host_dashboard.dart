import 'package:flutter/material.dart';
import 'package:desole_app/role/host/account/account_host_screen.dart';
import 'package:desole_app/role/host/advertisements/advertisements_screen.dart';
import 'package:desole_app/role/host/reserves/reserves_screen.dart';

class HostDashboard extends StatefulWidget {
  final String rol;
  final String nombre;
  final String hostId; // ✅ Campo agregado

  const HostDashboard({
    super.key,
    required this.rol,
    required this.nombre,
    required this.hostId, // ✅ Campo agregado
  });

  @override
  State<HostDashboard> createState() => _HostDashboardState();
}

class _HostDashboardState extends State<HostDashboard> {
  int currentPageIndex = 0;

  @override
  Widget build(BuildContext context) {
    final List<Widget> _pages = [
      AdvertisementsScreen(),
      ReservesScreen(),
      AccountHostScreen(nombre: widget.nombre, rol: widget.rol),
    ];

    return Scaffold(
      body: _pages[currentPageIndex],
      bottomNavigationBar: hostNavigationBar(
        currentIndex: currentPageIndex,
        onTabSelected: (int index) {
          setState(() {
            currentPageIndex = index;
          });
        },
      ),
    );
  }
}

Widget hostNavigationBar({
  required int currentIndex,
  required Function(int) onTabSelected,
}) {
  return NavigationBar(
    selectedIndex: currentIndex,
    onDestinationSelected: onTabSelected,
    destinations: const <NavigationDestination>[
      NavigationDestination(
        selectedIcon: Icon(Icons.announcement),
        icon: Icon(Icons.announcement_outlined),
        label: 'Anuncios',
      ),
      NavigationDestination(
        selectedIcon: Icon(Icons.home_repair_service),
        icon: Icon(Icons.home_repair_service_outlined),
        label: 'Reservas',
      ),
      NavigationDestination(
        selectedIcon: Icon(Icons.person_2),
        icon: Icon(Icons.person_2_outlined),
        label: 'Cuenta',
      ),
    ],
  );
}
