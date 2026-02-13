// ignore_for_file: deprecated_member_use

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'meu_app.db');
    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE discursos(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        titulo TEXT NOT NULL,
        descricao TEXT,
        data_criacao TEXT NOT NULL,
        categoria TEXT DEFAULT 'Outros'
      )
    ''');

    await db.execute('''
      CREATE TABLE categorias(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nome TEXT NOT NULL
      )
    ''');
  }

  // ============ FUNÇÕES DE BACKUP ============

  /// EXPORTA TODOS OS DADOS DO BANCO PARA JSON
  Future<Map<String, dynamic>> exportDatabase() async {
    final db = await database;

    try {
      List<Map<String, dynamic>> discursos = await db.query('discursos');
      List<Map<String, dynamic>> categorias = await db.query('categorias');

      return {
        'metadata': {
          'version': '1.0',
          'exportDate': DateTime.now().toIso8601String(),
          'appName': 'MeuApp',
          'tables': ['discursos', 'categorias'],
          'totalRegistros': discursos.length + categorias.length,
        },
        'data': {'discursos': discursos, 'categorias': categorias},
      };
    } catch (e) {
      throw Exception('Erro ao exportar dados: $e');
    }
  }

  /// CRIA ARQUIVO FÍSICO DE BACKUP
  Future<File> createBackupFile() async {
    try {
      Map<String, dynamic> backupData = await exportDatabase();
      String jsonString = jsonEncode(backupData);

      Directory docsDir = await getApplicationDocumentsDirectory();
      String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      String fileName = 'esbocoReuniao$timestamp.json';
      File backupFile = File('${docsDir.path}/$fileName');

      return await backupFile.writeAsString(jsonString);
    } catch (e) {
      throw Exception('Erro ao criar arquivo de backup: $e');
    }
  }

  /// COMPARTILHA O BACKUP VIA WHATSAPP/TELEGRAM/OUTROS
  Future<void> shareBackup() async {
    try {
      File backupFile = await createBackupFile();

      // CORREÇÃO: Usando SharePlus com XFile
      await Share.shareXFiles(
        [XFile(backupFile.path)],
        // text:
        //     '📁 Backup do MeuApp - ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
      );
    } catch (e) {
      throw Exception('Erro ao compartilhar backup: $e');
    }
  }

  /// COMPARTILHA DIRETAMENTE PARA WHATSAPP
  Future<void> shareToWhatsApp() async {
    try {
      File backupFile = await createBackupFile();

      // CORREÇÃO: SharePlus para WhatsApp
      await Share.shareXFiles(
        [XFile(backupFile.path)],
        text: '📁 Backup do MeuApp',
        subject: 'Backup Discursos',
      );
    } catch (e) {
      throw Exception('Erro ao enviar para WhatsApp: $e');
    }
  }

  // ============ FUNÇÕES DE RESTORE ============

  /// VALIDA SE O ARQUIVO DE BACKUP É VÁLIDO
  bool validateBackup(Map<String, dynamic> backupData) {
    try {
      if (!backupData.containsKey('metadata')) return false;
      if (!backupData.containsKey('data')) return false;

      Map<String, dynamic> data = backupData['data'];
      if (!data.containsKey('discursos')) return false;
      if (!data.containsKey('categorias')) return false;

      if (backupData['metadata']['version'] != '1.0') return false;

      return true;
    } catch (e) {
      return false;
    }
  }

  /// IMPORTA DADOS DE UM ARQUIVO DE BACKUP (SUBSTITUI)
  Future<void> importBackup(String filePath) async {
    final db = await database;

    try {
      File file = File(filePath);
      String jsonString = await file.readAsString();
      Map<String, dynamic> backupData = jsonDecode(jsonString);

      if (!validateBackup(backupData)) {
        throw Exception('Arquivo de backup inválido ou corrompido');
      }

      Map<String, dynamic> data = backupData['data'];

      await db.transaction((txn) async {
        // Limpa dados existentes
        await txn.delete('discursos');
        await txn.delete('categorias');

        // Importa categorias
        for (var categoria in data['categorias']) {
          categoria.remove('id');
          await txn.insert('categorias', categoria);
        }

        // Importa discursos
        for (var discurso in data['discursos']) {
          discurso.remove('id');
          await txn.insert('discursos', discurso);
        }
      });
    } catch (e) {
      throw Exception('Erro ao importar backup: $e');
    }
  }

  /// IMPORTA BACKUP MANTENDO DADOS EXISTENTES (MESCLAR)
  Future<void> importBackupMerge(String filePath) async {
    final db = await database;

    try {
      File file = File(filePath);
      String jsonString = await file.readAsString();
      Map<String, dynamic> backupData = jsonDecode(jsonString);

      if (!validateBackup(backupData)) {
        throw Exception('Arquivo de backup inválido');
      }

      Map<String, dynamic> data = backupData['data'];

      await db.transaction((txn) async {
        // Importa sem deletar dados existentes
        for (var categoria in data['categorias']) {
          categoria.remove('id');
          await txn.insert('categorias', categoria);
        }

        for (var discurso in data['discursos']) {
          discurso.remove('id');
          await txn.insert('discursos', discurso);
        }
      });
    } catch (e) {
      throw Exception('Erro ao importar backup: $e');
    }
  }

  /// LIMPA TODOS OS DADOS DO BANCO
  Future<void> clearAllData() async {
    final db = await database;
    await db.transaction((txn) async {
      await txn.delete('discursos');
      await txn.delete('categorias');
    });
  }

  /// ESTATÍSTICAS DO BACKUP
  Future<String> getBackupInfo(String filePath) async {
    try {
      File file = File(filePath);
      String jsonString = await file.readAsString();
      Map<String, dynamic> backupData = jsonDecode(jsonString);

      if (!validateBackup(backupData)) {
        return '❌ Arquivo de backup inválido';
      }

      var metadata = backupData['metadata'];
      var data = backupData['data'];

      return '''
📊 INFORMAÇÕES DO BACKUP:
📅 Data: ${metadata['exportDate']}
📋 Versão: ${metadata['version']}
📚 Total discursos: ${data['discursos'].length}
🏷️ Total categorias: ${data['categorias'].length}
      ''';
    } catch (e) {
      return 'Erro ao ler backup: $e';
    }
  }
}
