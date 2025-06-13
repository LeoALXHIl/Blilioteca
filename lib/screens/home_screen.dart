import 'package:flutter/material.dart';
import 'package:sapetshop/controllers/livros_controller.dart';
import 'package:sapetshop/models/livro_model.dart';
import 'package:sapetshop/screens/add_livro_screen.dart';
import 'package:sapetshop/screens/livro_detalhe_screen.dart';
import 'package:sapetshop/screens/add_emprestimo_screen.dart';

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
    // Agrupa os livros por categoria (gênero)
    Map<String, List<Livro>> livrosPorCategoria = {};
    for (var livro in _livros) {
      livrosPorCategoria.putIfAbsent(livro.genero, () => []).add(livro);
    }
    return Scaffold(
      appBar: AppBar(title: Text("Biblioteca")),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView(
              children: livrosPorCategoria.entries.map((entry) {
                final categoria = entry.key;
                final livros = entry.value;
                return ExpansionTile(
                  title: Text(categoria, style: const TextStyle(fontWeight: FontWeight.bold)),
                  children: livros.map((livro) {
                    return ListTile(
                      title: Text(livro.titulo),
                      subtitle: Text(livro.autor),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            tooltip: "Editar Livro",
                            onPressed: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => AddLivroScreen(
                                    livro: livro,
                                  ),
                                ),
                              );
                              _loadLivros();
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            tooltip: "Deletar Livro",
                            onPressed: () async {
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text("Confirmar Exclusão"),
                                  content: Text("Deseja realmente deletar o livro '${livro.titulo}'?"),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context, false),
                                      child: const Text("Cancelar"),
                                    ),
                                    TextButton(
                                      onPressed: () => Navigator.pop(context, true),
                                      child: const Text("Deletar", style: TextStyle(color: Colors.red)),
                                    ),
                                  ],
                                ),
                              );
                              if (confirm == true) {
                                await _livrosController.removerLivro(livro.id!);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text("Livro deletado com sucesso!")),
                                );
                                _loadLivros();
                              }
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.menu_book),
                            tooltip: "Ações do Livro",
                            onPressed: () async {
                              final controller = LivrosController();
                              final historico = await controller.historicoEmprestimos(livro.id!);
                              showModalBottomSheet(
                                context: context,
                                isScrollControlled: true,
                                builder: (context) => Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: SingleChildScrollView(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        if (livro.capa.isNotEmpty)
                                          Image.network(
                                            livro.capa,
                                            height: 180,
                                            fit: BoxFit.cover,
                                            errorBuilder: (context, error, stackTrace) =>
                                                const Icon(Icons.broken_image, size: 100),
                                            loadingBuilder: (context, child, progress) =>
                                                progress == null ? child : const CircularProgressIndicator(),
                                          ),
                                        Text("Título: "+livro.titulo, style: const TextStyle(fontSize: 20)),
                                        Text("Autor: "+livro.autor),
                                        Text("ISBN: "+livro.isbn),
                                        Text("Ano: "+livro.ano),
                                        Text("Editora: "+livro.editora),
                                        Text("Gênero: "+livro.genero),
                                        Text("Tipo: "+livro.tipo),
                                        Text("Quantidade disponível: "+livro.quantidade.toString()),
                                        const Divider(),
                                        if (livro.tipo == "Físico") ...[
                                          const Text("Histórico de Empréstimos/Devoluções:",
                                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                          historico.isEmpty
                                              ? const Center(child: Text("Nenhum empréstimo registrado para este livro."))
                                              : ListView.builder(
                                                  shrinkWrap: true,
                                                  physics: NeverScrollableScrollPhysics(),
                                                  itemCount: historico.length,
                                                  itemBuilder: (context, idx) {
                                                    final emp = historico[idx];
                                                    final isPendente = emp.dataDevolucao == null;
                                                    return Card(
                                                      margin: const EdgeInsets.symmetric(vertical: 4),
                                                      child: ListTile(
                                                        title: Text("Locatário: "+emp.nomeLocatario),
                                                        subtitle: Text(
                                                            "Empréstimo: "+emp.dataEmprestimoFormatada+"\n"
                                                            "Previsão: "+emp.previsaoDevolucao.day.toString()+"/"+emp.previsaoDevolucao.month.toString()+"/"+emp.previsaoDevolucao.year.toString()+"\n"
                                                            "Devolução: "+(emp.dataDevolucaoFormatada ?? 'Pendente')),
                                                        trailing: Row(
                                                          mainAxisSize: MainAxisSize.min,
                                                          children: [
                                                            if (isPendente)
                                                              IconButton(
                                                                tooltip: "Registrar Devolução",
                                                                onPressed: () async {
                                                                  await controller.registrarDevolucao(emp.id!);
                                                                  Navigator.pop(context);
                                                                  setState(() {});
                                                                },
                                                                icon: const Icon(Icons.assignment_turned_in, color: Colors.green),
                                                              ),
                                                            Icon(
                                                              isPendente ? Icons.hourglass_empty : Icons.check_circle,
                                                              color: isPendente ? Colors.orange : Colors.blue,
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                ),
                                          const SizedBox(height: 10),
                                          ElevatedButton.icon(
                                            icon: const Icon(Icons.add),
                                            label: const Text("Registrar Empréstimo"),
                                            onPressed: () async {
                                              Navigator.pop(context);
                                              await Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) => AddEmprestimoScreen(livroId: livro.id!),
                                                ),
                                              );
                                              setState(() {});
                                            },
                                          ),
                                        ],
                                        const SizedBox(height: 10),
                                        TextButton(
                                          onPressed: () => Navigator.pop(context),
                                          child: const Text("Fechar"),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => LivroDetalheScreen(livroId: livro.id!),
                        ),
                      ),
                    );
                  }).toList(),
                );
              }).toList(),
            ),
      floatingActionButton: FloatingActionButton(
        tooltip: "Adicionar Novo Livro",
        onPressed: () async {
          await Navigator.push(
              context, MaterialPageRoute(builder: (context) => AddLivroScreen()));
          _loadLivros();
        },
        child: Icon(Icons.add),
      ),
    );
  }
}