import 'package:flutter/foundation.dart';
import '../../movimientos/data/movimiento_model.dart';
import '../../movimientos/data/movimiento_repository.dart';

class ReporteViewModel extends ChangeNotifier {
  final MovimientoRepository _movRepo = MovimientoRepository();

  String _rangoSeleccionado = 'mes'; // semana | mes | ano
  List<Movimiento> _movimientosPeriodo = [];
  bool _isLoading = false;

  String get rangoSeleccionado => _rangoSeleccionado;
  List<Movimiento> get movimientosPeriodo => _movimientosPeriodo;
  bool get isLoading => _isLoading;

  double get totalIngresos => _movimientosPeriodo
      .where((m) => m.tipo == 'ingreso')
      .fold(0.0, (sum, m) => sum + m.monto);

  double get totalEgresos => _movimientosPeriodo
      .where((m) => m.tipo == 'gasto')
      .fold(0.0, (sum, m) => sum + m.monto);

  double get balanceNeto => totalIngresos - totalEgresos;

  Future<void> cargarReporte([String? rango]) async {
    if (rango != null) _rangoSeleccionado = rango;
    _isLoading = true;
    notifyListeners();

    try {
      final todos = await _movRepo.getAll();
      final ahora = DateTime.now();

      _movimientosPeriodo = todos.where((m) {
        if (_rangoSeleccionado == 'semana') {
          final inicioSemana = ahora.subtract(Duration(days: ahora.weekday - 1));
          return m.fecha.isAfter(inicioSemana.subtract(const Duration(seconds: 1)));
        } else if (_rangoSeleccionado == 'mes') {
          return m.fecha.year == ahora.year && m.fecha.month == ahora.month;
        } else if (_rangoSeleccionado == 'ano') {
          return m.fecha.year == ahora.year;
        }
        return true;
      }).toList();
    } catch (e) {
      debugPrint('Error al cargar reporte: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void cambiarRango(String nuevoRango) {
    _rangoSeleccionado = nuevoRango;
    cargarReporte();
  }
}
