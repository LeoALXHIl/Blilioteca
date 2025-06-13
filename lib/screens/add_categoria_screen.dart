import 'package:flutter/material.dart';
import 'package:sapetshop/database/db_helper.dart';

class Categoria {
  final int? id;
  final String nome;
  Categoria({this.id, required this.nome});
}

class AddCategoriaScreen extends StatefulWidget {
  @override
  State<AddCategoriaScreen> createState() => _AddCategoriaScreenState();
}

class _AddCategoriaScreenState extends State<AddCategoriaScreen> {
  final _formKey = GlobalKey<FormState>();
  String _nome = "";

  Future<void> _salvarCategoria() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final db = await BibliotecaDBHelper().database;
      await db.insert('categorias', {'nome': _nome});
      Navigator.pop(context, _nome);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Nova Categoria")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: "Nome da Categoria"),
                validator: (value) => value!.isEmpty ? "Campo obrigatório" : null,
                onSaved: (value) => _nome = value!,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _salvarCategoria,
                child: Text("Salvar"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
