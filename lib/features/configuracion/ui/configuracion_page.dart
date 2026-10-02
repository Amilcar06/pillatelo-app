import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/theme_provider.dart';
import '../../../core/providers/font_scale_provider.dart';
import '../../seguridad/data/pin_service.dart';
import '../../movimientos/data/movimiento_repository.dart';
import '../../../shared/services/export_service.dart';

class ConfiguracionPage extends StatefulWidget {
  const ConfiguracionPage({super.key});

  @override
  State<ConfiguracionPage> createState() => _ConfiguracionPageState();
}

class _ConfiguracionPageState extends State<ConfiguracionPage> {
  final _pinService = PinService();
  bool _hasPin = false;

  @override
  void initState() {
    super.initState();
    _checkPinStatus();
  }

  Future<void> _checkPinStatus() async {
    final hasPin = await _pinService.hasPin();
    if (mounted) {
      setState(() => _hasPin = hasPin);
    }
  }

  Future<void> _removePin() async {
    await _pinService.removePin();
    await _checkPinStatus();
    if (!mounted || !context.mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('PIN de seguridad eliminado')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuración'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text('Seguridad', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.lock_outline),
                  title: const Text('Código de acceso (PIN)'),
                  subtitle: Text(_hasPin ? 'Activado' : 'Desactivado'),
                  trailing: Switch(
                    value: _hasPin,
                    onChanged: (v) async {
                      if (v) {
                        Navigator.pushNamed(context, '/setup/pin').then((_) => _checkPinStatus());
                      } else {
                        await _removePin();
                      }
                    },
                  ),
                ),
                if (_hasPin) ...[
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.password_outlined),
                    title: const Text('Cambiar PIN'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      Navigator.pushNamed(context, '/setup/pin').then((_) => _checkPinStatus());
                    },
                  ),
                ]
              ],
            ),
          ),
          const SizedBox(height: 32),
          const Text('Personalización y Datos', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.category_outlined),
                  title: const Text('Gestionar Categorías'),
                  subtitle: const Text('Añade, edita o elimina categorías de ingresos y gastos'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.pushNamed(context, '/configuracion/categorias'),
                ),
                const Divider(height: 1),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Apariencia', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      Consumer<ThemeProvider>(
                        builder: (context, themeProvider, child) {
                          return SegmentedButton<ThemeMode>(
                            segments: const [
                              ButtonSegment(
                                value: ThemeMode.system,
                                icon: Icon(Icons.brightness_auto),
                                label: Text('Auto'),
                              ),
                              ButtonSegment(
                                value: ThemeMode.light,
                                icon: Icon(Icons.light_mode),
                                label: Text('Claro'),
                              ),
                              ButtonSegment(
                                value: ThemeMode.dark,
                                icon: Icon(Icons.dark_mode),
                                label: Text('Oscuro'),
                              ),
                            ],
                            selected: {themeProvider.themeMode},
                            onSelectionChanged: (Set<ThemeMode> newSelection) {
                              themeProvider.setThemeMode(newSelection.first);
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                Consumer<FontScaleProvider>(
                  builder: (context, fontScale, child) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Text('Tamaño de Texto', style: TextStyle(fontWeight: FontWeight.bold)),
                              const Spacer(),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  fontScale.label,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Theme.of(context).colorScheme.secondary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.text_fields, size: 16),
                              Expanded(
                                child: Slider(
                                  value: fontScale.stepIndex.toDouble(),
                                  min: 0,
                                  max: 2,
                                  divisions: 2,
                                  onChanged: (v) {
                                    fontScale.setFromStep(v.round());
                                  },
                                ),
                              ),
                              const Icon(Icons.text_fields, size: 24),
                            ],
                          ),
                          Text(
                            'Ejemplo de texto con tamaño actual',
                            style: TextStyle(
                              fontSize: 14,
                              color: Theme.of(context).textTheme.bodySmall?.color,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.download_outlined),
                  title: const Text('Exportar Datos a CSV'),
                  subtitle: const Text('Descarga todos tus movimientos'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () async {
                    final movs = await MovimientoRepository().getAll();
                    if (context.mounted) {
                      ExportService.exportToCSV(movs, context);
                    }
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          const Text('Información', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.shield_outlined),
                  title: const Text('Política de Privacidad'),
                  subtitle: const Text('100% Local, Privado y Seguro'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.pushNamed(context, '/configuracion/privacidad'),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.info_outline),
                  title: const Text('Acerca de Pillatelo'),
                  subtitle: const Text('Versión 1.0.0, desarrollador e información'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.pushNamed(context, '/configuracion/acerca'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 48),
          Center(
            child: Text(
              'Pillatelo v1.0.0 (Offline & Privado)',
              style: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}
