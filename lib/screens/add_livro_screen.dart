//formulario para adiconar novo livro

import 'package:flutter/material.dart';
import 'package:sapetshop/controllers/livros_controller.dart';
import 'package:sapetshop/models/livro_model.dart';
import 'package:sapetshop/screens/home_screen.dart';

class AddLivroScreen extends StatefulWidget {
  @override
  State<AddLivroScreen> createState() => _AddLivroScreenState();
}

class _AddLivroScreenState extends State<AddLivroScreen> {
  final _formKey = GlobalKey<FormState>(); //chave para o Formulário
  final LivrosController _livrosController = LivrosController();

  String _titulo = "";
  String _autor = "";
  String _isbn = "";
  String _ano = "";
  String _editora = "";
  String _genero = "";
  String _tipo = "Físico";
  int _quantidade = 1;
  String _capa = "";

  Future<void> _salvarLivro() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final newLivro = Livro(
        titulo: _titulo,
        autor: _autor,
        isbn: _isbn,
        ano: _ano,
        editora: _editora,
        genero: _genero,
        tipo: _tipo,
        quantidade: _quantidade,
        capa: _capa,
      );
      //mando para o banco
      try {
        await _livrosController.inserirLivro(newLivro);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Exception: $e")));
      }
      Navigator.push(context, MaterialPageRoute(builder: (context) => HomeScreen())); //Retorna para a Tela Anterior
    }
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(title: Text("Novo Livro"),),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Form(
            key: _formKey,
            child: ListView(
              children: [
                TextFormField(
                  decoration: InputDecoration(labelText: "Título"),
                  validator: (value) => value!.isEmpty ? "Campo obrigatório" : null,
                  onSaved: (value) => _titulo = value!,
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: "Autor"),
                  validator: (value) => value!.isEmpty ? "Campo obrigatório" : null,
                  onSaved: (value) => _autor = value!,
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: "ISBN"),
                  validator: (value) => value!.isEmpty ? "Campo obrigatório" : null,
                  onSaved: (value) => _isbn = value!,
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: "Ano"),
                  validator: (value) => value!.isEmpty ? "Campo obrigatório" : null,
                  onSaved: (value) => _ano = value!,
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: "Editora"),
                  validator: (value) => value!.isEmpty ? "Campo obrigatório" : null,
                  onSaved: (value) => _editora = value!,
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: "Gênero"),
                  validator: (value) => value!.isEmpty ? "Campo obrigatório" : null,
                  onSaved: (value) => _genero = value!,
                ),
                DropdownButtonFormField<String>(
                  value: _tipo,
                  items: ["Físico", "E-book"]
                      .map((tipo) => DropdownMenuItem(value: tipo, child: Text(tipo)))
                      .toList(),
                  onChanged: (value) => setState(() => _tipo = value!),
                  decoration: InputDecoration(labelText: "Tipo"),
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: "Quantidade disponível"),
                  keyboardType: TextInputType.number,
                  validator: (value) => value!.isEmpty ? "Campo obrigatório" : null,
                  onSaved: (value) => _quantidade = int.tryParse(value!) ?? 1,
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: "URL da Capa"),
                  onSaved: (value) => _capa = value ?? "",
                ),
                ElevatedButton(onPressed: _salvarLivro, child: Text("Salvar"))

              ],
            )),
        ),
    );
  }
}
