import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Proveedor que controla la escala de fuente global de la aplicación.
/// Permite al usuario ajustar entre 3 niveles: Normal (1.0), Grande (1.15), Muy Grande (1.3).
class FontScaleProvider extends ChangeNotifier {
  static const _key = 'font_scale';
  double _scale = 1.0;

  double get scale => _scale;

  /// Etiqueta legible para la UI.
  String get label {
    if (_scale <= 1.0) {
      return 'Normal';
    } else if (_scale <= 1.15) {
      return 'Grande';
    } else {
      return 'Muy Grande';
    }
  }

  /// Índice discreto para el Slider (0 = Normal, 1 = Grande, 2 = Muy Grande).
  int get stepIndex {
    if (_scale <= 1.0) {
      return 0;
    } else if (_scale <= 1.15) {
      return 1;
    } else {
      return 2;
    }
  }

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _scale = prefs.getDouble(_key) ?? 1.0;
    notifyListeners();
  }

  Future<void> setScale(double value) async {
    _scale = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_key, value);
    notifyListeners();
  }

  /// Conveniencia: establece desde el índice del Slider.
  Future<void> setFromStep(int step) async {
    switch (step) {
      case 0:
        await setScale(1.0);
        break;
      case 1:
        await setScale(1.15);
        break;
      case 2:
        await setScale(1.3);
        break;
    }
  }
}
