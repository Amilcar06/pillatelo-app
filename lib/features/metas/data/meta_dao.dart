import '../../../data/database/database_helper.dart';
import 'meta_model.dart';

class MetaDao {
  static const String table = 'goals';
  static const String contribTable = 'goal_contributions';

  Future<int> insert(Meta meta) async {
    final db = await DatabaseHelper.instance.database;
    return db.insert(table, meta.toMap());
  }

  Future<int> update(Meta meta) async {
    final db = await DatabaseHelper.instance.database;
    return db.update(table, meta.toMap(), where: 'id = ?', whereArgs: [meta.id]);
  }

  Future<int> delete(int id) async {
    final db = await DatabaseHelper.instance.database;
    await db.delete(contribTable, where: 'goal_id = ?', whereArgs: [id]);
    return db.delete(table, where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Meta>> getAll() async {
    final db = await DatabaseHelper.instance.database;
    final rows = await db.query(table, orderBy: 'creado_en DESC');
    return rows.map((e) => Meta.fromMap(e)).toList();
  }

  Future<List<Meta>> getActive() async {
    final db = await DatabaseHelper.instance.database;
    final rows = await db.query(table, where: 'estado = ?', whereArgs: ['activa'], orderBy: 'creado_en DESC');
    return rows.map((e) => Meta.fromMap(e)).toList();
  }

  Future<List<Meta>> getCompleted() async {
    final db = await DatabaseHelper.instance.database;
    final rows = await db.query(table, where: 'estado = ?', whereArgs: ['completada'], orderBy: 'creado_en DESC');
    return rows.map((e) => Meta.fromMap(e)).toList();
  }

  Future<int> insertContribution(Contribution c) async {
    final db = await DatabaseHelper.instance.database;
    return db.insert(contribTable, c.toMap());
  }

  Future<List<Contribution>> getContributionsByGoal(int goalId) async {
    final db = await DatabaseHelper.instance.database;
    final rows = await db.query(contribTable, where: 'goal_id = ?', whereArgs: [goalId], orderBy: 'fecha DESC');
    return rows.map((e) => Contribution.fromMap(e)).toList();
  }
}


