import 'package:flutter/material.dart';
import '../data/pin_service.dart';
import 'numeric_keypad.dart';

class PinPage extends StatefulWidget {
  const PinPage({super.key});
  @override
  State<PinPage> createState() => _PinPageState();
}

class _PinPageState extends State<PinPage> {
  String pin = '';
  String confirmPin = '';
  String? _error;
  bool isConfirming = false;
  final _pinService = PinService();
  final int pinLength = 4;

  void _onKeyPress(String key) {
    setState(() {
      _error = null;
      if (!isConfirming) {
        if (pin.length < pinLength) {
          pin += key;
          if (pin.length == pinLength) {
            isConfirming = true;
          }
        }
      } else {
        if (confirmPin.length < pinLength) {
          confirmPin += key;
          if (confirmPin.length == pinLength) {
            _verifyAndSave();
          }
        }
      }
    });
  }

  void _onDelete() {
    setState(() {
      _error = null;
      if (isConfirming) {
        if (confirmPin.isNotEmpty) {
          confirmPin = confirmPin.substring(0, confirmPin.length - 1);
        } else {
          isConfirming = false;
          pin = pin.substring(0, pin.length - 1);
        }
      } else {
        if (pin.isNotEmpty) {
          pin = pin.substring(0, pin.length - 1);
        }
      }
    });
  }

  Future<void> _verifyAndSave() async {
    if (pin != confirmPin) {
      setState(() {
        _error = 'Los códigos no coinciden. Intenta de nuevo.';
        pin = '';
        confirmPin = '';
        isConfirming = false;
      });
      return;
    }

    try {
      await _pinService.setPin(pin);
      if (!mounted || !context.mounted) {
        return;
      }
      Navigator.pushNamed(context, '/setup/preferencias');
    } catch (e) {
      if (!mounted) {
        return;
      }
      setState(() {
        _error = 'Error al guardar PIN';
        pin = '';
        confirmPin = '';
        isConfirming = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentPin = isConfirming ? confirmPin : pin;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Seguridad'),
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: Column(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.asset(
                Theme.of(context).brightness == Brightness.dark
                    ? 'assets/images/logoDark.png'
                    : 'assets/images/logoLight.png',
                width: 64,
                height: 64,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              isConfirming ? 'Confirma tu código' : 'Crea un código de acceso',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              isConfirming ? 'Vuelve a ingresarlo' : 'Úsalo para desbloquear la app',
              style: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color),
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(pinLength, (index) {
                final isFilled = index < currentPin.length;
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
