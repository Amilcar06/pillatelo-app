import '../../../data/database/database_helper.dart';
import 'movimiento_model.dart';

class MovimientoDao {
  static const String table = 'movements';

  Future<int> insert(Movimiento mov) async {
    final db = await DatabaseHelper.instance.database;
    final id = await db.insert(table, mov.toMap());

    // Ajustar saldo de la cuenta si aplica
    if (mov.accountId != null) {
      final delta = (mov.tipo == 'ingreso') ? mov.monto : -mov.monto;
      await db.rawUpdate(
        'UPDATE accounts SET saldo_actual = saldo_actual + ? WHERE id = ?',
        [delta, mov.accountId],
      );
    }
    return id;
  }

  Future<int> update(Movimiento mov) async {
    if (mov.id == null) throw ArgumentError('Movimiento.id requerido para update');
    final db = await DatabaseHelper.instance.database;
    return db.update(table, mov.toMap(), where: 'id = ?', whereArgs: [mov.id]);
  }

  Future<int> delete(int id) async {
    final db = await DatabaseHelper.instance.database;
    final mov = await getById(id);
    if (mov != null && mov.accountId != null) {
      final delta = (mov.tipo == 'ingreso') ? -mov.monto : mov.monto;
      await db.rawUpdate(
        'UPDATE accounts SET saldo_actual = saldo_actual + ? WHERE id = ?',
        [delta, mov.accountId],
      );
    }
    return db.update(
      table,
      {
        'is_deleted': 1,
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<Movimiento?> getById(int id) async {
    final db = await DatabaseHelper.instance.database;
    final res = await db.query(table, where: 'id = ? AND is_deleted = 0', whereArgs: [id], limit: 1);
    if (res.isEmpty) return null;
    return Movimiento.fromMap(res.first);
  }

  Future<List<Movimiento>> getAll() async {
    final db = await DatabaseHelper.instance.database;
    final rows = await db.query(table, where: 'is_deleted = 0', orderBy: 'fecha DESC');
    return rows.map((e) => Movimiento.fromMap(e)).toList();
  }

  Future<List<Movimiento>> getByDateRange(DateTime from, DateTime to) async {
    final db = await DatabaseHelper.instance.database;
    final rows = await db.query(
      table,
      where: 'fecha >= ? AND fecha <= ? AND is_deleted = 0',
      whereArgs: [from.toIso8601String(), to.toIso8601String()],
      orderBy: 'fecha DESC',
    );
    return rows.map((e) => Movimiento.fromMap(e)).toList();
  }

  Future<List<Movimiento>> getByCategoria(int categoriaId) async {
    final db = await DatabaseHelper.instance.database;
    final rows = await db.query(
      table,
      where: 'categoria_id = ? AND is_deleted = 0',
      whereArgs: [categoriaId],
      orderBy: 'fecha DESC',
    );
    return rows.map((e) => Movimiento.fromMap(e)).toList();
  }
}
