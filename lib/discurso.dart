import 'dart:async';
import 'package:esbocoreuniao/discurso_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';

class Discursos extends StatefulWidget {
  const Discursos({super.key});

  @override
  State<Discursos> createState() => _DiscursosState();
}

class _DiscursosState extends State<Discursos> {
  final QuillController _controller = QuillController.basic();
  Timer? _timer;
  int _tempoRestante = 0;
  bool _timerRodando = false;

  final bool _dadosCarregados = false;
  final TextEditingController _discurso = TextEditingController();

  void tempodisc(int tempoInicial) {
    _timer?.cancel();

    setState(() {
      _tempoRestante = tempoInicial;
      _timerRodando = true;
    });

    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (_tempoRestante > 0) {
          _tempoRestante--;
        } else {
          _timerRodando = false;
          timer.cancel();
        }
      });
    });
  }

  String formatarTempo(int segundos) {
    int minutos = segundos ~/ 60;
    int segundosRestantes = segundos % 60;
    return '${minutos.toString().padLeft(2, '0')}:${segundosRestantes.toString().padLeft(2, '0')}';
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_dadosCarregados) {
      final arguments = ModalRoute.of(context)?.settings.arguments;
      if (arguments != null) {
        final discurso = arguments as Discurso;
        _discurso.text = discurso.descricao;
      }
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _iniciarContador(int minutos) {
    _timer?.cancel();

    setState(() {
      _tempoRestante = minutos * 60;
      _timerRodando = true;
    });

    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (_tempoRestante > 0) {
          _tempoRestante--;
        } else {
          _timerRodando = false;
          timer.cancel();
          _mostrarAlertaFimTempo();
        }
      });
    });
  }

  void _mostrarAlertaFimTempo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Tempo Esgotado!'),
        content: Text('O contador regressivo chegou ao fim.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }



  

  String _formatarTempo(int segundos) {
    int minutos = segundos ~/ 60;
    int segundosRestantes = segundos % 60;
    return '${minutos.toString().padLeft(2, '0')}:${segundosRestantes.toString().padLeft(2, '0')}';
  }

  double _fonteTextform = 20;
  bool year2023 = true;

  void _pararContador() {
    _timer?.cancel();
    setState(() {
      _tempoRestante = 0;
      _timerRodando = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 150,
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: _timerRodando ? Colors.blue[50] : Colors.grey[100],
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: _timerRodando ? Colors.blue : Colors.grey,
                    width: 4,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _formatarTempo(_tempoRestante),
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: _timerRodando ? Colors.blue : Colors.grey,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      _timerRodando ? 'CONTANDO...' : 'PARADO',
                      style: TextStyle(
                        fontSize: 12,
                        color: _timerRodando ? Colors.blue : Colors.grey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 40),

              if (_timerRodando) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: _pararContador,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                      child: Text('PARAR'),
                    ),
                  ],
                ),
              ],
              SizedBox(width: 20),
              SizedBox(
                width: 200,
                child: TextField(
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Minutos personalizados',
                    border: OutlineInputBorder(),
                    suffixText: 'min',
                  ),
                  onSubmitted: (value) {
                    final minutos = int.tryParse(value);
                    if (minutos != null && minutos > 0 && !_timerRodando) {
                      _iniciarContador(minutos);
                    }
                  },
                ),
              ),
              SizedBox(width: 20),
            ],
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        //mainAxisSize: MainAxisSize.max,
                        children: [
                          Text('Fonte A - a'),
                          Slider(
                            value: _fonteTextform,
                            max: 50,
                            min: 20,
                            onChanged: (double value) {
                              setState(() {
                                _fonteTextform = value;
                              });
                            },
                          ),
                        ],
                      ),
                      TextFormField(
                        style: TextStyle(fontSize: _fonteTextform),
                        readOnly: true,
                        controller: _discurso,
                        maxLines: null,
                        minLines: 3,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            // borderRadius: BorderRadius.circular(8),
                          ),
                          // filled: true,
                          // fillColor: const Color.fromARGB(255, 219, 218, 218),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
