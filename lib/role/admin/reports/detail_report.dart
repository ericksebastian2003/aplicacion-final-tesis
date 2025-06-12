import 'package:desole_app/data/models/Reportes.dart';
import 'package:flutter/material.dart';

class DetailReport extends StatelessWidget{
  final Reportes reportes;
  const DetailReport({
    super.key,
    required this.reportes,
  });
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(reportes.nombre),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              reportes.descripcion
            )
          ],
        ),
      ),
    );
  }
}