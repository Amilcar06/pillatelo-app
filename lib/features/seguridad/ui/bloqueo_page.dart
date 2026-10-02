import 'package:flutter/material.dart';
import '../data/pin_service.dart';
import 'numeric_keypad.dart';

class BloqueoPage extends StatefulWidget {
  const BloqueoPage({super.key});

  @override
  State<BloqueoPage> createState() => _BloqueoPageState();
}

class _BloqueoPageState extends State<BloqueoPage> {
  final _pinService = PinService();
  String _enteredPin = '';
  String? _errorMessage;

  void _onKeyPress(String val) {
    if (_enteredPin.length < 6) {
      setState(() {
        _enteredPin += val;
        _errorMessage = null;
      });
      if (_enteredPin.length == 4 || _enteredPin.length == 6) {
        _verifyPin();
      }
    }
  }

  void _onDelete() {
    if (_enteredPin.isNotEmpty) {
      setState(() {
        _enteredPin = _enteredPin.substring(0, _enteredPin.length - 1);
        _errorMessage = null;
      });
    }
  }

  Future<void> _verifyPin() async {
    final isValid = await _pinService.verifyPin(_enteredPin);
    if (isValid) {
      if (!mounted || !context.mounted) {
        return;
      }
      Navigator.pop(context);
    } else {
      setState(() {
        _enteredPin = '';
        _errorMessage = 'PIN incorrecto. Intenta de nuevo.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.asset(
                  Theme.of(context).brightness == Brightness.dark
                      ? 'assets/images/logoDark.png'
                      : 'assets/images/logoLight.png',
                  width: 72,
                  height: 72,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Aplicación Bloqueada',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Ingresa tu PIN de seguridad para continuar',
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  4,
                  (index) => Container(
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: index < _enteredPin.length ? Colors.blue : Colors.grey.shade300,
                    ),
                  ),
                ),
              ),
              if (_errorMessage != null) ...[
                const SizedBox(height: 16),
                Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
              ],
              const Spacer(),
              NumericKeypad(
                onKeyPress: _onKeyPress,
                onDelete: _onDelete,
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
