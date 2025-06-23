import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:desole_app/role/guest/dashboard/guest_dashboard.dart';
import 'package:desole_app/role/guest/pays/pay_accomodation.dart';

class ReserveDestination extends StatefulWidget {
  final String duenio;
  final String alojamientoId;
  final int precioPorNoche;
  final int maxHuespedes;

  const ReserveDestination({
    super.key,
    required this.duenio,
    required this.alojamientoId,
    required this.maxHuespedes,
    required this.precioPorNoche,
  });

  @override
  State<ReserveDestination> createState() => _ReserveDestinationState();
}

class _ReserveDestinationState extends State<ReserveDestination> {
  final _formKey = GlobalKey<FormState>();
  bool _enviando = false;
  int _cantidadHuespedes = 1;
  DateTime? _checkIn;
  DateTime? _checkOut;
  int _cantidadNoches = 1;

  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('es_ES', null);
  }

  Future<bool> _crearReservation() async {
    // Retorna true si la reserva fue creada con éxito, false en caso contrario.
    try {
      setState(() => _enviando = true);

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';
      final huespedId = prefs.getString('userId') ?? '';

      final noches = _cantidadNoches;
      final numHuespedes = _cantidadHuespedes;

      if (numHuespedes > widget.maxHuespedes) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Solo se permiten hasta ${widget.maxHuespedes} huéspedes')),
        );
        return false;
      }

      final precioTotal = widget.precioPorNoche * noches;

      final datos = {
        "huesped": huespedId,
        "alojamiento": widget.alojamientoId,
        "fechaCheckIn": _checkIn!.toIso8601String(),
        "fechaCheckOut": _checkOut!.toIso8601String(),
        "numeroHuespedes": numHuespedes,
        "precioTotal": precioTotal,
      };

      final dio = Dio();
      dio.options.headers['Authorization'] = 'Bearer $token';

      final response = await dio.post(
        'https://hospedajes-4rmu.onrender.com/api/reservas/crear',
        data: datos,
      );

      if (response.statusCode == 201) {
        final reservaData = response.data;
        final idReserva = reservaData['_id'];

        await prefs.setString('reservaId', idReserva);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Reserva creada con éxito. ID: $idReserva')),
        );

        final rol = prefs.getString('rol');
        final nombre = prefs.getString('nombre') ?? '';

        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) => GuestDashboard(rol: rol!, nombre: nombre),
          ),
          (route) => false,
        );

        return true;
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al crear la reserva')),
        );
        return false;
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
      return false;
    } finally {
      setState(() => _enviando = false);
    }
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    setState(() {
      if (_checkIn == null || (_checkIn != null && _checkOut != null)) {
        _checkIn = selectedDay;
        _checkOut = null;
        _cantidadNoches = 1;
      } else if (_checkIn != null && _checkOut == null) {
        if (selectedDay.isAfter(_checkIn!)) {
          _checkOut = selectedDay;
          _cantidadNoches = _checkOut!.difference(_checkIn!).inDays;
        } else {
          _checkIn = selectedDay;
        }
      }
      _focusedDay = focusedDay;
    });
  }

  @override
  Widget build(BuildContext context) {
    final precioTotal = widget.precioPorNoche * _cantidadNoches;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reservar alojamiento',
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              const Text(
                'Selecciona fechas',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              const SizedBox(height: 8),
              TableCalendar(
                locale: 'es_ES',
                firstDay: DateTime.now(),
                lastDay: DateTime.now().add(const Duration(days: 365)),
                focusedDay: _focusedDay,
                calendarFormat: _calendarFormat,
                onFormatChanged: (format) {
                  setState(() {
                    _calendarFormat = format;
                  });
                },
                selectedDayPredicate: (day) =>
                    (day.isAtSameMomentAs(_checkIn ?? DateTime(0)) ||
                        day.isAtSameMomentAs(_checkOut ?? DateTime(0))),
                onDaySelected: _onDaySelected,
                calendarStyle: const CalendarStyle(
                  todayDecoration: BoxDecoration(), // <- Aquí no se marca hoy
                  selectedDecoration: BoxDecoration(
                    color: Colors.black,
                    shape: BoxShape.circle,
                  ),
                  selectedTextStyle: TextStyle(color: Colors.white),
                  weekendTextStyle: TextStyle(color: Colors.grey),
                  defaultTextStyle: TextStyle(color: Colors.black),
                  outsideTextStyle: TextStyle(color: Colors.grey),
                ),
                headerStyle: const HeaderStyle(
                  formatButtonVisible: false,
                  titleCentered: true,
                  titleTextStyle: TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  leftChevronIcon: Icon(
                    Icons.chevron_left,
                    color: Colors.black,
                  ),
                  rightChevronIcon: Icon(
                    Icons.chevron_right,
                    color: Colors.black,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                _checkIn == null
                    ? 'Fecha de ingreso: No seleccionada'
                    : 'Fecha de ingreso: ${_checkIn!.toLocal().toString().split(' ')[0]}',
                style: const TextStyle(fontSize: 16),
              ),
              Text(
                _checkOut == null
                    ? 'Fecha de salida: No seleccionada'
                    : 'Fecha de salida: ${_checkOut!.toLocal().toString().split(' ')[0]}',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 20),
              const Text(
                'Número de huéspedes',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    iconSize: 24,
                    onPressed: _cantidadHuespedes > 1
                        ? () => setState(() => _cantidadHuespedes--)
                        : null,
                    icon: const Icon(Icons.remove_circle_outline),
                    color: Colors.black,
                  ),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black, width: 2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '$_cantidadHuespedes',
                      style: const TextStyle(
                          fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                  ),
                  IconButton(
                    iconSize: 24,
                    onPressed: _cantidadHuespedes < widget.maxHuespedes
                        ? () => setState(() => _cantidadHuespedes++)
                        : null,
                    icon: const Icon(Icons.add_circle_outline),
                    color: Colors.black,
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                'Cantidad de noches: $_cantidadNoches',
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: Colors.black),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Text(
                'Precio total: \$${precioTotal}',
                style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: _enviando
  ? null
  : () async {
      if (_checkIn == null || _checkOut == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Por favor selecciona ambas fechas')),
        );
        return;
      }
      if (_cantidadNoches < 1) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('La cantidad de noches debe ser al menos 1')),
        );
        return;
      }

      final prefs = await SharedPreferences.getInstance();
      final huespedId = prefs.getString('userId') ?? '';

      if (huespedId.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se encontró el usuario, por favor inicia sesión')),
        );
        return;
      }

      // Enviar a pantalla de pago
      final resultadoPago = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => PayAccomodation(
            noches: _cantidadNoches,
            precioPorNoche: widget.precioPorNoche,
            precioTotal: widget.precioPorNoche * _cantidadNoches,
            duenio: widget.duenio,
            alojamientoId: widget.alojamientoId,
            huespedId: huespedId,
            fechaCheckIn: _checkIn!,
            fechaCheckOut: _checkOut!,
            cantidadHuespedes: _cantidadHuespedes,
          ),
        ),
      );

      if (resultadoPago == true) {
        final exito = await _crearReservation();
        if (!exito) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Error al crear la reserva después del pago')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pago cancelado o fallido')),
        );
      }
    },

                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  backgroundColor: Colors.black,
                ),
                child: _enviando
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Siguiente',
                        style: TextStyle(color: Colors.white, fontSize: 18)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
