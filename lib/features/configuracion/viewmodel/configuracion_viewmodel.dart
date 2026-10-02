import 'package:flutter/material.dart';
import '../data/categoria_model.dart';
import '../data/categoria_repository.dart';
import '../../../core/di/locator.dart';

class ConfiguracionViewModel extends ChangeNotifier {
  final CategoriaRepository _catRepo = locator<CategoriaRepository>();

  List<Categoria> _categorias = [];
  bool _isLoading = false;

  List<Categoria> get categorias => _categorias;
  List<Categoria> get ingresos => _categorias.where((c) => c.tipo == 'ingreso').toList();
  List<Categoria> get gastos => _categorias.where((c) => c.tipo == 'gasto').toList();
  bool get isLoading => _isLoading;

  Future<void> cargarCategorias() async {
    _isLoading = true;
    notifyListeners();
    try {
      _categorias = await _catRepo.getAll();
    } catch (e) {
      debugPrint('Error al cargar categorías: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> agregarCategoria(Categoria c) async {
    await _catRepo.create(c);
    await cargarCategorias();
  }

  Future<void> editarCategoria(Categoria c) async {
    await _catRepo.update(c);
    await cargarCategorias();
  }

  Future<void> eliminarCategoria(int id) async {
    await _catRepo.delete(id);
    await cargarCategorias();
  }
}
