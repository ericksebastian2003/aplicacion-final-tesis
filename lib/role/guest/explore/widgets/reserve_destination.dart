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

  // Para el calendario:
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('es_ES', null); // Inicializa Intl en español
  }

  Future<void> _crearReservation() async {
    if (!_formKey.currentState!.validate()) return;

    if (_checkIn == null || _checkOut == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, seleccione las fechas de ingreso y salida')),
      );
      return;
    }

    if (_checkOut!.isBefore(_checkIn!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('La fecha de salida debe ser después de la de ingreso')),
      );
      return;
    }

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
        return;
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
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al crear la reserva')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() => _enviando = false);
    }
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    setState(() {
      // Si no hay checkIn, lo asignamos
      if (_checkIn == null || (_checkIn != null && _checkOut != null)) {
        _checkIn = selectedDay;
        _checkOut = null;
        _cantidadNoches = 1;
      } else if (_checkIn != null && _checkOut == null) {
        // Si la fecha seleccionada es después del checkIn, asignamos checkOut
        if (selectedDay.isAfter(_checkIn!)) {
          _checkOut = selectedDay;
          _cantidadNoches = _checkOut!.difference(_checkIn!).inDays;
        } else {
          // Si no, reasignamos checkIn
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
                  // Colores tipo Airbnb blanco y negro
                  todayDecoration: BoxDecoration(
                      color: Colors.black,
                      shape: BoxShape.circle,
                  ),
                  selectedDecoration: BoxDecoration(
                    color: Colors.black,
                    shape: BoxShape.circle,
                  ),
                  selectedTextStyle: TextStyle(color: Colors.white),
                  weekendTextStyle: TextStyle(color: Colors.grey),
                  defaultTextStyle: TextStyle(color: Colors.black),
                  outsideTextStyle: TextStyle(color: Colors.grey),
                ),
                headerStyle: HeaderStyle(
                  formatButtonVisible: false,
                  titleCentered: true,
                  titleTextStyle: const TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  leftChevronIcon: const Icon(
                    Icons.chevron_left,
                    color: Colors.black,
                  ),
                  rightChevronIcon: const Icon(
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
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
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
                            const SnackBar(
                                content:
                                    Text('Por favor selecciona ambas fechas')),
                          );
                          return;
                        }
                        if (_cantidadNoches < 1) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content:
                                    Text('La cantidad de noches debe ser al menos 1')),
                          );
                          return;
                        }

                        await _crearReservation();

                        final prefs = await SharedPreferences.getInstance();
                        final idReserva = prefs.getString('reservaId');

                        if (idReserva == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content:
                                    Text('No se pudo obtener el ID de la reserva')),
                          );
                          return;
                        }

                        final resultadoPago = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => PayAccomodation(
                              alojamiento: widget.alojamientoId,
                              nombreDuenio: widget.duenio,
                              noches: _cantidadNoches,
                              precioPorNoche: widget.precioPorNoche,
                              precioTotal: precioTotal,
                              idReserva: idReserva,
                            ),
                          ),
                        );

                        if (resultadoPago != true) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Pago cancelado o fallido')),
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
