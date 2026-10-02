import 'package:flutter/foundation.dart';
import '../data/recurrente_repository.dart';
import '../data/recurrente_model.dart';

import '../../../core/di/locator.dart';

class RecurrenteViewModel extends ChangeNotifier {
  final RecurrenteRepository _repo = locator<RecurrenteRepository>();

  List<MovimientoRecurrente> _recurrentes = [];
  bool _isLoading = false;

  List<MovimientoRecurrente> get recurrentes => _recurrentes;
  bool get isLoading => _isLoading;

  Future<void> cargarRecurrentes() async {
    _isLoading = true;
    notifyListeners();
    try {
      _recurrentes = await _repo.getAll();
    } catch (e) {
      debugPrint('Error cargando recurrentes: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> guardarRecurrente(MovimientoRecurrente r) async {
    if (r.id == null) {
      await _repo.create(r);
    } else {
      await _repo.update(r);
    }
    await cargarRecurrentes();
  }

  Future<void> eliminarRecurrente(int id) async {
    await _repo.delete(id);
    await cargarRecurrentes();
  }
}
