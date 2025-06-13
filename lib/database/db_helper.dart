import 'dart:io';
import 'package:path/path.dart';
import 'package:sapetshop/models/livro_model.dart';
import 'package:sapetshop/models/emprestimo_model.dart';
import 'package:sqflite/sqflite.dart';

class BibliotecaDBHelper {
  static Database? _database;
  static final BibliotecaDBHelper _instance = BibliotecaDBHelper._internal();
  BibliotecaDBHelper._internal();
  factory BibliotecaDBHelper() {
    return _instance;
  }

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final _dbPath = await getDatabasesPath();
    final path = join(_dbPath, "biblioteca_v2.db"); // nome alterado para forçar nova criação
    return await openDatabase(path, version: 2, onCreate: _onCreateDB, onUpgrade: _onUpgradeDB);
  }

  Future<void> _onCreateDB(Database db, int version) async {
    // Tabela de categorias
    await db.execute('''
      CREATE TABLE IF NOT EXISTS categorias(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nome TEXT NOT NULL UNIQUE
      )
    ''');
    // Tabela de livros
    await db.execute('''
      CREATE TABLE IF NOT EXISTS livros(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        titulo TEXT NOT NULL,
        autor TEXT NOT NULL,
        isbn TEXT NOT NULL,
        ano TEXT NOT NULL,
        editora TEXT NOT NULL,
        genero TEXT NOT NULL,
        tipo TEXT NOT NULL,
        quantidade INTEGER NOT NULL,
        capa TEXT,
        categoria TEXT NOT NULL
      )
    ''');
    // Tabela de empréstimos
    await db.execute('''
      CREATE TABLE IF NOT EXISTS emprestimos(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        livro_id INTEGER NOT NULL,
        nome_locatario TEXT NOT NULL,
        data_emprestimo TEXT NOT NULL,
        previsao_devolucao TEXT NOT NULL,
        data_devolucao TEXT,
        FOREIGN KEY (livro_id) REFERENCES livros(id) ON DELETE CASCADE
      )
    ''');
  }

  Future<void> _onUpgradeDB(Database db, int oldVersion, int newVersion) async {
    // Adicione upgrades de schema se necessário
  }

  // CRUD para livros
  Future<int> inserirLivro(Livro livro) async {
    final db = await database;
    return await db.insert("livros", livro.toMap());
  }

  Future<List<Livro>> listarLivros() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query("livros");
    return maps.map((e) => Livro.fromMap(e)).toList();
  }

  Future<Livro?> buscarLivroPorId(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query("livros", where: "id = ?", whereArgs: [id]);
    if (maps.isNotEmpty) {
      return Livro.fromMap(maps.first);
    } else {
      return null;
    }
  }

  Future<int> atualizarLivro(Livro livro) async {
    final db = await database;
    return await db.update("livros", livro.toMap(), where: "id = ?", whereArgs: [livro.id]);
  }

  Future<int> removerLivro(int id) async {
    final db = await database;
    return await db.delete("livros", where: "id = ?", whereArgs: [id]);
  }

  // CRUD para empréstimos
  Future<int> registrarEmprestimo(Emprestimo emprestimo) async {
    final db = await database;
    return await db.insert("emprestimos", emprestimo.toMap());
  }

  Future<int> registrarDevolucao(int emprestimoId) async {
    final db = await database;
    final now = DateTime.now().toIso8601String();
    return await db.update(
      "emprestimos",
      {"data_devolucao": now},
      where: "id = ?",
      whereArgs: [emprestimoId],
    );
  }

  Future<List<Emprestimo>> historicoEmprestimos(int livroId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      "emprestimos",
      where: "livro_id = ?",
      whereArgs: [livroId],
      orderBy: "data_emprestimo DESC"
    );
    return maps.map((e) => Emprestimo.fromMap(e)).toList();
  }
}