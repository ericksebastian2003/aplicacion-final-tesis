import 'package:desole_app/role/guest/dashboard/guest_dashboard.dart';
import 'package:desole_app/services/users_services.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import './my_balance.dart';
class DepositoPage extends StatefulWidget {
  const DepositoPage({super.key});

  @override
  State<DepositoPage> createState() => _DepositoPageState();
}

class _DepositoPageState extends State<DepositoPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _montoController = TextEditingController();


  final List<double> montosRapidos = [10, 20, 50, 100, 200];

  
  void _hacerDeposito() async {
  if (_formKey.currentState!.validate()) {
    final service = UsersServices(); // no es necesario hacer `await` aquí
    final prefs = await SharedPreferences.getInstance();
    final nombreUser = prefs.getString('userName') ?? '';
    final role = prefs.getString('userRole') ?? '';

    final monto = double.parse(_montoController.text);


    final dataBalance = {
      "monto": monto,
    };

    final success = await service.depositBalance(dataBalance);
    print(success);

    if (success) {
      _montoController.clear();
       final prefs = await SharedPreferences.getInstance();
                        
            await Navigator.of(context).pushAndRemoveUntil(
                       MaterialPageRoute(
                        builder: (context) => GuestDashboard(nombre: nombreUser, rol: role,
                  
                        ),
                      ),
                      (Route<dynamic> route) => false
                          );
   
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ocurrió un error al realizar el depósito')),
      );
    }
  }
}


  void _seleccionarMonto(double monto) {
    setState(() {
      _montoController.text = monto.toStringAsFixed(2);
    });
  }

  @override
  void dispose() {
  
    _montoController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Transferencia de Saldo'),
  
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Card(
            elevation: 6,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    Text(
                      'Realiza un depósito a tu cuenta',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 20),
                    TextFormField(
                      controller: _montoController,
                      decoration: InputDecoration(
                        labelText: 'Monto a transferir',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.attach_money),
                      ),
                      keyboardType: TextInputType.numberWithOptions(decimal: true),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Ingrese un monto';
                        }
                        final monto = double.tryParse(value);
                        if (monto == null || monto <= 0) {
                          return 'Monto inválido';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 12),

                    Wrap(
                      spacing: 10,
                      children: montosRapidos.map((monto) {
                        return ElevatedButton(
                          onPressed: () => _seleccionarMonto(monto),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue.shade100,
                            foregroundColor: Colors.blue.shade800,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Text('\$${monto.toStringAsFixed(0)}'),
                        );
                      }).toList(),
                    ),
                    SizedBox(height: 16),

                    SizedBox(height: 24),

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
                        _hacerDeposito();
                      },
                      child: const Text(
                        'Transferir',
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
            ),
          ),
        ),
      ),
    );
  }
}
