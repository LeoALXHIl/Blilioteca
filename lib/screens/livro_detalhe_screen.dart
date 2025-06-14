import 'package:flutter/material.dart';
import 'package:sapetshop/controllers/livros_controller.dart';
import 'package:sapetshop/models/livro_model.dart';
import 'package:sapetshop/models/emprestimo_model.dart';
import 'package:sapetshop/screens/add_emprestimo_screen.dart';
import 'package:sapetshop/screens/add_livro_screen.dart';

class LivroDetalheScreen extends StatefulWidget {
  final int livroId;

  const LivroDetalheScreen({super.key, required this.livroId});

  @override
  State<StatefulWidget> createState() => _LivroDetalheScreenState();
}

class _LivroDetalheScreenState extends State<LivroDetalheScreen> {
  final LivrosController _controllerLivros = LivrosController();
  bool _isLoading = true;

  Livro? _livro;
  List<Emprestimo> _emprestimos = [];

  @override
  void initState() {
    super.initState();
    _loadLivroEmprestimos();
  }

  Future<void> _loadLivroEmprestimos() async {
    setState(() {
      _isLoading = true;
    });
    try {
      _livro = await _controllerLivros.buscarLivroPorId(widget.livroId);
      if (_livro != null && _livro!.tipo == "Físico") {
        _emprestimos = await _controllerLivros.historicoEmprestimos(widget.livroId);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Exception $e")));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _registrarDevolucao(int emprestimoId) async {
    try {
      await _controllerLivros.registrarDevolucao(emprestimoId);
      await _loadLivroEmprestimos();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Devolução registrada")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erro ao registrar devolução: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Detalhes do Livro"),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _livro == null
              ? const Center(child: Text("Erro ao carregar o Livro. Verifique o ID."))
              : Padding(
                  padding: const EdgeInsets.all(16),
                  child: ListView(
                    children: [
                      if (_livro!.capa.isNotEmpty)
                        Stack(
                          children: [
                            Image.network(
                              _livro!.capa,
                              height: 180,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image, size: 100),
                              loadingBuilder: (context, child, progress) =>
                                progress == null ? child : const CircularProgressIndicator(),
                            ),
                            Positioned(
                              top: 8,
                              right: 8,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit, color: Colors.blue, size: 28),
                                    tooltip: 'Editar Livro',
                                    onPressed: () async {
                                      await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => AddLivroScreen(livro: _livro!),
                                        ),
                                      );
                                      await _loadLivroEmprestimos();
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete, color: Colors.red, size: 28),
                                    tooltip: 'Excluir Livro',
                                    onPressed: () async {
                                      final confirm = await showDialog<bool>(
                                        context: context,
                                        builder: (context) => AlertDialog(
                                          title: const Text('Confirmar Exclusão'),
                                          content: Text("Deseja realmente excluir o livro '${_livro!.titulo}'?"),
                                          actions: [
                                            TextButton(
                                              onPressed: () => Navigator.pop(context, false),
                                              child: const Text('Cancelar'),
                                            ),
                                            TextButton(
                                              onPressed: () => Navigator.pop(context, true),
                                              child: const Text('Excluir', style: TextStyle(color: Colors.red)),
                                            ),
                                          ],
                                        ),
                                      );
                                      if (confirm == true) {
                                        await _controllerLivros.removerLivro(_livro!.id!);
                                        if (mounted) {
                                          Navigator.pop(context);
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(content: Text('Livro excluído com sucesso!')),
                                          );
                                        }
                                      }
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      Text("Título: ${_livro!.titulo}", style: const TextStyle(fontSize: 20)),
                      Text("Autor: ${_livro!.autor}"),
                      Text("ISBN: ${_livro!.isbn}"),
                      Text("Ano: ${_livro!.ano}"),
                      Text("Editora: ${_livro!.editora}"),
                      Text("Gênero: ${_livro!.genero}"),
                      Text("Tipo: \\${_livro!.tipo}"),
                      Text("Quantidade disponível: \\${_livro!.quantidade}"),
                      const SizedBox(height: 16),
                      const Divider(),
                      if (_livro!.tipo == "Físico") ...[
                        const Text("Histórico de Empréstimos/Devoluções:",
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        _emprestimos.isEmpty
                            ? const Center(child: Text("Nenhum empréstimo registrado para este livro."))
                            : ListView.builder(
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                itemCount: _emprestimos.length,
                                itemBuilder: (context, index) {
                                  final emp = _emprestimos[index];
                                  return Card(
                                    margin: const EdgeInsets.symmetric(vertical: 4),
                                    child: ListTile(
                                      title: Text("Locatário: \\${emp.nomeLocatario}"),
                                      subtitle: Text(
                                        "Empréstimo: \\${emp.dataEmprestimoFormatada}\\n"
                                        "Previsão: \\${emp.previsaoDevolucao.day}/\\${emp.previsaoDevolucao.month}/\\${emp.previsaoDevolucao.year}\\n"
                                        "Devolução: \\${emp.dataDevolucaoFormatada ?? 'Pendente'}"
                                      ),
                                      trailing: emp.dataDevolucao == null
                                          ? IconButton(
                                              onPressed: () => _registrarDevolucao(emp.id!),
                                              icon: const Icon(Icons.assignment_turned_in, color: Colors.green),
                                            )
                                          : null,
                                    ),
                                  );
                                },
                              ),
                      ],
                    ],
                  ),
                ),
      floatingActionButton: _livro != null && _livro!.tipo == "Físico"
          ? FloatingActionButton(
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddEmprestimoScreen(livroId: widget.livroId),
                  ),
                );
                _loadLivroEmprestimos();
              },
              child: const Icon(Icons.add),
              tooltip: "Registrar Empréstimo",
            )
          : null,
    );
  }
}