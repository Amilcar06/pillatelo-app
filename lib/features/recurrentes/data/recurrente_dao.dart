import '../../../data/database/database_helper.dart';
import 'recurrente_model.dart';

class RecurrenteDao {
  final dbHelper = DatabaseHelper.instance;

  Future<int> insert(MovimientoRecurrente r) async {
    final db = await dbHelper.database;
    return await db.insert('recurring_movements', r.toMap());
  }

  Future<int> update(MovimientoRecurrente r) async {
    final db = await dbHelper.database;
    return await db.update(
      'recurring_movements',
      r.toMap(),
      where: 'id = ?',
      whereArgs: [r.id],
    );
  }

  Future<int> delete(int id) async {
    final db = await dbHelper.database;
    return await db.delete('recurring_movements', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<MovimientoRecurrente>> getAll() async {
    final db = await dbHelper.database;
    final maps = await db.query('recurring_movements');
    return maps.map((m) => MovimientoRecurrente.fromMap(m)).toList();
  }

  Future<List<MovimientoRecurrente>> getActivos() async {
    final db = await dbHelper.database;
    final maps = await db.query('recurring_movements', where: 'activo = 1');
    return maps.map((m) => MovimientoRecurrente.fromMap(m)).toList();
  }
}
