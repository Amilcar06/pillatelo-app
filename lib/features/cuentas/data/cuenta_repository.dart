import 'cuenta_dao.dart';
import 'cuenta_model.dart';

class CuentaRepository {
  final _dao = CuentaDao();

  Future<int> agregarCuenta(Cuenta c) => _dao.insert(c);
  Future<List<Cuenta>> obtenerCuentas() => _dao.getAll();
  Future<Cuenta?> obtenerPorId(int id) => _dao.getById(id);
  Future<int> actualizarCuenta(Cuenta c) => _dao.update(c);
  Future<int> eliminarCuenta(int id) => _dao.delete(id);
  Future<void> ajustarSaldo(int id, double delta) => _dao.ajustarSaldo(id, delta);
}
