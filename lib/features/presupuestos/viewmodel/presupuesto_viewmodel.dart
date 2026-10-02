import 'package:flutter/foundation.dart';
import '../data/presupuesto_repository.dart';
import '../data/presupuesto_model.dart';
import '../../movimientos/data/movimiento_repository.dart';

import '../../../core/di/locator.dart';

class PresupuestoViewModel extends ChangeNotifier {
  final PresupuestoRepository _repo = locator<PresupuestoRepository>();
  final MovimientoRepository _movRepo = locator<MovimientoRepository>();

  List<Presupuesto> _presupuestos = [];
  bool _isLoading = false;

  List<Presupuesto> get presupuestos => _presupuestos;
  bool get isLoading => _isLoading;

  Future<void> cargarPresupuestos() async {
    _isLoading = true;
    notifyListeners();
    try {
      final data = await _repo.getAll();
      final movs = await _movRepo.getAll();
      
      final now = DateTime.now();
      final gastosEsteMes = movs.where((m) => 
        m.tipo == 'gasto' && 
        m.fecha.month == now.month && 
        m.fecha.year == now.year
      ).toList();

      _presupuestos = data.map((p) {
        final gastosCategoria = gastosEsteMes
            .where((m) => m.categoriaId == p.categoriaId)
            .fold(0.0, (sum, m) => sum + m.monto);
        return p.copyWith(gastado: gastosCategoria);
      }).toList();

    } catch (e) {
      debugPrint('Error cargando presupuestos: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> guardarPresupuesto(Presupuesto p) async {
    if (p.id == null) {
      await _repo.create(p);
    } else {
      await _repo.update(p);
    }
    await cargarPresupuestos();
  }

  Future<void> eliminarPresupuesto(int id) async {
    await _repo.delete(id);
    await cargarPresupuestos();
  }
}
