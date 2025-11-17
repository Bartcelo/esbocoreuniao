import 'package:esbocoreuniao/discurso_model.dart';
import 'package:esbocoreuniao/discurso_repository.dart';
import 'package:flutter/material.dart';

class Editardiscurso extends StatefulWidget {
  const Editardiscurso({super.key});

  @override
  State<Editardiscurso> createState() => _EditardiscursoState();
}

class _EditardiscursoState extends State<Editardiscurso> {
  final TextEditingController _titulo = TextEditingController();
  final TextEditingController _discurso = TextEditingController();
  bool _dadosCarregados = false; // ✅ Mude para var, não final

  final DiscursoRepository _repository = DiscursoRepository();
  Discurso? _discursoed;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_dadosCarregados) {
      final arguments = ModalRoute.of(context)?.settings.arguments;
      if (arguments != null && arguments is Discurso) {
        final discurso = arguments;
        _titulo.text = discurso.titulo;
        _discurso.text = discurso.descricao;
        _discursoed = discurso;
        _dadosCarregados = true; // ✅ Marca como carregado
      } else {
        // ✅ CORREÇÃO: Atribuição correta
        _discursoed = Discurso(
          titulo: "titulo",
          descricao: "descricao",
          dataCriacao: DateTime.now().toString(),
        );
        _dadosCarregados = true;
      }
    }
  }

  Future<void> _updatadiscurso() async {
    if (_discursoed == null) return;

    final discursoAtualizado = Discurso(
      id: _discursoed!.id,
      titulo: _titulo.text,
      descricao: _discurso.text,
      dataCriacao: DateTime.now().toString(),
    );

    await _repository.updateDiscurso(discursoAtualizado);
  }

  Future<void> _salvarEdicao() async {
    if (_titulo.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro: O título é obrigatório!'),
          backgroundColor: Colors.red,
        ),
      );
      return; // ✅ Para a execução se tiver erro
    }

    try {
      await _updatadiscurso(); // ✅ Aguarda a atualização

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Discurso editado com sucesso'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context, true); // ✅ Volta com sucesso
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao editar: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text("Editar Discurso"),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: TextFormField(
                controller: _titulo,
                maxLines: null,
                minLines: 2,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  hintText: "Digite o Título", // ✅ Use hintText
                  filled: true,
                  fillColor: Colors.grey[200],
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: SingleChildScrollView(
                  child: TextFormField(
                    controller: _discurso,
                    maxLines: null,
                    minLines: 3,
                    decoration: InputDecoration(
                      hintText: 'Escreva aqui...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      filled: true,
                      fillColor: const Color.fromARGB(255, 219, 218, 218),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _salvarEdicao, // ✅ Chama a função corrigida
        child: Icon(Icons.save), // ✅ Mude para "save"
      ),
    );
  }
}
