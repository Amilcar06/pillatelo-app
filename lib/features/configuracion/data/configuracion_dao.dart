import '../../../data/database/database_helper.dart';
import 'settings_model.dart';

class ConfiguracionDao {
  static const String table = 'settings';

  Future<Configuracion> getConfig() async {
    final db = await DatabaseHelper.instance.database;
    final res = await db.query(table, limit: 1);
    if (res.isEmpty) {
      // initialize if missing
      final id = await db.insert(table, {
        'pin': null,
        'moneda': '\u0000',
        'cash_balance': 0.0,
        'bank_balance': 0.0,
        'setup_complete': 0,
      });
      return Configuracion(id: id);
    }
    return Configuracion.fromMap(res.first);
  }

  Future<int> update(Configuracion config) async {
    final db = await DatabaseHelper.instance.database;
    if (config.id != null) {
      return db.update(table, config.toMap(), where: 'id = ?', whereArgs: [config.id]);
    }
    // update first row if id unknown
    final rows = await db.query(table, limit: 1);
    if (rows.isEmpty) {
      return db.insert(table, config.toMap());
    }
    final id = rows.first['id'] as int;
    return db.update(table, config.toMap(), where: 'id = ?', whereArgs: [id]);
  }

  Future<int> reset() async {
    final db = await DatabaseHelper.instance.database;
    await db.delete(table);
    return db.insert(table, {
      'pin': null,
      'moneda': '\u0000',
      'cash_balance': 0.0,
      'bank_balance': 0.0,
      'setup_complete': 0,
    });
  }
}


