import 'package:flutter/material.dart';
import '../data/cuenta_model.dart';
import '../data/cuenta_repository.dart';

import '../../../core/di/locator.dart';

class CuentaViewModel extends ChangeNotifier {
  final CuentaRepository _repo = locator<CuentaRepository>();

  List<Cuenta> _cuentas = [];
  bool _isLoading = false;

  List<Cuenta> get cuentas => _cuentas;
  bool get isLoading => _isLoading;

  double get saldoTotalUnificado =>
      _cuentas.fold(0.0, (sum, item) => sum + item.saldoActual);

  Future<void> cargarCuentas() async {
    _isLoading = true;
    notifyListeners();
    try {
      _cuentas = await _repo.obtenerCuentas();
    } catch (e) {
      debugPrint('Error al cargar cuentas: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> agregarCuenta(Cuenta cuenta) async {
    await _repo.agregarCuenta(cuenta);
    await cargarCuentas();
  }

  Future<void> actualizarCuenta(Cuenta cuenta) async {
    await _repo.actualizarCuenta(cuenta);
    await cargarCuentas();
  }

  Future<void> eliminarCuenta(int id) async {
    await _repo.eliminarCuenta(id);
    await cargarCuentas();
  }

  Future<void> ajustarSaldo(int accountId, double delta) async {
    await _repo.ajustarSaldo(accountId, delta);
    await cargarCuentas();
  }
}
