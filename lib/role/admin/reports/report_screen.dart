import 'package:flutter/material.dart';
import '../../../data/models/Reportes.dart';
import 'services/obtener_reportes.dart';
import 'detail_report.dart';
class ReportScreen extends StatefulWidget{
  const ReportScreen({
    super.key
  });
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen>{

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Reportes' , style: TextStyle(
          fontSize: 26,
          fontWeight: FontWeight.bold,
        ),
        ),
      ),
      body: FutureBuilder(
        future: obtenerReportes(), 
        builder: (context,snapshot){
          if(snapshot.hasData){
            final reports = snapshot.data!;
            return Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              child: ListView.builder(
                itemCount: reports.length,
                itemBuilder: (context,index){
                  final report = reports[index];
                  return CardReports(reporte : report);

                },
                
              ),
              );
          
          }
          else if(snapshot.hasError){
            return Center(
              child: Text(
                'Error al cargar los reportes',
              ),
            );
          }
          else{
            return Center(
              child: CircularProgressIndicator(),
            );
          }
        }
        
        ),
    );
  }
}
class CardReports extends StatelessWidget{
  final Reportes reporte;
  const CardReports({
    super.key,
    required this.reporte,

  });
  @override
  Widget build(BuildContext context) {
    
    return InkWell(
      onTap: (){
        Navigator.pushReplacement(context, 
        MaterialPageRoute(builder: (context) => DetailReport(reportes : reporte),
         ),
         );
      },
      child: Card(
        margin: const EdgeInsets.symmetric(
          vertical: 12,
          horizontal: 12,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(reporte.nombre,
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),), 
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(reporte.descripcion,
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),), 
            )
          ],
        ),
      ),
    );
  }
}