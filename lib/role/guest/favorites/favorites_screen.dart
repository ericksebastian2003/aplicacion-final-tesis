import 'package:flutter/material.dart';

class FavoritesScreen extends StatefulWidget{
  const FavoritesScreen({
    super.key,

  });
  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen>{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favoritos'),
      ),
      body: const Padding(
        padding: const EdgeInsets.all(12),
        child: Text('Carta'),
        //CardFavorites,
        
      ),
    );
  }
}
