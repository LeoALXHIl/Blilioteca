import 'package:intl/intl.dart';

class Emprestimo {
  final int? id;
  final int livroId;
  final String nomeLocatario;
  final DateTime dataEmprestimo;
  final DateTime? dataDevolucao;
  final DateTime previsaoDevolucao;

  Emprestimo({
    this.id,
    required this.livroId,
    required this.nomeLocatario,
    required this.dataEmprestimo,
    this.dataDevolucao,
    required this.previsaoDevolucao,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'livro_id': livroId,
      'nome_locatario': nomeLocatario,
      'data_emprestimo': dataEmprestimo.toIso8601String(),
      'data_devolucao': dataDevolucao?.toIso8601String(),
      'previsao_devolucao': previsaoDevolucao.toIso8601String(),
    };
  }

  factory Emprestimo.fromMap(Map<String, dynamic> map) {
    return Emprestimo(
      id: map['id'] as int?,
      livroId: map['livro_id'] as int,
      nomeLocatario: map['nome_locatario'] as String,
      dataEmprestimo: DateTime.parse(map['data_emprestimo'] as String),
      dataDevolucao: map['data_devolucao'] != null ? DateTime.tryParse(map['data_devolucao']) : null,
      previsaoDevolucao: DateTime.parse(map['previsao_devolucao'] as String),
    );
  }

  String get dataEmprestimoFormatada => DateFormat('dd/MM/yyyy').format(dataEmprestimo);
  String? get dataDevolucaoFormatada => dataDevolucao != null ? DateFormat('dd/MM/yyyy').format(dataDevolucao!) : null;
}
