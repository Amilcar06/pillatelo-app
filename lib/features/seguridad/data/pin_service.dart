import 'dart:convert';
import 'package:crypto/crypto.dart';
import '../../configuracion/data/configuracion_repository.dart';
import '../../configuracion/data/settings_model.dart';

class PinService {
  final ConfiguracionRepository _configRepo = ConfiguracionRepository();

  Future<void> setPin(String rawPin) async {
    _validatePin(rawPin);
    final salt = _generateSalt(16);
    final hashed = _hashPin(rawPin, salt);
    final stored = '$salt:$hashed';
    final cfg = await _configRepo.get();
    await _configRepo.update(Configuracion(
      id: cfg.id,
      pin: stored,
      moneda: cfg.moneda,
      cashBalance: cfg.cashBalance,
      bankBalance: cfg.bankBalance,
      setupComplete: cfg.setupComplete,
    ));
  }

  Future<bool> verifyPin(String rawPin) async {
    final cfg = await _configRepo.get();
    final stored = cfg.pin;
    if (stored == null || !stored.contains(':')) return false;
    final parts = stored.split(':');
    final salt = parts[0];
    final hash = parts[1];
    final attempt = _hashPin(rawPin, salt);
    return _timingSafeEquals(hash, attempt);
  }

  Future<bool> hasPin() async {
    final cfg = await _configRepo.get();
    return cfg.pin != null && cfg.pin!.isNotEmpty;
  }

  Future<void> removePin() async {
    final cfg = await _configRepo.get();
    await _configRepo.update(Configuracion(
      id: cfg.id,
      pin: null,
      moneda: cfg.moneda,
      cashBalance: cfg.cashBalance,
      bankBalance: cfg.bankBalance,
      setupComplete: cfg.setupComplete,
    ));
  }

  void _validatePin(String pin) {
    if (!(pin.length == 4 || pin.length == 6) || int.tryParse(pin) == null) {
      throw ArgumentError('PIN inválido');
    }
  }

  String _generateSalt(int length) {
    final now = DateTime.now().microsecondsSinceEpoch.toString();
    return md5.convert(utf8.encode(now)).toString().substring(0, length);
  }

  String _hashPin(String pin, String salt) {
    final bytes = utf8.encode('$salt|$pin');
    return sha256.convert(bytes).toString();
  }

  bool _timingSafeEquals(String a, String b) {
    if (a.length != b.length) return false;
    var res = 0;
    for (var i = 0; i < a.length; i++) {
      res |= a.codeUnitAt(i) ^ b.codeUnitAt(i);
    }
    return res == 0;
  }
}


