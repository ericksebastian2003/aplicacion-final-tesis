import 'package:desole_app/services/users_services.dart';
import 'package:flutter/material.dart';

class SaldoPageAdmin extends StatefulWidget {
  const SaldoPageAdmin({super.key});

  @override
  _SaldoPageAdminState createState() => _SaldoPageAdminState();
}

class _SaldoPageAdminState extends State<SaldoPageAdmin> {
  double _saldo = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _cargarSaldoAdmin();
  }

  Future<void> _cargarSaldoAdmin() async {
  try {
    final userService = UsersServices();
    final data = await userService.getBalanceForHost();
    setState(() {
      _saldo = data?['saldoGenerado']?.toDouble() ?? 0;
      _isLoading = false;
    });
  } catch (e) {
    print('Error al obtener el saldo y pagos: $e');
    setState(() {
      _isLoading = false;
    });
  }
}



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis ganancias' , style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
),
        
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Container(
              padding: const EdgeInsets.all(20),
              width: double.infinity,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Card(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    elevation: 8,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 40, horizontal: 30),
                      child: Column(
                        children: [
                          Text(
                            'Ganancias',
                            style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey[700]),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            '\$${_saldo.toStringAsFixed(2)}',
                            style: TextStyle(
                                fontSize: 42,
                                fontWeight: FontWeight.bold,
                                color: Colors.green[700]),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  
                ],
              ),
            ),
    );
  }
}
