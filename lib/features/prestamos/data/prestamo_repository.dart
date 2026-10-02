import '../../../data/repositories/base_repository.dart';
import 'devolucion_model.dart';
import 'prestamo_dao.dart';
import 'prestamo_model.dart';

class PrestamoRepository implements BaseRepository<Prestamo> {
  final PrestamoDao _dao = PrestamoDao();

  @override
  Future<int> create(Prestamo entity) => _dao.insert(entity);

  @override
  Future<int> delete(int id) => _dao.delete(id);

  @override
  Future<List<Prestamo>> getAll() => _dao.getAll();

  @override
  Future<Prestamo?> getById(int id) => _dao.getById(id);

  Future<List<Prestamo>> getActive() => _dao.getActive();
  Future<List<Prestamo>> getSettled() => _dao.getSettled();

  @override
  Future<int> update(Prestamo entity) => _dao.update(entity);

  Future<int> registrarDevolucion(Devolucion dev) => _dao.registrarDevolucion(dev);
  Future<List<Devolucion>> getDevolucionesByLoan(int loanId) => _dao.getDevolucionesByLoan(loanId);
}
