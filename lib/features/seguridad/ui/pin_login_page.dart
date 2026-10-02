import 'package:flutter/material.dart';
import '../data/pin_service.dart';
import 'numeric_keypad.dart';

class PinLoginPage extends StatefulWidget {
  const PinLoginPage({super.key});
  @override
  State<PinLoginPage> createState() => _PinLoginPageState();
}

class _PinLoginPageState extends State<PinLoginPage> {
  final _pinService = PinService();
  String _pin = '';
  String? _error;
  final int pinLength = 4;

  void _onKeyPress(String key) {
    setState(() {
      _error = null;
      if (_pin.length < pinLength) {
        _pin += key;
        if (_pin.length == pinLength) {
          _verifyLogin();
        }
      }
    });
  }

  void _onDelete() {
    setState(() {
      _error = null;
      if (_pin.isNotEmpty) {
        _pin = _pin.substring(0, _pin.length - 1);
      }
    });
  }

  Future<void> _verifyLogin() async {
    final ok = await _pinService.verifyPin(_pin);
    if (ok) {
      if (!mounted || !context.mounted) {
        return;
      }
      Navigator.pushReplacementNamed(context, '/inicio');
    } else {
      if (!mounted) {
        return;
      }
      setState(() {
        _error = 'Código incorrecto. Intenta de nuevo.';
        _pin = '';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(),
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
            const SizedBox(height: 24),
            const Text(
              'Bienvenido de vuelta',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Ingresa tu código de acceso',
              style: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color),
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(pinLength, (index) {
                final isFilled = index < _pin.length;
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 12),
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isFilled ? Theme.of(context).colorScheme.primary : Colors.transparent,
                    border: Border.all(
                      color: isFilled ? Theme.of(context).colorScheme.primary : Colors.grey.withValues(alpha: 0.5),
                      width: 2,
                    ),
                  ),
                );
              }),
            ),
            if (_error != null) ...[
              const SizedBox(height: 24),
              Text(_error!, style: const TextStyle(color: Colors.red)),
            ],
            const Spacer(),
            NumericKeypad(
              onKeyPress: _onKeyPress,
              onDelete: _onDelete,
            ),
          ],
        ),
      ),
    );
  }
}
