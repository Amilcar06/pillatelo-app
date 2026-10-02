import '../../../data/repositories/base_repository.dart';
import 'categoria_dao.dart';
import 'categoria_model.dart';

class CategoriaRepository implements BaseRepository<Categoria> {
  final CategoriaDao _dao = CategoriaDao();

  @override
  Future<int> create(Categoria entity) => _dao.insert(entity);

  @override
  Future<int> delete(int id) => _dao.delete(id);

  @override
  Future<List<Categoria>> getAll() => _dao.getAll();

  @override
  Future<Categoria?> getById(int id) async {
    final all = await _dao.getAll();
    try {
      return all.firstWhere((e) => e.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<List<Categoria>> getByTipo(String tipo) => _dao.getByTipo(tipo);

  @override
  Future<int> update(Categoria entity) => _dao.update(entity);
}


