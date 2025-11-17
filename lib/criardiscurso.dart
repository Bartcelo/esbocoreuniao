import 'package:esbocoreuniao/discurso_model.dart';
import 'package:esbocoreuniao/discurso_repository.dart';
import 'package:flutter/material.dart';

class CriarDiscurso extends StatefulWidget {
  const CriarDiscurso({super.key});

  @override
  State<CriarDiscurso> createState() => _CriarDiscursoState();
}

class _CriarDiscursoState extends State<CriarDiscurso> {
  final TextEditingController _titulo = TextEditingController();
  final TextEditingController _discurso = TextEditingController();

  final DiscursoRepository _repository = DiscursoRepository();
  String _categoria = 'Outros';

  final FocusNode _buttonFocusNode = FocusNode(debugLabel: 'Menu Button');

  Future<void> _adicionarDiscurso(String titulo, String descricao) async {
    final novoDiscurso = Discurso(
      titulo: titulo,
      descricao: descricao,
      dataCriacao: DateTime.now().toString(),
      categoria: _categoria,
    );

    await _repository.insertDiscurso(novoDiscurso);
  }

  void _atualizarCategoria(String novaCategoria) {
    setState(() {
      _categoria = novaCategoria;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text("Criar Discurso"),
        actions: [
          Text(_categoria),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: MenuAnchor(
              childFocusNode: _buttonFocusNode,
              menuChildren: <Widget>[
                MenuItemButton(
                  onPressed: () {
                    _atualizarCategoria('Publico');
                  },
                  child: const Text('Discurso Publico'),
                ),
                MenuItemButton(
                  onPressed: () {
                    _atualizarCategoria('Campo');
                  },
                  child: const Text('Consideração Campo'),
                ),
                MenuItemButton(
                  onPressed: () {
                    _atualizarCategoria('Outros');
                  },
                  child: const Text('Outros'),
                ),
              ],
              builder: (_, MenuController controller, Widget? child) {
                return IconButton(
                  focusNode: _buttonFocusNode,
                  onPressed: () {
                    if (controller.isOpen) {
                      controller.close();
                    } else {
                      controller.open();
                    }
                  },
                  icon: const Icon(Icons.more_vert),
                );
              },
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: TextFormField(
                style: TextStyle(color: Colors.white),
                controller: _titulo,
                maxLines: null,
                minLines: 2,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  hint: Center(
                    child: Text(
                      "Digite o Titulo",
                      style: TextStyle(color: Colors.white, fontSize: 25),
                    ),
                  ),
                  filled: true,
                  fillColor: const Color(0xFF4a6da7),
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
                      hintText: 'Digite o discurso aqui...',
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
        onPressed: () {
          if (_titulo.text.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Erro: O título é obrigatório!'),
                backgroundColor: Colors.red,
              ),
            );
          }

          _adicionarDiscurso(_titulo.text, _discurso.text);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Discurso criado com sucesso'),
              backgroundColor: Colors.green,
            ),
          );

          Navigator.pop(context, true);
        },
        child: Icon(Icons.save),
      ),
    );
  }
}
