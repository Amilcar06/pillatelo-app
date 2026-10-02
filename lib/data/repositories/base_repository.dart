abstract class BaseRepository<T> {
  Future<int> create(T entity);
  Future<int> update(T entity);
  Future<int> delete(int id);
  Future<T?> getById(int id);
  Future<List<T>> getAll();
}


