import 'package:desole_app/data/providers/form_alojamiento_provider.dart';
import 'package:flutter/material.dart';
import 'features/host/dashboard/host_dashboard.dart';
import 'features/guest/dashboard/guest_dashboard.dart';
import 'features/admin/dashboard/admin_dashboard.dart';
import 'features/auth/widgets/login_screen.dart';
import 'providers/session_provider.dart';
import 'package:provider/provider.dart';
void main() async {


  WidgetsFlutterBinding.ensureInitialized();  
  final sessionProvider = SessionProvider();
  await sessionProvider.loadSessionFromPrefs();

  runApp(
    MultiProvider(providers: [

    ChangeNotifierProvider(
      create: (_) => sessionProvider,
      
    ),
    ChangeNotifierProvider(
      create: (_) => FormAlojamientoProvider(),
      
    ),

    ],
    child: const MyApp(),
  )
  );
}

class MyApp extends StatelessWidget {


  const MyApp({
    super.key,
    
  });

  @override
  Widget build(BuildContext context) {
    final sessionProvider = Provider.of<SessionProvider>(context);
    Widget startWidget;
    if(!sessionProvider.isSessionLoaded){
      startWidget = const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    else if (sessionProvider.isLoggedIn && sessionProvider.email  != null && sessionProvider.rol != null) {
      switch (sessionProvider.rol){
      case 'admin' :
        startWidget = AdminDashboard(nombre: sessionProvider.fullName! , rol: 'admin',);
        break;
      case  'huesped' :
        startWidget = GuestDashboard(nombre: sessionProvider.fullName!, rol: 'huesped');
        break;
      case  'anfitrion' : 
startWidget = HostDashboard(nombre: sessionProvider.fullName!, rol: 'anfitrion', hostId: sessionProvider.idUsuario!);
        break;
      default :
        startWidget = const LoginScreen();
    }

    } else {
      startWidget = const LoginScreen();
    }

    return MaterialApp(
    
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 13, 40, 199),
        ),
        useMaterial3: true,
      ),
      home: startWidget,
    );
  }
}
