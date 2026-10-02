import '../../../data/repositories/base_repository.dart';
import 'recurrente_dao.dart';
import 'recurrente_model.dart';

class RecurrenteRepository implements BaseRepository<MovimientoRecurrente> {
  final RecurrenteDao _dao = RecurrenteDao();

  @override
  Future<int> create(MovimientoRecurrente entity) => _dao.insert(entity);

  @override
  Future<int> delete(int id) => _dao.delete(id);

  @override
  Future<List<MovimientoRecurrente>> getAll() => _dao.getAll();

  Future<List<MovimientoRecurrente>> getActivos() => _dao.getActivos();

  @override
  Future<MovimientoRecurrente?> getById(int id) async {
    final all = await _dao.getAll();
    try {
      return all.firstWhere((r) => r.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<int> update(MovimientoRecurrente entity) => _dao.update(entity);
}
