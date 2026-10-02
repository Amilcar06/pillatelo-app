import '../../../data/database/database_helper.dart';
import 'cuenta_model.dart';

class CuentaDao {
  final dbProvider = DatabaseHelper.instance;

  Future<int> insert(Cuenta cuenta) async {
    final db = await dbProvider.database;
    return await db.insert('accounts', cuenta.toMap());
  }

  Future<List<Cuenta>> getAll() async {
    final db = await dbProvider.database;
    final res = await db.query('accounts', orderBy: 'id ASC');
    return res.map((m) => Cuenta.fromMap(m)).toList();
  }

  Future<Cuenta?> getById(int id) async {
    final db = await dbProvider.database;
    final res = await db.query('accounts', where: 'id = ?', whereArgs: [id]);
    if (res.isNotEmpty) {
      return Cuenta.fromMap(res.first);
    }
    return null;
  }

  Future<int> update(Cuenta cuenta) async {
    final db = await dbProvider.database;
    return await db.update(
      'accounts',
      cuenta.toMap(),
      where: 'id = ?',
      whereArgs: [cuenta.id],
    );
  }

  Future<int> delete(int id) async {
    final db = await dbProvider.database;
    return await db.delete('accounts', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> ajustarSaldo(int accountId, double delta) async {
    final db = await dbProvider.database;
    await db.rawUpdate(
      'UPDATE accounts SET saldo_actual = saldo_actual + ? WHERE id = ?',
      [delta, accountId],
    );
  }
}
