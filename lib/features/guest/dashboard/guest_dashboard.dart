import 'package:desole_app/features/guest/explore/explore_screen.dart';
import 'package:desole_app/features/guest/profile/account_screen.dart';
import 'package:flutter/material.dart';

class GuestDashboard extends StatefulWidget{
  final String nombre;
  final String rol;
  
  const GuestDashboard({
    super.key,
    required this.nombre ,
    required this.rol, 
    });
  @override
  State<GuestDashboard> createState() => _GuestDashboardState();
}
class _GuestDashboardState extends State<GuestDashboard>{
  int currentPageIndex = 0;
  
  @override

  Widget build(BuildContext context) {
    final List<Widget> _pages =[
    ExploreScreen(),
    Center(child: Text('Está en implementación. Vuelva pronto')),
    Center(child: Text('Está en implementación. Vuelva pronto')),
    AccountScreen(nombre: widget.nombre , rol: widget.rol,),
  ];
    return Scaffold(
      body: _pages[currentPageIndex],
      bottomNavigationBar: userNavigationBar(
        currentIndex : currentPageIndex,
        onTabSelected : (int index){
          setState(() {
            currentPageIndex = index;
          });
        }

      ),
    
    );
  }

}
Widget userNavigationBar({required int currentIndex , required Function(int) onTabSelected}){
  return NavigationBar(
    selectedIndex: currentIndex,
    onDestinationSelected: onTabSelected,
   destinations : const <NavigationDestination>[
            NavigationDestination(
              selectedIcon: Icon(Icons.explore),
              icon: Icon(Icons.explore_outlined), 
              label: 'Explorar'),
            NavigationDestination(
              selectedIcon: Icon(Icons.favorite),
              icon: Icon(Icons.favorite_outline), 
              label: 'Favoritos'),
            NavigationDestination(
              selectedIcon: Icon(Icons.home_repair_service), 
              icon: Icon(Icons.home_repair_service_outlined), 
              label: 'Reservas'),
            NavigationDestination(
              selectedIcon: Icon(Icons.person_2),
              icon: Icon(Icons.person_2_outlined), 
              label: 'Cuenta'),
          ],
      
  );
}
