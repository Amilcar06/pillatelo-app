import 'package:flutter/material.dart';
import '../data/meta_model.dart';
import '../data/meta_repository.dart';
import '../../../core/di/locator.dart';

class MetaViewModel extends ChangeNotifier {
  final MetaRepository _repo = locator<MetaRepository>();

  List<Meta> _metas = [];
  final Map<int, List<Contribution>> _contributionsMap = {};
  bool _isLoading = false;

  List<Meta> get metas => _metas;
  List<Meta> get activas => _metas.where((m) => m.estado == 'activa').toList();
  List<Meta> get completadas => _metas.where((m) => m.estado == 'completada').toList();
  bool get isLoading => _isLoading;

  double get totalTarget => _metas.fold(0.0, (sum, item) => sum + item.targetAmount);
  double get totalSaved => _metas.fold(0.0, (sum, item) => sum + item.currentAmount);
  double get progresoGeneral => totalTarget > 0 ? (totalSaved / totalTarget).clamp(0.0, 1.0) : 0.0;

  List<Contribution> getContributionsForGoal(int goalId) {
    return _contributionsMap[goalId] ?? [];
  }

  Future<void> cargarMetas() async {
    _isLoading = true;
    notifyListeners();
    try {
      _metas = await _repo.getAll();
      for (final m in _metas) {
        if (m.id != null) {
          _contributionsMap[m.id!] = await _repo.getContributionsByGoal(m.id!);
        }
      }
    } catch (e) {
      debugPrint('Error al cargar metas: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> registrarMeta(Meta m) async {
    await _repo.create(m);
    await cargarMetas();
  }

  Future<void> agregarAporte(Contribution c, Meta meta) async {
    await _repo.addContributionAndAdjustBalance(c, meta);
    await cargarMetas();
  }

  Future<void> marcarCompletada(Meta meta) async {
    final updated = Meta(
      id: meta.id,
      nombre: meta.nombre,
      targetAmount: meta.targetAmount,
      currentAmount: meta.currentAmount,
      fechaLimite: meta.fechaLimite,
      estado: 'completada',
      creadoEn: meta.creadoEn,
    );
    await _repo.update(updated);
    await cargarMetas();
  }

  Future<void> eliminarMeta(int id) async {
    await _repo.delete(id);
    await cargarMetas();
  }
}
