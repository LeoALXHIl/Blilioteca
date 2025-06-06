import 'package:sapetshop/database/db_helper.dart';
import 'package:sapetshop/models/livro_model.dart';
import 'package:sapetshop/models/emprestimo_model.dart';

class LivrosController {
  final BibliotecaDBHelper _dbHelper = BibliotecaDBHelper();

  Future<int> inserirLivro(Livro livro) async {
    return await _dbHelper.inserirLivro(livro);
  }

  Future<List<Livro>> listarLivros() async {
    return await _dbHelper.listarLivros();
  }

  Future<Livro?> buscarLivroPorId(int id) async {
    return await _dbHelper.buscarLivroPorId(id);
  }

  Future<int> atualizarLivro(Livro livro) async {
    return await _dbHelper.atualizarLivro(livro);
  }

  Future<int> removerLivro(int id) async {
    return await _dbHelper.removerLivro(id);
  }

  Future<int> registrarEmprestimo(Emprestimo emprestimo) async {
    return await _dbHelper.registrarEmprestimo(emprestimo);
  }

  Future<int> registrarDevolucao(int emprestimoId) async {
    return await _dbHelper.registrarDevolucao(emprestimoId);
  }

  Future<List<Emprestimo>> historicoEmprestimos(int livroId) async {
    return await _dbHelper.historicoEmprestimos(livroId);
  }
}
