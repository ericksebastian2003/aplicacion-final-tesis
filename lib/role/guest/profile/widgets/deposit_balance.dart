import 'package:desole_app/role/guest/dashboard/guest_dashboard.dart';
import 'package:desole_app/services/users_services.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DepositoPage extends StatefulWidget {
  const DepositoPage({super.key});

  @override
  State<DepositoPage> createState() => _DepositoPageState();
}

class _DepositoPageState extends State<DepositoPage> {
  final _formKey = GlobalKey<FormState>();
  final _cardController = TextEditingController();
  final _nameController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvvController = TextEditingController();
  final _montoController = TextEditingController();

  bool isLoading = false;

  final List<double> montosRapidos = [10, 20, 50, 100, 200];

  void _seleccionarMonto(double monto) {
    setState(() {
      _montoController.text = monto.toStringAsFixed(2);
    });
  }

  Future<void> _hacerDeposito() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    final service = UsersServices();
    final prefs = await SharedPreferences.getInstance();
    final nombreUser = prefs.getString('userName') ?? '';
    final role = prefs.getString('userRole') ?? '';

    final monto = double.parse(_montoController.text);

    final dataBalance = {
      "monto": monto,
    };

    final success = await service.depositBalance(dataBalance);

    if (success) {
      _montoController.clear();

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) => GuestDashboard(nombre: nombreUser, rol: role),
        ),
        (route) => false,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('❌ Error al realizar el depósito')),
      );
    }

    setState(() => isLoading = false);
  }

  @override
  void dispose() {
    _cardController.dispose();
    _nameController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    _montoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Depósito con Tarjeta'),
        backgroundColor: Colors.green.shade700,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Card(
          elevation: 5,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  const Text(
                    'Ingresa los datos de tu tarjeta',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _cardController,
                    maxLength: 19,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Número de tarjeta',
                      hintText: 'XXXX XXXX XXXX XXXX',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.credit_card),
                    ),
                    validator: (value) {
                      if (value == null || value.length < 16) return 'Número inválido';
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Nombre del titular',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.person),
                    ),
                    validator: (value) => value == null || value.isEmpty ? 'Campo requerido' : null,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _expiryController,
                          maxLength: 5,
                          decoration: const InputDecoration(
                            labelText: 'Expira',
                            hintText: 'MM/AA',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) =>
                              value == null || value.length != 5 ? 'Formato inválido' : null,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: _cvvController,
                          maxLength: 4,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'CVV',
                            hintText: '3 o 4 dígitos',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) =>
                              value == null || value.length < 3 ? 'CVV inválido' : null,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _montoController,
                    keyboardType: TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      labelText: 'Monto a transferir',
                      prefixIcon: Icon(Icons.attach_money),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Ingrese un monto';
                      final parsed = double.tryParse(value);
                      if (parsed == null || parsed <= 0) return 'Monto inválido';
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 10,
                    children: montosRapidos.map((monto) {
                      return ElevatedButton(
                        onPressed: () => _seleccionarMonto(monto),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green.shade100,
                          foregroundColor: Colors.green.shade900,
                        ),
                        child: Text('\$${monto.toStringAsFixed(0)}'),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : _hacerDeposito,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.shade700,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              'Depositar',
                              style: TextStyle(fontSize: 18, color: Colors.white),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
