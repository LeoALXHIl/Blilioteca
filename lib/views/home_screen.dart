import 'package:flutter/material.dart';
import 'package:sapetshop/controllers/livros_controller.dart';
import 'package:sapetshop/models/livro_model.dart';
import 'package:sapetshop/views/add_emprestimo_screen.dart';
import 'package:sapetshop/views/add_livro_screen.dart';
import 'package:sapetshop/views/livro_detalhe_screen.dart';
import 'package:sapetshop/screens/add_categoria_screen.dart';
import 'package:sapetshop/screens/listar_categoria_screen.dart';
import 'package:sapetshop/screens/listar_genero_screen.dart';
import 'package:sapetshop/screens/perfil_usuario_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final LivrosController _livrosController = LivrosController();

  List<Livro> _livros = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadLivros();
  }

  Future<void> _loadLivros() async {
    setState(() {
      _isLoading = true;
      _livros = [];
    });
    try {
      _livros = await _livrosController.listarLivros();
    } catch (erro) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Exception: $erro")));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Agrupa os livros por categoria
    Map<String, List<Livro>> livrosPorCategoria = {};
    for (var livro in _livros) {
      livrosPorCategoria.putIfAbsent(livro.categoria, () => []).add(livro);
    }
    return Scaffold(
      appBar: AppBar(title: Text("Biblioteca")),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Theme.of(context).primaryColor),
              child: Text('Menu', style: TextStyle(color: Colors.white, fontSize: 24)),
            ),
            ListTile(
              leading: Icon(Icons.home),
              title: Text('Início'),
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => HomeScreen()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.add),
              title: Text('Novo Livro'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AddLivroScreen()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.category),
              title: Text('Nova Categoria'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AddCategoriaScreen()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.list),
              title: Text('Listar Categorias'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ListarCategoriaScreen()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.bookmark),
              title: Text('Listar Gêneros'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ListarGeneroScreen()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.person),
              title: Text('Perfil'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => PerfilUsuarioScreen()),
                );
              },
            ),
            // Removido: ListTile de Pets
            // Removido: ListTile de Consultas
            // Adicione mais ListTile para outras funções do app
          ],
        ),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView(
              children: livrosPorCategoria.entries.map((entry) {
                final categoria = entry.key;
                final livros = entry.value;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: Text(
                        categoria,
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.deepPurple),
                      ),
                    ),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.62,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 16,
                      ),
                      itemCount: livros.length,
                      itemBuilder: (context, idx) {
                        final livro = livros[idx];
                        return GestureDetector(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => LivroDetalheScreen(livroId: livro.id!),
                            ),
                          ),
                          child: Card(
                            elevation: 4,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Expanded(
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                                    child: livro.capa.isNotEmpty
                                        ? Image.network(
                                            livro.capa,
                                            fit: BoxFit.cover,
                                            errorBuilder: (context, error, stackTrace) =>
                                                const Icon(Icons.broken_image, size: 60, color: Colors.grey),
                                          )
                                        : Container(
                                            color: Colors.grey[200],
                                            child: const Icon(Icons.menu_book, size: 60, color: Colors.grey),
                                          ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        livro.titulo,
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        livro.autor,
                                        style: const TextStyle(fontSize: 14, color: Colors.black54),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                );
              }).toList(),
            ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: 'addCategoria',
            tooltip: "Adicionar Nova Categoria",
            child: Icon(Icons.category),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AddCategoriaScreen()),
              );
              _loadLivros();
            },
          ),
          SizedBox(height: 12),
          FloatingActionButton(
            heroTag: 'addLivro',
            tooltip: "Adicionar Novo Livro",
            onPressed: () async {
              await Navigator.push(
                  context, MaterialPageRoute(builder: (context) => AddLivroScreen()));
              _loadLivros();
            },
            child: Icon(Icons.add),
          ),
        ],
      ),
    );
  }
}