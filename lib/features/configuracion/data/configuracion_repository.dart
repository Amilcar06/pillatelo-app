import '../../../data/repositories/base_repository.dart';
import 'configuracion_dao.dart';
import 'settings_model.dart';

class ConfiguracionRepository implements BaseRepository<Configuracion> {
  final ConfiguracionDao _dao = ConfiguracionDao();

  @override
  Future<int> create(Configuracion entity) async {
    // create = update/insert single row
    return _dao.update(entity);
  }

  @override
  Future<int> delete(int id) async {
    // not applicable for single settings row
    return 0;
  }

  @override
  Future<List<Configuracion>> getAll() async {
    final cfg = await _dao.getConfig();
    return [cfg];
  }

  @override
  Future<Configuracion?> getById(int id) async {
    return _dao.getConfig();
  }

  Future<Configuracion> get() => _dao.getConfig();

  @override
  Future<int> update(Configuracion entity) => _dao.update(entity);

  Future<int> reset() => _dao.reset();
}


