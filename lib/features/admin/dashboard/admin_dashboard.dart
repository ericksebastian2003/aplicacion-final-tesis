
import 'package:flutter/material.dart';
import '../reports/report_screen.dart';
class AdminDashboard extends StatefulWidget {
  final String nombre;
  final String rol;

  const AdminDashboard({
    super.key, 
    required this.nombre,
    required this.rol ,
  });

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}
class _AdminDashboardState extends State<AdminDashboard>{

  int currentPageIndex = 0;
  
  @override
  Widget build(BuildContext context) {
    final List<Widget> _pages = [
      ReportScreen(),
       Center(child: Text('Favoritos')),
      Center(child: Text('Favoritos')),

    ];

    return Scaffold(
      
      body: _pages[currentPageIndex],
      bottomNavigationBar: userNavigationBar(
        currentIndex: currentPageIndex, 
        onTabSelected: (int index){
          setState(() {
            currentPageIndex = index;
          });
        },
        ),
    );
  }
}
Widget userNavigationBar({
  required int currentIndex,
  required Function(int) onTabSelected
}){
  return NavigationBar(
    selectedIndex: currentIndex,
    onDestinationSelected: onTabSelected,
    destinations: const <NavigationDestination>[
      NavigationDestination(
        selectedIcon: Icon(Icons.announcement_rounded),
        icon: Icon(Icons.announcement_outlined), 
        label: 'Reportes'
        ),
        NavigationDestination(
          selectedIcon: Icon(Icons.hotel_rounded),
          icon: Icon(Icons.hotel_outlined), 
          label: 'Reservas'),
        NavigationDestination(
          selectedIcon: Icon(Icons.person_2_rounded),
          icon: Icon(Icons.person_2_outlined), 
          label: 'Perfil')
    ],
  );
}
