import 'package:flutter/foundation.dart';
import '../data/movimiento_repository.dart';
import '../data/movimiento_model.dart';
import '../../../shared/services/home_widget_service.dart';

import '../../../core/di/locator.dart';

class MovimientoViewModel extends ChangeNotifier {
  final MovimientoRepository _repo = locator<MovimientoRepository>();
  List<Movimiento> _movimientos = [];
  bool _isLoading = false;

  List<Movimiento> get movimientos => _movimientos;
  bool get isLoading => _isLoading;

  double get totalIngresos => _movimientos
      .where((m) => m.tipo == 'ingreso')
      .fold(0.0, (sum, m) => sum + m.monto);

  double get totalGastos => _movimientos
      .where((m) => m.tipo == 'gasto')
      .fold(0.0, (sum, m) => sum + m.monto);

  double get totalIngresosMesActual {
    final now = DateTime.now();
    return _movimientos
        .where((m) =>
            m.tipo == 'ingreso' &&
            m.fecha.year == now.year &&
            m.fecha.month == now.month)
        .fold(0.0, (sum, m) => sum + m.monto);
  }

  double get totalGastosMesActual {
    final now = DateTime.now();
    return _movimientos
        .where((m) =>
            m.tipo == 'gasto' &&
            m.fecha.year == now.year &&
            m.fecha.month == now.month)
        .fold(0.0, (sum, m) => sum + m.monto);
  }

  Future<void> cargarMovimientos() async {
    _isLoading = true;
    notifyListeners();
    try {
      _movimientos = await _repo.getAll();
    } catch (e) {
      debugPrint('Error al cargar movimientos: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
      _actualizarHomeWidget();
    }
  }

  Future<int> registrarMovimiento(Movimiento m) async {
    final id = await _repo.create(m);
    await cargarMovimientos();
    return id;
  }

  Future<void> eliminarMovimiento(int id) async {
    await _repo.delete(id);
    await cargarMovimientos();
  }

  /// Envía datos actualizados al widget nativo de la pantalla de inicio.
  Future<void> _actualizarHomeWidget() async {
    try {
      final saldo = _movimientos.fold<double>(
        0.0,
        (sum, m) => m.tipo == 'ingreso' ? sum + m.monto : sum - m.monto,
      );

      String ultimoRegistro = 'Sin registros';
      if (_movimientos.isNotEmpty) {
        final ultimo = _movimientos.first;
        final signo = ultimo.tipo == 'ingreso' ? '+' : '-';
        ultimoRegistro = '$signo Bs. ${ultimo.monto.toStringAsFixed(2)} · ${ultimo.descripcion}';
      }

      await HomeWidgetService.actualizarWidget(
        saldoTotal: saldo,
        ultimoRegistro: ultimoRegistro,
      );
    } catch (e) {
      debugPrint('Error actualizando home widget: $e');
    }
  }
}
