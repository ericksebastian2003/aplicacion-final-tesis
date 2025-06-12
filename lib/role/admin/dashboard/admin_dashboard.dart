import 'package:desole_app/role/admin/account/account_admin_screen.dart';
import 'package:desole_app/role/admin/reserves/reserves_screen.dart';
import 'package:flutter/material.dart';


class AdminDashboard extends StatefulWidget {
  final String nombre;
  final String rol;
  
  const AdminDashboard({
    super.key,
    required this.nombre ,
    required this.rol, 
    });

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int currentPageIndex = 0;

  @override
  Widget build(BuildContext context) {
    final List<Widget> _pages = [
      Center(child: Text('Módulo de Quejas')),
      Center(child: Text('Módulo de Reportes')),
      ReservesAdminScreen(),
      AccountAdminScreen(nombre: widget.nombre , rol: widget.rol,),
      
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
        label: 'Quejas',
      ),
      NavigationDestination(
        selectedIcon: Icon(Icons.announcement),
        icon: Icon(Icons.announcement_outlined),
        label: 'Reportes',
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
