import 'package:esbocoreuniao/componentes/sobre.dart';
import 'package:esbocoreuniao/database_helper.dart';
import 'package:esbocoreuniao/discurso_model.dart';
import 'package:esbocoreuniao/discurso_repository.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io' show Platform;

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final DiscursoRepository _repository = DiscursoRepository();
  final FocusNode _buttonFocusNode = FocusNode(debugLabel: 'Menu Button');
  final TextEditingController _searchController = TextEditingController();

  final AppInfoService _appInfoService = AppInfoService();

  List<Discurso> _discursos = [];
  bool _carregando = true;

  @override
  void initState() {
    // todo: implement init_state
    super.initState();
    validaplataforma();
  }

  void validaplataforma() {
    if (Platform.isAndroid) {
      _carregarDiscursos();
    } else {}
  }

  Future<void> _carregarDiscursos() async {
    setState(() => _carregando = true);

    List<Discurso> discursos;

    discursos = await _repository.getDiscursos();

    setState(() {
      _discursos = discursos;
      _carregando = false;
    });
  }

  Future<void> _carregarApenasPublicos(String categoria) async {
    setState(() => _carregando = true);

    final discursos = await _repository.getDiscursosPorCategorias([categoria]);

    setState(() {
      _discursos = discursos;
      _carregando = false;
    });
  }

  // ignore: unused_element
  Future<void> _editarDiscurso(Discurso discurso) async {
    discurso.titulo = '${discurso.titulo} [Editado]';
    await _repository.updateDiscurso(discurso);
    _carregarDiscursos();
  }

  Future<void> _excluirDiscurso(int id) async {
    await _repository.deleteDiscurso(id);
    _carregarDiscursos();
  }

  Future<void> _filtrarDiscursos(String query) async {
    final discursos = await _repository.searchDiscursos(query);

    setState(() {
      _discursos = discursos;
      _carregando = false;
    });
  }

  void _showMyAlertDialog(BuildContext context, int id) {
    Widget cancelButton = TextButton(
      child: Text("Não deletar"),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );
    Widget continueButton = TextButton(
      child: Text("Sim deletar"),
      onPressed: () {
        _excluirDiscurso(id);
        Navigator.of(context).pop();
      },
    );

    AlertDialog alert = AlertDialog(
      title: Text("Delete"),
      content: Text("Voce tem certeza que deseja Deletar?"),
      actions: [cancelButton, continueButton],
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  void _fazerbackup() {
    DatabaseHelper dbHelper = DatabaseHelper();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Backup'),
        content: Text('Deseja Fazer ou Restaurar um backUp ?.'),
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // BOTÃO ATUALIZAR (IMPORTAR)
              TextButton(
                onPressed: () async {
                  if (!mounted) return;
                  try {
                    // Abre o seletor de arquivos
                    FilePickerResult? result = await FilePicker.platform
                        .pickFiles(
                          type: FileType.custom,
                          allowedExtensions: ['json'],
                          dialogTitle: 'Selecione o arquivo de backup',
                        );

                    if (result != null) {
                      String filePath = result.files.single.path!;

                      // Mostra informações do backup antes de importar
                      String info = await dbHelper.getBackupInfo(filePath);
                      // if (!context.mounted) return;
                      // Dialog de confirmação
                      bool? confirm = await showDialog(
                        // ignore: use_build_context_synchronously
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text('Confirmar Atualização'),
                          content: Text(
                            '$info\n\nIsso irá SUBSTITUIR todos os dados atuais?',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: Text('Cancelar'),
                            ),
                            ElevatedButton(
                              onPressed: () => Navigator.pop(context, true),
                              style: ElevatedButton.styleFrom(),
                              child: Text('Atualizar'),
                            ),
                          ],
                        ),
                      );

                      if (confirm == true) {
                        // ✅ USA A FUNÇÃO importBackup
                        await dbHelper.importBackup(filePath);
                        // ignore: use_build_context_synchronously
                        Navigator.of(context).pop();
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('✅ Dados atualizados com sucesso!'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        }
                      }
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('❌ Erro ao atualizar: $e'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }

                  await _carregarDiscursos();
                },
                child: Text('Restaurar'),
              ),

              // BOTÃO CRIAR BACKUP (EXPORTAR)
              TextButton(
                onPressed: () async {
                  try {
                    await dbHelper.shareBackup();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('✅ Backup criado e compartilhado!'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('❌ Erro: $e'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                },
                child: Text('Fazer'),
              ),

              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text("Cancelar"),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text('Discursos (${_discursos.length})'),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      width: 2,
                      color: Color(0xFF0a224b),
                      style: BorderStyle.solid,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  width: 200,
                  padding: EdgeInsets.only(right: 16),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Pesquisar...',
                      hintStyle: TextStyle(color: Colors.black),
                      border: InputBorder.none,
                      prefixIcon: Icon(Icons.search, color: Colors.black),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: Icon(Icons.clear, size: 18),
                              onPressed: () => _searchController.clear(),
                            )
                          : null,
                    ),
                    style: TextStyle(color: Colors.white, fontSize: 14),
                    onChanged: (query) {
                      _filtrarDiscursos(query);
                    },
                  ),
                ),
                MenuAnchor(
                  childFocusNode: _buttonFocusNode,
                  menuChildren: <Widget>[
                    MenuItemButton(
                      onPressed: () {
                        _carregarApenasPublicos('Publico');
                      },
                      child: const Text('Discurso Publico'),
                    ),
                    MenuItemButton(
                      onPressed: () {
                        _carregarApenasPublicos('Campo');
                      },
                      child: const Text('Consideração Campo'),
                    ),
                    MenuItemButton(
                      onPressed: () {
                        _carregarApenasPublicos('Outros');
                      },
                      child: const Text('Outros'),
                    ),
                    MenuItemButton(
                      onPressed: () {
                        _carregarDiscursos();
                      },
                      child: const Text('Atualizar'),
                    ),
                    MenuItemButton(
                      onPressed: () async {
                        await _appInfoService.showInfoDialog(context);
                      },
                      child: Row(
                        children: [
                          const Icon(Icons.info),
                          const Text(' Sobre'),
                        ],
                      ),
                    ),
                    MenuItemButton(
                      onPressed: () {
                        _fazerbackup();
                      },
                      child: Row(
                        children: [
                          const Icon(Icons.backup),
                          const Text(' BackUp'),
                        ],
                      ),
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
              ],
            ),
          ),
        ],
      ),
      body: _carregando
          ? Center(child: CircularProgressIndicator())
          : _discursos.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.list, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('Nenhum discurso encontrado'),
                  SizedBox(height: 8),
                  Text('Clique no + para adicionar um novo'),
                ],
              ),
            )
          : ListView.builder(
              itemCount: _discursos.length,
              itemBuilder: (context, index) {
                final discurso = _discursos[index];
                return Card(
                  color: discurso.categoria == 'Publico'
                      ? const Color.fromARGB(255, 15, 54, 121)
                      : discurso.categoria == 'Outros'
                      ? const Color(0xFF4a6da7)
                      : const Color(0xFF25532D),
                  margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                  child: ListTile(
                    title: Text(
                      discurso.titulo,
                      style: TextStyle(color: Colors.white),
                    ),
                    subtitle: Text(
                      discurso.descricao.length > 50
                          ? '${discurso.descricao.substring(0, 50)}...'
                          : discurso.descricao,
                      style: TextStyle(color: Colors.white),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Container(
                            padding: EdgeInsets.all(5.0),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                            ),
                            child: Icon(Icons.edit, color: Colors.blueGrey),
                          ),
                          onPressed: () {
                            Navigator.pushNamed(
                              context,
                              '/editardiscurso',
                              arguments: discurso,
                            ).then((resultado) {
                              if (resultado == true) {
                                _carregarDiscursos();
                              }
                            });
                          },
                        ),
                        IconButton(
                          icon: Container(
                            padding: EdgeInsets.all(5.0),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                            ),
                            child: Icon(
                              Icons.delete,
                              color: const Color.fromARGB(255, 138, 42, 35),
                            ),
                          ),
                          onPressed: () {
                            _showMyAlertDialog(context, discurso.id!);
                          },
                        ),
                      ],
                    ),
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        '/discursos',
                        arguments: discurso,
                      );
                    },
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () =>
            Navigator.pushNamed(context, '/criardiscurso').then((resultado) {
              if (resultado == true) {
                _carregarDiscursos();
              }
            }),
        child: Icon(Icons.add),
      ),
    );
  }
}
