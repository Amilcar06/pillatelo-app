import 'package:flutter/material.dart';
import '../../configuracion/data/configuracion_repository.dart';
import '../../configuracion/data/settings_model.dart';

class SaldoInicialPage extends StatefulWidget {
  const SaldoInicialPage({super.key});
  @override
  State<SaldoInicialPage> createState() => _SaldoInicialPageState();
}

class _SaldoInicialPageState extends State<SaldoInicialPage> {
  final _formKey = GlobalKey<FormState>();
  final _efectivoController = TextEditingController();
  final _bancoController = TextEditingController();
  final _notaController = TextEditingController();
  final _configRepo = ConfiguracionRepository();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Saldo Inicial')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 500),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      '¿Con cuánto dinero empiezas?',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Registra el dinero que tienes actualmente para que tus balances sean precisos.',
                      style: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color),
                    ),
                    const SizedBox(height: 32),
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Saldo en efectivo',
                        prefixIcon: Icon(Icons.payments_outlined),
                      ),
                      controller: _efectivoController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) return 'Ingresa el saldo en efectivo';
                        if (double.tryParse(value.trim()) == null) return 'Ingresa un número válido';
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Saldo en banco (opcional)',
                        prefixIcon: Icon(Icons.account_balance_outlined),
                      ),
                      controller: _bancoController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Nota (opcional)',
                        prefixIcon: Icon(Icons.note_alt_outlined),
                      ),
                      controller: _notaController,
                      maxLines: 2,
                    ),
                    const SizedBox(height: 40),
                    ElevatedButton(
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          final efectivo = double.tryParse(_efectivoController.text.trim()) ?? 0.0;
                          final banco = double.tryParse(_bancoController.text.trim()) ?? 0.0;
                          final cfg = await _configRepo.get();
                          await _configRepo.update(Configuracion(
                            id: cfg.id,
                            pin: cfg.pin,
                            moneda: cfg.moneda,
                            cashBalance: efectivo,
                            bankBalance: banco,
                            setupComplete: cfg.setupComplete,
                          ));
                          if (!context.mounted) return;
                          Navigator.pushNamed(context, '/setup/pin');
                        }
                      },
                      child: const Text('Continuar'),
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () => Navigator.pushNamed(context, '/setup/pin'),
                      child: const Text('Omitir este paso'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
