import '../../../data/repositories/base_repository.dart';
import '../../configuracion/data/settings_model.dart';
import '../../configuracion/data/configuracion_repository.dart';
import 'movimiento_dao.dart';
import 'movimiento_model.dart';

class MovimientoRepository implements BaseRepository<Movimiento> {
  final MovimientoDao _dao = MovimientoDao();
  final ConfiguracionRepository _configRepo = ConfiguracionRepository();

  @override
  Future<int> create(Movimiento entity) async {
    final id = await _dao.insert(entity);
    await _updateBalances(entity);
    return id;
  }

  Future<void> _updateBalances(Movimiento mov) async {
    final cfg = await _configRepo.get();
    double cash = cfg.cashBalance;
    double bank = cfg.bankBalance;
    final sign = mov.tipo == 'ingreso' ? 1.0 : -1.0;
    if (mov.metodoPago == 'efectivo') {
      cash += sign * mov.monto;
    } else {
      bank += sign * mov.monto;
    }
    await _configRepo.update(Configuracion(
      id: cfg.id,
      pin: cfg.pin,
      moneda: cfg.moneda,
      cashBalance: cash,
      bankBalance: bank,
      setupComplete: cfg.setupComplete,
    ));
  }

  @override
  Future<int> delete(int id) => _dao.delete(id);

  @override
  Future<List<Movimiento>> getAll() => _dao.getAll();

  @override
  Future<Movimiento?> getById(int id) => _dao.getById(id);

  @override
  Future<int> update(Movimiento entity) => _dao.update(entity);

  Future<List<Movimiento>> getByDateRange(DateTime from, DateTime to) => _dao.getByDateRange(from, to);
  Future<List<Movimiento>> getByCategoria(int categoriaId) => _dao.getByCategoria(categoriaId);
}
