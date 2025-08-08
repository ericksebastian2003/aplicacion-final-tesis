import 'package:desole_app/providers/session_provider.dart';
import 'package:desole_app/services/users_services.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';

class DepositarTarjetaScreen extends StatefulWidget {
  const DepositarTarjetaScreen({super.key});

  @override
  State<DepositarTarjetaScreen> createState() => _DepositarTarjetaScreenState();
}

class _DepositarTarjetaScreenState extends State<DepositarTarjetaScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _cardController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _expiryController = TextEditingController();
  final TextEditingController _cvvController = TextEditingController();
  final TextEditingController _montoController = TextEditingController();

  bool hasSavedCard = false;
  String? savedCardNumber;
  String? savedCardHolder;
  String? savedExpiryDate;
  String? savedCvv;

  String? mensaje;
  bool isError = false;
  bool isLoading = false;

  // Colores personalizados
  final Color backgroundColor = Colors.white;
  final Color cardBackgroundColor = const Color(0xFF1C1C1C); // gris oscuro casi negro
  final Color buttonColor = Colors.black;
  final Color buttonTextColor = Colors.white;
  final Color textColor = Colors.black87;
  final Color labelColor = Colors.black54;

  @override
  void initState() {
    super.initState();
    _loadSavedCard();
  }

  Future<void> _loadSavedCard() async {
    final prefs = await SharedPreferences.getInstance();
    savedCardNumber = prefs.getString('cardNumber');
    savedCardHolder = prefs.getString('cardHolder');
    savedExpiryDate = prefs.getString('expiryDate');
    savedCvv = prefs.getString('cvv');

    if (savedCardNumber != null &&
        savedCardHolder != null &&
        savedExpiryDate != null &&
        savedCvv != null) {
      setState(() {
        hasSavedCard = true;
      });
    }
  }

  Future<void> _guardarTarjeta() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('cardNumber', _cardController.text);
    await prefs.setString('cardHolder', _nameController.text);
    await prefs.setString('expiryDate', _expiryController.text);
    await prefs.setString('cvv', _cvvController.text);
  }

  Future<void> _depositar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      isLoading = true;
      mensaje = null;
    });

    final sessionProvider = Provider.of<SessionProvider>(context, listen: false);
    final services = UsersServices();

    final dataBalance = {
      "monto": double.tryParse(_montoController.text) ?? 0,
    };

    try {
      final result = await services.depositBalance(dataBalance);

      if (result['success'] == true) {
        setState(() {
          mensaje = result['msg'];
          isError = false;
        });
        await _guardarTarjeta();
        await Future.delayed(const Duration(milliseconds: 1500));
        if (mounted) Navigator.pop(context);
      } else {
        setState(() {
          mensaje = result['msg'];
          isError = true;
        });
      }
    } catch (e) {
      setState(() {
        mensaje = 'Error inesperado al realizar el depósito.';
        isError = true;
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Widget _buildCardSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tarjeta guardada:',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textColor),
        ),
        const SizedBox(height: 10),
        Card(
          color: cardBackgroundColor,
          elevation: 8,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          shadowColor: Colors.black54,
          child: ListTile(
            leading: Icon(Icons.credit_card, color: Colors.black87, size: 32),
            title: Text(
              '**** **** **** ${savedCardNumber!.substring(savedCardNumber!.length - 4)}',
              style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white, fontSize: 18),
            ),
            subtitle: Text(savedCardHolder!, style: TextStyle(color: Colors.grey[400], fontSize: 14)),
            trailing: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: buttonColor,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                elevation: 5,
              ),
              onPressed: () {
                _cardController.text = savedCardNumber!;
                _nameController.text = savedCardHolder!;
                _expiryController.text = savedExpiryDate!;
                _cvvController.text = savedCvv!;
                setState(() {
                  hasSavedCard = false;
                });
              },
              child: Text('Usar esta tarjeta', style: TextStyle(color: buttonTextColor, fontWeight: FontWeight.w600)),
            ),
          ),
        ),
        TextButton(
          onPressed: () {
            setState(() {
              hasSavedCard = false;
            });
          },
          child: Text('Usar otra tarjeta', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }

  Widget _buildForm() {
    final inputBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: labelColor),
    );
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            controller: _cardController,
            style: TextStyle(color: textColor),
            decoration: InputDecoration(
              labelText: 'Número de tarjeta',
              labelStyle: TextStyle(color: labelColor),
              hintText: 'XXXX XXXX XXXX XXXX',
              hintStyle: TextStyle(color: labelColor.withOpacity(0.6)),
              border: inputBorder,
              enabledBorder: inputBorder,
              focusedBorder: inputBorder.copyWith(borderSide: BorderSide(color: Colors.black87, width: 2)),
              prefixIcon: Icon(Icons.credit_card, color: Colors.black87),
            ),
            keyboardType: TextInputType.number,
            maxLength: 19,
            validator: (value) {
              if (value == null || value.replaceAll(' ', '').length < 16) {
                return 'Número inválido';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _nameController,
            style: TextStyle(color: textColor),
            decoration: InputDecoration(
              labelText: 'Nombre del titular',
              labelStyle: TextStyle(color: labelColor),
              border: inputBorder,
              enabledBorder: inputBorder,
              focusedBorder: inputBorder.copyWith(borderSide: BorderSide(color: Colors.black87, width: 2)),
              prefixIcon: Icon(Icons.person, color: Colors.black87),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Campo requerido';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _expiryController,
                  style: TextStyle(color: textColor),
                  decoration: InputDecoration(
                    labelText: 'Fecha de expiración (MM/AA)',
                    labelStyle: TextStyle(color: labelColor),
                    border: inputBorder,
                    enabledBorder: inputBorder,
                    focusedBorder: inputBorder.copyWith(borderSide: BorderSide(color: Colors.black87, width: 2)),
                  ),
                  keyboardType: TextInputType.datetime,
                  maxLength: 5,
                  validator: (value) {
                    if (value == null || value.length != 5) {
                      return 'Formato inválido';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextFormField(
                  controller: _cvvController,
                  style: TextStyle(color: textColor),
                  decoration: InputDecoration(
                    labelText: 'CVV',
                    labelStyle: TextStyle(color: labelColor),
                    border: inputBorder,
                    enabledBorder: inputBorder,
                    focusedBorder: inputBorder.copyWith(borderSide: BorderSide(color: Colors.black87, width: 2)),
                  ),
                  keyboardType: TextInputType.number,
                  maxLength: 3,
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.length != 3) {
                      return 'CVV inválido';
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _montoController,
            style: TextStyle(color: textColor),
            decoration: InputDecoration(
              labelText: 'Monto a depositar',
              labelStyle: TextStyle(color: labelColor),
              prefixIcon: const Icon(Icons.attach_money, color: Color(0xFF060128)),
              border: inputBorder,
              enabledBorder: inputBorder,
              focusedBorder: inputBorder.copyWith(borderSide: BorderSide(color: Colors.black87, width: 2)),
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            validator: (value) {
              if (value == null || value.isEmpty) return 'Ingrese un monto';
              final parsed = double.tryParse(value);
              if (parsed == null || parsed <= 0) return 'Monto inválido';
              return null;
            },
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: isLoading ? null : _depositar,
              child: isLoading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
                    )
                  : const Text('Depositar', style: TextStyle(color:Colors.white, fontSize:  18, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: buttonColor,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 6,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMensaje() {
    if (mensaje == null) return const SizedBox.shrink();

    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        child: AnimatedOpacity(
          opacity: mensaje != null ? 1 : 0,
          duration: const Duration(milliseconds: 300),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 8,
                  offset: Offset(0, 3),
                )
              ],
            ),
            constraints: const BoxConstraints(minWidth: 200),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isError ? Icons.error_outline : Icons.check_circle_outline,
                  color: isError ? Colors.red.shade700 : Colors.black87,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    mensaje!,
                    style: TextStyle(
                      color: Colors.black87,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        title: Text(
          'Depósito con tarjeta',
          style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: textColor),
        ),
        centerTitle: true,
        iconTheme: IconThemeData(color: textColor),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (hasSavedCard) _buildCardSelection() else _buildForm(),
              ],
            ),
          ),
          if (mensaje != null) _buildMensaje(),
        ],
      ),
    );
  }
}
