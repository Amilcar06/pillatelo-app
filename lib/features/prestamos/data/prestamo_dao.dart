import '../../../data/database/database_helper.dart';
import 'devolucion_model.dart';
import 'prestamo_model.dart';

class PrestamoDao {
  static const String table = 'loans';
  static const String tablePayments = 'loan_payments';

  Future<int> insert(Prestamo p) async {
    final db = await DatabaseHelper.instance.database;
    return db.insert(table, p.toMap());
  }

  Future<int> update(Prestamo p) async {
    final db = await DatabaseHelper.instance.database;
    return db.update(table, p.toMap(), where: 'id = ?', whereArgs: [p.id]);
  }

  Future<int> delete(int id) async {
    final db = await DatabaseHelper.instance.database;
    final prestamo = await getById(id);
    
    if (prestamo != null) {
      // 1. Revertir todas las devoluciones (pagos) en sus respectivas cuentas
      final pagos = await getDevolucionesByLoan(id);
      for (final pago in pagos) {
        if (pago.accountId != null) {
          // Si era prestado, el pago fue un ingreso (+monto), lo revertimos restando.
          // Si era recibido, el pago fue un egreso (-monto), lo revertimos sumando.
          final deltaPago = (prestamo.tipo == 'prestado') ? -pago.monto : pago.monto;
          await db.rawUpdate(
            'UPDATE accounts SET saldo_actual = saldo_actual + ? WHERE id = ?',
            [deltaPago, pago.accountId],
          );
        }
      }

      // 2. Revertir el préstamo inicial en su cuenta de origen
      if (prestamo.accountId != null) {
        // Si presté dinero, el delta original fue -monto. Al borrar, devuelvo (+monto).
        // Si pedí prestado, el delta original fue +monto. Al borrar, resto (-monto).
        final deltaInicial = (prestamo.tipo == 'prestado') ? prestamo.monto : -prestamo.monto;
        await db.rawUpdate(
          'UPDATE accounts SET saldo_actual = saldo_actual + ? WHERE id = ?',
          [deltaInicial, prestamo.accountId],
        );
      }
    }

    await db.delete(tablePayments, where: 'loan_id = ?', whereArgs: [id]);
    return db.update(
      table,
      {'is_deleted': 1, 'updated_at': DateTime.now().toIso8601String()},
      where: 'id = ?',
      whereArgs: [id]
    );
  }

  Future<List<Prestamo>> getAll() async {
    final db = await DatabaseHelper.instance.database;
    final rows = await db.query(table, where: 'is_deleted = 0', orderBy: 'creado_en DESC');
    return rows.map((e) => Prestamo.fromMap(e)).toList();
  }

  Future<Prestamo?> getById(int id) async {
    final db = await DatabaseHelper.instance.database;
    final rows = await db.query(table, where: 'id = ? AND is_deleted = 0', whereArgs: [id]);
    if (rows.isNotEmpty) {
      return Prestamo.fromMap(rows.first);
    }
    return null;
  }

  Future<List<Prestamo>> getActive() async {
    final db = await DatabaseHelper.instance.database;
    final rows = await db.query(table, where: 'status = ? AND is_deleted = 0', whereArgs: ['active'], orderBy: 'creado_en DESC');
    return rows.map((e) => Prestamo.fromMap(e)).toList();
  }

  Future<List<Prestamo>> getSettled() async {
    final db = await DatabaseHelper.instance.database;
    final rows = await db.query(table, where: 'status = ? AND is_deleted = 0', whereArgs: ['settled'], orderBy: 'creado_en DESC');
    return rows.map((e) => Prestamo.fromMap(e)).toList();
  }

  // Devoluciones / Abonos
  Future<int> registrarDevolucion(Devolucion dev) async {
    final db = await DatabaseHelper.instance.database;
    final paymentId = await db.insert(tablePayments, dev.toMap());

    // Actualizar el remaining_amount del préstamo
    final prestamo = await getById(dev.loanId);
    if (prestamo != null) {
      final nuevoRestante = (prestamo.remainingAmount - dev.monto).clamp(0.0, double.infinity);
      final nuevoEstado = nuevoRestante <= 0 ? 'settled' : 'active';
      await update(prestamo.copyWith(
        remainingAmount: nuevoRestante,
        status: nuevoEstado,
      ));
    }

    // Si tiene accountId especificado, ajustar el saldo de la cuenta
    if (dev.accountId != null) {
      // Si el préstamo era 'prestado' (me debían), la devolución entra a mi cuenta (+monto).
      // Si el préstamo era 'recibido' (yo debía), la devolución sale de mi cuenta (-monto).
      final delta = (prestamo?.tipo == 'prestado') ? dev.monto : -dev.monto;
      await db.rawUpdate(
        'UPDATE accounts SET saldo_actual = saldo_actual + ? WHERE id = ?',
        [delta, dev.accountId],
      );
    }

    return paymentId;
  }

  Future<List<Devolucion>> getDevolucionesByLoan(int loanId) async {
    final db = await DatabaseHelper.instance.database;
    final rows = await db.query(
      tablePayments,
      where: 'loan_id = ?',
      whereArgs: [loanId],
      orderBy: 'fecha DESC',
    );
    return rows.map((e) => Devolucion.fromMap(e)).toList();
  }
}
