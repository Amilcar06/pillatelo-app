import '../../../data/database/database_helper.dart';
import 'categoria_model.dart';

class CategoriaDao {
  static const String table = 'categories';

  Future<int> insert(Categoria categoria) async {
    final db = await DatabaseHelper.instance.database;
    return db.insert(table, categoria.toMap());
  }

  Future<int> update(Categoria categoria) async {
    final db = await DatabaseHelper.instance.database;
    return db.update(table, categoria.toMap(), where: 'id = ?', whereArgs: [categoria.id]);
  }

  Future<int> delete(int id) async {
    final db = await DatabaseHelper.instance.database;
    return db.delete(table, where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Categoria>> getAll() async {
    final db = await DatabaseHelper.instance.database;
    final rows = await db.query(table, orderBy: 'nombre ASC');
    return rows.map((e) => Categoria.fromMap(e)).toList();
  }

  Future<List<Categoria>> getByTipo(String tipo) async {
    final db = await DatabaseHelper.instance.database;
    final rows = await db.query(table, where: 'tipo = ?', whereArgs: [tipo], orderBy: 'nombre ASC');
    return rows.map((e) => Categoria.fromMap(e)).toList();
  }
}


