import 'package:flutter/material.dart';
import '../../configuracion/data/configuracion_repository.dart';
import '../../configuracion/data/settings_model.dart';

class ConfiguracionInicialPage extends StatefulWidget {
  const ConfiguracionInicialPage({super.key});
  @override
  State<ConfiguracionInicialPage> createState() => _ConfiguracionInicialPageState();
}

class _ConfiguracionInicialPageState extends State<ConfiguracionInicialPage> {
  final _configRepo = ConfiguracionRepository();
  String _moneda = 'BOB';
  bool _temaOscuro = false;
  bool _syncFirebase = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Preferencias Iniciales')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 500),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Personaliza tu experiencia',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Configura la moneda base para tus finanzas y la sincronización opcional con Firebase.',
                    style: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color),
                  ),
                  const SizedBox(height: 32),
                  DropdownButtonFormField<String>(
                    value: _moneda,
                    items: ['BOB', 'USD', 'EUR']
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                    onChanged: (val) => setState(() => _moneda = (val ?? 'BOB')),
                    decoration: const InputDecoration(
                      labelText: 'Moneda principal',
                      prefixIcon: Icon(Icons.monetization_on_outlined),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Card(
                    child: SwitchListTile(
                      title: const Text('Tema oscuro (Demostración)'),
                      subtitle: const Text('Alternar manualmente (solo preview)'),
                      value: _temaOscuro,
                      onChanged: (val) => setState(() => _temaOscuro = val),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Card(
                    child: SwitchListTile(
                      title: const Text('Sincronización en la nube (Firebase)'),
                      subtitle: const Text('Respalda tus datos automáticamente'),
                      value: _syncFirebase,
                      onChanged: (val) => setState(() => _syncFirebase = val),
                    ),
                  ),
                  const SizedBox(height: 48),
                  ElevatedButton(
                    onPressed: () async {
                      final cfg = await _configRepo.get();
                      await _configRepo.update(Configuracion(
                        id: cfg.id,
                        pin: cfg.pin,
                        moneda: _moneda,
                        cashBalance: cfg.cashBalance,
                        bankBalance: cfg.bankBalance,
                        setupComplete: true,
                      ));
                      if (!context.mounted) return;
                      Navigator.pushNamedAndRemoveUntil(context, '/inicio', (route) => false);
                    },
                    child: const Text('Finalizar configuración'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
