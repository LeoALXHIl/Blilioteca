import 'package:flutter/material.dart';
import 'package:sapetshop/controllers/livros_controller.dart';

class ListarGeneroScreen extends StatefulWidget {
  @override
  State<ListarGeneroScreen> createState() => _ListarGeneroScreenState();
}

class _ListarGeneroScreenState extends State<ListarGeneroScreen> {
  final LivrosController _livrosController = LivrosController();
  List<String> _generos = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _carregarGeneros();
  }

  Future<void> _carregarGeneros() async {
    final generos = await _livrosController.listarGeneros();
    setState(() {
      _generos = generos;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Gêneros Cadastrados')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _generos.isEmpty
              ? const Center(child: Text('Nenhum gênero cadastrado.'))
              : ListView.builder(
                  itemCount: _generos.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(_generos[index]),
                    );
                  },
                ),
    );
  }
}
