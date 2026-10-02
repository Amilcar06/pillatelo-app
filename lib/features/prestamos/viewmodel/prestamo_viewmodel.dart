import 'package:flutter/material.dart';
import '../data/devolucion_model.dart';
import '../data/prestamo_model.dart';
import '../data/prestamo_repository.dart';

import '../../../core/di/locator.dart';

class PrestamoViewModel extends ChangeNotifier {
  final PrestamoRepository _repo = locator<PrestamoRepository>();

  List<Prestamo> _prestamos = [];
  final Map<int, List<Devolucion>> _devolucionesMap = {};
  bool _isLoading = false;

  List<Prestamo> get prestamos => _prestamos;

  List<Prestamo> get prestadosPorMi =>
      _prestamos.where((p) => p.tipo == 'prestado').toList();

  List<Prestamo> get recibidosDeOtros =>
      _prestamos.where((p) => p.tipo == 'recibido').toList();

  double get totalMeDeben => _prestamos
      .where((p) => p.tipo == 'prestado' && p.status == 'active')
      .fold(0.0, (sum, item) => sum + item.remainingAmount);

  double get totalDebo => _prestamos
      .where((p) => p.tipo == 'recibido' && p.status == 'active')
      .fold(0.0, (sum, item) => sum + item.remainingAmount);

  bool get isLoading => _isLoading;

  List<Devolucion> getDevolucionesForLoan(int loanId) {
    return _devolucionesMap[loanId] ?? [];
  }

  Future<void> cargarPrestamos() async {
    _isLoading = true;
    notifyListeners();
    try {
      _prestamos = await _repo.getAll();
      for (final p in _prestamos) {
        if (p.id != null) {
          _devolucionesMap[p.id!] = await _repo.getDevolucionesByLoan(p.id!);
        }
      }
    } catch (e) {
      debugPrint('Error al cargar préstamos: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<int> registrarPrestamo(Prestamo p) async {
    final id = await _repo.create(p);
    await cargarPrestamos();
    return id;
  }

  Future<void> registrarDevolucion(Devolucion dev) async {
    await _repo.registrarDevolucion(dev);
    await cargarPrestamos();
  }

  Future<void> eliminarPrestamo(int id) async {
    await _repo.delete(id);
    await cargarPrestamos();
  }
}
