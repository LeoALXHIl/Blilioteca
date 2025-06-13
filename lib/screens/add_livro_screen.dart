//formulario para adiconar novo livro

import 'package:flutter/material.dart';
import 'package:sapetshop/controllers/livros_controller.dart';
import 'package:sapetshop/models/livro_model.dart';
import 'package:sapetshop/screens/home_screen.dart';
import 'package:sapetshop/screens/add_categoria_screen.dart';
import 'package:sapetshop/database/db_helper.dart';

class AddLivroScreen extends StatefulWidget {
  final Livro? livro;
  AddLivroScreen({Key? key, this.livro}) : super(key: key);
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
  String _categoria = "";
  List<String> _categorias = [];
  bool _carregandoCategorias = true;

  @override
  void initState() {
    super.initState();
    if (widget.livro != null) {
      _titulo = widget.livro!.titulo;
      _autor = widget.livro!.autor;
      _isbn = widget.livro!.isbn;
      _ano = widget.livro!.ano;
      _editora = widget.livro!.editora;
      _genero = widget.livro!.genero;
      _tipo = widget.livro!.tipo;
      _quantidade = widget.livro!.quantidade;
      _capa = widget.livro!.capa;
      _categoria = widget.livro!.categoria;
    }
    _carregarCategorias();
  }

  Future<void> _carregarCategorias() async {
    final db = await BibliotecaDBHelper().database;
    final result = await db.query('categorias');
    if (result.isEmpty) {
      await db.insert('categorias', {'nome': 'Geral'});
      _categorias = ['Geral'];
      setState(() {
        _categoria = 'Geral';
        _carregandoCategorias = false;
      });
    } else {
      setState(() {
        _categorias = result.map((e) => e['nome'] as String).toList();
        if (_categoria.isEmpty && _categorias.isNotEmpty) {
          _categoria = _categorias.first;
        }
        _carregandoCategorias = false;
      });
    }
  }

  Future<void> _adicionarCategoria() async {
    final novaCategoria = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddCategoriaScreen()),
    );
    if (novaCategoria != null && !_categorias.contains(novaCategoria)) {
      setState(() {
        _categorias.add(novaCategoria);
        _categoria = novaCategoria;
      });
    }
  }

  Future<void> _salvarLivro() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final newLivro = Livro(
        id: widget.livro?.id,
        titulo: _titulo,
        autor: _autor,
        isbn: _isbn,
        ano: _ano,
        editora: _editora,
        genero: _genero,
        tipo: _tipo,
        quantidade: _quantidade,
        capa: _capa,
        categoria: _categoria,
      );
      try {
        if (widget.livro != null) {
          await _livrosController.atualizarLivro(newLivro);
        } else {
          await _livrosController.inserirLivro(newLivro);
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Exception: $e")));
      }
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomeScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.livro != null ? "Editar Livro" : "Novo Livro")),
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
              _carregandoCategorias
                  ? Center(child: Padding(padding: EdgeInsets.all(16), child: CircularProgressIndicator()))
                  : Column(
                      children: [
                        DropdownButtonFormField<String>(
                          value: _categoria.isNotEmpty ? _categoria : null,
                          decoration: InputDecoration(labelText: "Categoria"),
                          items: _categorias.map((cat) => DropdownMenuItem(value: cat, child: Text(cat))).toList(),
                          onChanged: (value) => setState(() => _categoria = value ?? ""),
                          validator: (value) => (value == null || value.isEmpty) ? "Selecione uma categoria" : null,
                        ),
                        TextButton.icon(
                          icon: Icon(Icons.add),
                          label: Text("Nova Categoria"),
                          onPressed: _adicionarCategoria,
                        ),
                      ],
                    ),
              ElevatedButton(onPressed: _salvarLivro, child: Text("Salvar"))

            ],
          ),
        ),
      ),
    );
  }
}
