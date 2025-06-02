import 'package:flutter/material.dart';

class ReservesScreen  extends StatefulWidget{
  const ReservesScreen({
    super.key,
  });
  @override
  State<ReservesScreen> createState() => _ReservesScreenState();

}
class _ReservesScreenState extends State<ReservesScreen>{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:AppBar(
        title: Text(
          'Reservas',
          textAlign: TextAlign.right,
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
      ) ,
  );
  }}