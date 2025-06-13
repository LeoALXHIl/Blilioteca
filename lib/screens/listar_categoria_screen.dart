import 'package:flutter/material.dart';
import 'package:sapetshop/database/db_helper.dart';

class ListarCategoriaScreen extends StatefulWidget {
  @override
  State<ListarCategoriaScreen> createState() => _ListarCategoriaScreenState();
}

class _ListarCategoriaScreenState extends State<ListarCategoriaScreen> {
  List<String> _categorias = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _carregarCategorias();
  }

  Future<void> _carregarCategorias() async {
    final db = await BibliotecaDBHelper().database;
    final result = await db.query('categorias');
    setState(() {
      _categorias = result.map((e) => e['nome'] as String).toList();
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Categorias Cadastradas')),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _categorias.isEmpty
              ? Center(child: Text('Nenhuma categoria cadastrada.'))
              : ListView.builder(
                  itemCount: _categorias.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(_categorias[index]),
                    );
                  },
                ),
    );
  }
}
