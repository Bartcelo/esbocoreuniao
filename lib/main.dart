import 'package:esbocoreuniao/contadortimer.dart';
import 'package:esbocoreuniao/criardiscurso.dart';
import 'package:esbocoreuniao/discurso.dart';
import 'package:esbocoreuniao/editardiscurso.dart';
import 'package:esbocoreuniao/homepage.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 19, 30, 54),
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => HomePage(),
        '/discursos': (context) => Discursos(),
        '/criardiscurso': (context) => CriarDiscurso(),
        '/contadortimer': (context) => Contadortimer(),
        '/editardiscurso': (context) => Editardiscurso(),
      },
    );
  }
}
