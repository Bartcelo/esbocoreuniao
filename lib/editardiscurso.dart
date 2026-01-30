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
  bool _dadosCarregados = false;

  final DiscursoRepository _repository = DiscursoRepository();
  Discurso? _discursoed;

  final FocusNode _buttonFocusNode = FocusNode(debugLabel: 'Menu Button');
  String _categoria = 'Outros';

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
        _dadosCarregados = true;
      } else {
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
      categoria: _categoria,
    );

    await _repository.updateDiscurso(discursoAtualizado);
  }

  void _atualizarCategoria(String novaCategoria) {
    setState(() {
      _categoria = novaCategoria;
    });
  }

  Future<void> _salvarEdicao() async {
    if (_titulo.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro: O título é obrigatório!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      await _updatadiscurso();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Discurso editado com sucesso'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context, true);
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
        automaticallyImplyLeading: false,
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text("Editar Discurso"),
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
                controller: _titulo,
                maxLines: null,
                minLines: 2,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  hintText: "Digite o Título",
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
        onPressed: _salvarEdicao,
        child: Icon(Icons.save),
      ),
    );
  }
}
