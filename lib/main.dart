import 'package:flutter/material.dart';
import 'package:sapetshop/views/home_screen.dart';
import 'package:sapetshop/screens/listar_categoria_screen.dart';
import 'package:sapetshop/screens/listar_genero_screen.dart';

void main() {
  runApp(MaterialApp(
    home: HomeScreen(),
    routes: {
      '/categorias': (context) => ListarCategoriaScreen(),
      '/generos': (context) => ListarGeneroScreen(),
    },
  ));
}