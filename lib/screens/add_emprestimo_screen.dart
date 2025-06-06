import 'package:flutter/material.dart';
import 'package:sapetshop/controllers/livros_controller.dart';
import 'package:sapetshop/models/emprestimo_model.dart';

class AddEmprestimoScreen extends StatefulWidget {
  final int livroId;
  const AddEmprestimoScreen({super.key, required this.livroId});

  @override
  State<AddEmprestimoScreen> createState() => _AddEmprestimoScreenState();
}

class _AddEmprestimoScreenState extends State<AddEmprestimoScreen> {
  final _formKey = GlobalKey<FormState>();
  final LivrosController _controller = LivrosController();

  String _nomeLocatario = "";
  DateTime _dataEmprestimo = DateTime.now();
  DateTime _previsaoDevolucao = DateTime.now().add(Duration(days: 7));

  Future<void> _selecionarDataEmprestimo(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dataEmprestimo,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _dataEmprestimo = picked;
      });
    }
  }

  Future<void> _selecionarPrevisaoDevolucao(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _previsaoDevolucao,
      firstDate: _dataEmprestimo,
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _previsaoDevolucao = picked;
      });
    }
  }

  Future<void> _salvarEmprestimo() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final novoEmprestimo = Emprestimo(
        livroId: widget.livroId,
        nomeLocatario: _nomeLocatario,
        dataEmprestimo: _dataEmprestimo,
        previsaoDevolucao: _previsaoDevolucao,
        dataDevolucao: null,
      );
      try {
        await _controller.registrarEmprestimo(novoEmprestimo);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Empréstimo registrado com sucesso!")),
        );
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erro ao registrar empréstimo: $e")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Registrar Empréstimo")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: "Nome do Locatário"),
                validator: (value) => value!.isEmpty ? "Campo obrigatório" : null,
                onSaved: (value) => _nomeLocatario = value!,
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: Text("Data do Empréstimo: ${_dataEmprestimo.day}/${_dataEmprestimo.month}/${_dataEmprestimo.year}"),
                  ),
                  TextButton(
                    onPressed: () => _selecionarDataEmprestimo(context),
                    child: const Text("Selecionar"),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: Text("Previsão de Devolução: ${_previsaoDevolucao.day}/${_previsaoDevolucao.month}/${_previsaoDevolucao.year}"),
                  ),
                  TextButton(
                    onPressed: () => _selecionarPrevisaoDevolucao(context),
                    child: const Text("Selecionar"),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _salvarEmprestimo,
                child: const Text("Salvar"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
