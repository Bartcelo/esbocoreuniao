import 'database_helper.dart';
import 'discurso_model.dart';

class DiscursoRepository {
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  // CREATE - Inserir novo discurso
  Future<int> insertDiscurso(Discurso discurso) async {
    final db = await _databaseHelper.database;
    return await db.insert('discursos', discurso.toMap());
  }

  // READ - Buscar todos os discursos

  Future<List<Discurso>> getDiscursos({String? categoria}) async {
    final db = await _databaseHelper.database;

    final List<Map<String, dynamic>> maps = await db.query(
      'discursos',
      where: categoria != null ? 'categoria = ?' : null, // ✅ Filtro opcional
      whereArgs: categoria != null ? [categoria] : null, // ✅ Args opcionais
      orderBy: 'data_criacao DESC',
    );

    return List.generate(maps.length, (i) {
      return Discurso.fromMap(maps[i]);
    });
  }

  // READ - Buscar discurso por ID
  Future<Discurso?> getDiscursoById(int id) async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'discursos',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return Discurso.fromMap(maps.first);
    }
    return null;
  }

  Future<int> updateDiscurso(Discurso discurso) async {
    final db = await _databaseHelper.database;

    final map = discurso.toMap();

    final result = await db.update(
      'discursos',
      map,
      where: 'id = ?',
      whereArgs: [discurso.id],
    );
    return result;
  }

  // DELETE - Excluir discurso
  Future<int> deleteDiscurso(int id) async {
    final db = await _databaseHelper.database;
    return await db.delete('discursos', where: 'id = ?', whereArgs: [id]);
  }

  // Buscar discursos por título (exemplo de busca)
  Future<List<Discurso>> searchDiscursos(String query) async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'discursos',
      where: 'titulo LIKE ?',
      whereArgs: ['%$query%'],
    );
    return List.generate(maps.length, (i) {
      return Discurso.fromMap(maps[i]);
    });
  }

  Future<List<Discurso>> getDiscursosPorCategorias(
    List<String> categorias,
  ) async {
    final db = await _databaseHelper.database;

    // Cria placeholders: ?, ?, ?
    final placeholders = List.filled(categorias.length, '?').join(', ');

    final List<Map<String, dynamic>> maps = await db.query(
      'discursos',
      where: 'categoria IN ($placeholders)', // WHERE categoria IN (?, ?, ?)
      whereArgs: categorias, // Lista de valores
      orderBy: 'data_criacao DESC',
    );

    return List.generate(maps.length, (i) {
      return Discurso.fromMap(maps[i]);
    });
  }
}
