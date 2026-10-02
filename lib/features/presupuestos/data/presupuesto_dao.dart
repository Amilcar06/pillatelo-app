import '../../../data/database/database_helper.dart';
import 'presupuesto_model.dart';

class PresupuestoDao {
  final dbHelper = DatabaseHelper.instance;

  Future<int> insert(Presupuesto p) async {
    final db = await dbHelper.database;
    return await db.insert('budgets', p.toMap());
  }

  Future<int> update(Presupuesto p) async {
    final db = await dbHelper.database;
    return await db.update(
      'budgets',
      p.toMap(),
      where: 'id = ?',
      whereArgs: [p.id],
    );
  }

  Future<int> delete(int id) async {
    final db = await dbHelper.database;
    return await db.delete('budgets', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Presupuesto>> getAll() async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT b.*, c.nombre as categoria_nombre, c.color as categoria_color
      FROM budgets b
      INNER JOIN categories c ON b.categoria_id = c.id
    ''');
    return maps.map((m) => Presupuesto.fromMap(m)).toList();
  }
}
