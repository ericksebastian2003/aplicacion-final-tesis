import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../../data/models/Reportes.dart';
Future<List<Reportes>> obtenerReportes() async{
  List<Reportes> reportesGenerados = [];
  
  try{
    for(int id = 1 ; id <= 20 ; id++){
    final String url = 'https://rickandmortyapi.com/api/character/$id';
    final response = await http.get(Uri.parse(url));
    if(response.statusCode == 200){
      final data = json.decode(response.body);
     reportesGenerados.add(Reportes.fromJson(data));
      
    }
    else{
      throw Exception('Error , al cargar el reporte $id');
    }
    }
    return reportesGenerados;
  }
  catch(e){
       throw Exception ('Error de conexión : $e');
  }

}