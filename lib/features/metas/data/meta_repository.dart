import '../../../data/repositories/base_repository.dart';
import '../../configuracion/data/settings_model.dart';
import '../../configuracion/data/configuracion_repository.dart';
import 'meta_dao.dart';
import 'meta_model.dart';

class MetaRepository implements BaseRepository<Meta> {
  final MetaDao _dao = MetaDao();
  final ConfiguracionRepository _configRepo = ConfiguracionRepository();

  @override
  Future<int> create(Meta entity) => _dao.insert(entity);

  @override
  Future<int> delete(int id) => _dao.delete(id);

  @override
  Future<List<Meta>> getAll() => _dao.getAll();

  @override
  Future<Meta?> getById(int id) async {
    final all = await _dao.getAll();
    try {
      return all.firstWhere((e) => e.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<List<Meta>> getActive() => _dao.getActive();
  Future<List<Meta>> getCompleted() => _dao.getCompleted();

  @override
  Future<int> update(Meta entity) => _dao.update(entity);

  Future<int> addContribution(Contribution c) => _dao.insertContribution(c);
  Future<List<Contribution>> getContributionsByGoal(int goalId) => _dao.getContributionsByGoal(goalId);

  Future<void> addContributionAndAdjustBalance(Contribution c, Meta meta) async {
    // Insert contribution
    await _dao.insertContribution(c);
    // Update goal currentAmount
    final updated = Meta(
      id: meta.id,
      nombre: meta.nombre,
      targetAmount: meta.targetAmount,
      currentAmount: meta.currentAmount + c.monto,
      fechaLimite: meta.fechaLimite,
      estado: (meta.currentAmount + c.monto) >= meta.targetAmount ? 'completada' : meta.estado,
      creadoEn: meta.creadoEn,
    );
    await _dao.update(updated);
    // Reduce cash balance
    final cfg = await _configRepo.get();
    await _configRepo.update(Configuracion(
      id: cfg.id,
      pin: cfg.pin,
      moneda: cfg.moneda,
      cashBalance: (cfg.cashBalance - c.monto),
      bankBalance: cfg.bankBalance,
      setupComplete: cfg.setupComplete,
    ));
  }
}


