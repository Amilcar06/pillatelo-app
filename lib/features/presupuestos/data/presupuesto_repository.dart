import '../../../data/repositories/base_repository.dart';
import 'presupuesto_dao.dart';
import 'presupuesto_model.dart';

class PresupuestoRepository implements BaseRepository<Presupuesto> {
  final PresupuestoDao _dao = PresupuestoDao();

  @override
  Future<int> create(Presupuesto entity) => _dao.insert(entity);

  @override
  Future<int> delete(int id) => _dao.delete(id);

  @override
  Future<List<Presupuesto>> getAll() => _dao.getAll();

  @override
  Future<Presupuesto?> getById(int id) async {
    final all = await _dao.getAll();
    try {
      return all.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<int> update(Presupuesto entity) => _dao.update(entity);
}
