import 'package:flutter/material.dart';
import 'dart:async';

class Contadortimer extends StatefulWidget {
  const Contadortimer({super.key});

  @override
  State<Contadortimer> createState() => _ContadortimerState();
}

class _ContadortimerState extends State<Contadortimer> {
  Timer? _timer;
  int _tempoRestante = 0; // em segundos
  bool _timerRodando = false;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _iniciarContador(int minutos) {
    // Cancela timer anterior se existir
    _timer?.cancel();

    setState(() {
      _tempoRestante = minutos * 60; // Converte minutos para segundos
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

  void _pararContador() {
    _timer?.cancel();
    setState(() {
      _tempoRestante = 0;
      _timerRodando = false;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Contador Regressivo'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Display do Tempo
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

            // Botões de Controle
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
          ],
        ),
      ),
    );
  }
}
