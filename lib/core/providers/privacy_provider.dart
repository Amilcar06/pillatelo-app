import 'package:flutter/material.dart';

class PrivacyProvider extends ChangeNotifier {
  bool _isPrivate = false;

  bool get isPrivate => _isPrivate;

  void toggle() {
    _isPrivate = !_isPrivate;
    notifyListeners();
  }
}
