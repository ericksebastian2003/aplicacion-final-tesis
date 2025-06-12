import 'package:desole_app/role/guest/profile/widgets/deposit_balance.dart';
import 'package:desole_app/services/users_services.dart';
import 'package:flutter/material.dart';

class SaldoPage extends StatefulWidget {
  const SaldoPage({super.key});

  @override
  _SaldoPageState createState() => _SaldoPageState();
}

class _SaldoPageState extends State<SaldoPage> {
  double _saldo = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _cargarSaldo();
  }

  Future<void> _cargarSaldo() async {
    try {
      final userService = UsersServices();
      final profile = await userService.getUserProfile();
      setState(() {
        final rawSaldo = profile?['saldo'];
        _saldo = rawSaldo is num ? rawSaldo.toDouble() : 0;
        _isLoading = false;
      });
    } catch (e) {
      print('Error al obtener el saldo: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi saldo'),
        centerTitle: true,
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
                            'Saldo disponible',
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
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        backgroundColor: Colors.black,
                      ),
                      onPressed: () async {
                        // Al volver, actualizamos el saldo
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const DepositoPage()),
                        );
                        _cargarSaldo();
                      },
                      child: const Text(
                        'Depositar',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
