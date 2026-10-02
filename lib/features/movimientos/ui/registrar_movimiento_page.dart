import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../shared/components/discard_guard.dart';
import '../../../shared/components/app_snackbar.dart';
import '../../cuentas/viewmodel/cuenta_viewmodel.dart';
import '../data/movimiento_model.dart';
import '../viewmodel/movimiento_viewmodel.dart';

class RegistrarMovimientoPage extends StatefulWidget {
  const RegistrarMovimientoPage({super.key});

  @override
  State<RegistrarMovimientoPage> createState() => _RegistrarMovimientoPageState();
}

class _RegistrarMovimientoPageState extends State<RegistrarMovimientoPage> {
  final _formKey = GlobalKey<FormState>();
  String _tipo = 'gasto'; // 'gasto' | 'ingreso'
  final _montoCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  String _categoriaSeleccionada = 'Comida';

  final List<String> _categoriasEgresos = ['Comida', 'Transporte', 'Compras', 'Entretenimiento', 'Salud', 'Hogar', 'Educación', 'Otros'];
  final List<String> _categoriasIngresos = ['Sueldo', 'Ventas', 'Transferencia', 'Regalo', 'Inversión', 'Otros'];

  DateTime _fecha = DateTime.now();
  int? _selectedAccountId;

  @override
  void initState() {
    super.initState();
    final cuentas = context.read<CuentaViewModel>().cuentas;
    if (cuentas.isNotEmpty) {
      _selectedAccountId = cuentas.first.id;
    }
  }

  @override
  void dispose() {
    _montoCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;
    final monto = double.tryParse(_montoCtrl.text.trim()) ?? 0.0;
    if (monto <= 0) return;

    final descFinal = _categoriaSeleccionada == 'Otros'
        ? (_descCtrl.text.trim().isEmpty ? 'Otros' : _descCtrl.text.trim())
        : _categoriaSeleccionada;

    final mov = Movimiento(
      tipo: _tipo,
      monto: monto,
      descripcion: descFinal,
      accountId: _selectedAccountId,
      metodoPago: 'cuenta',
      fecha: _fecha,
    );

    final movVm = context.read<MovimientoViewModel>();
    final cuentaVm = context.read<CuentaViewModel>();

    final movId = await movVm.registrarMovimiento(mov);
    if (_selectedAccountId != null) {
      await cuentaVm.cargarCuentas();
    }

    if (!mounted || !context.mounted) {
      return;
    }
    HapticFeedback.heavyImpact();
    AppSnackBar.showSuccessWithUndo(
      context: context,
      message: '${_tipo == 'gasto' ? 'Egreso' : 'Ingreso'} registrado',
      onUndo: () async {
        await movVm.eliminarMovimiento(movId);
        if (_selectedAccountId != null) {
          await cuentaVm.cargarCuentas();
        }
      },
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final cuentas = context.watch<CuentaViewModel>().cuentas;

    final hasData = _montoCtrl.text.trim().isNotEmpty || _descCtrl.text.trim().isNotEmpty;

    return DiscardGuard(
      hasUnsavedChanges: hasData,
      child: Scaffold(
        appBar: AppBar(title: const Text('Nuevo Movimiento')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Selector tipo
              Container(
                decoration: BoxDecoration(
                  color: AppColors.border.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.all(4),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() {
                          _tipo = 'gasto';
                          _categoriaSeleccionada = 'Comida';
                        }),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: _tipo == 'gasto' ? AppColors.gasto : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            'Egreso',
                            style: TextStyle(
                              color: _tipo == 'gasto' ? Colors.white : Theme.of(context).textTheme.bodySmall?.color,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() {
                          _tipo = 'ingreso';
                          _categoriaSeleccionada = 'Sueldo';
                        }),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: _tipo == 'ingreso' ? AppColors.ingreso : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            'Ingreso',
                            style: TextStyle(
                              color: _tipo == 'ingreso' ? Colors.white : Theme.of(context).textTheme.bodySmall?.color,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _montoCtrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                decoration: InputDecoration(
                  labelText: 'Monto (Bs.)',
                  prefixIcon: const Icon(Icons.attach_money, size: 28),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Ingresa el monto';
                  if (double.tryParse(v.trim()) == null) return 'Monto inválido';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _categoriaSeleccionada,
                decoration: InputDecoration(
                  labelText: 'Categoría',
                  prefixIcon: const Icon(Icons.category_outlined),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                ),
                items: (_tipo == 'gasto' ? _categoriasEgresos : _categoriasIngresos)
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (v) {
                  if (v != null) setState(() => _categoriaSeleccionada = v);
                },
              ),
              if (_categoriaSeleccionada == 'Otros') ...[
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descCtrl,
                  decoration: InputDecoration(
                    labelText: 'Descripción personalizada',
                    prefixIcon: const Icon(Icons.description_outlined),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                ),
              ],
              const SizedBox(height: 16),
              DropdownButtonFormField<int>(
                value: _selectedAccountId,
                decoration: InputDecoration(
                  labelText: 'Cuenta / Banco de origen o destino',
                  prefixIcon: const Icon(Icons.account_balance_wallet_outlined),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                ),
                items: cuentas.map((c) {
                  return DropdownMenuItem<int>(
                    value: c.id,
                    child: Text('${c.nombre} (Bs. ${c.saldoActual.toStringAsFixed(2)})'),
                  );
                }).toList(),
                onChanged: (v) => setState(() => _selectedAccountId = v),
              ),
              const SizedBox(height: 16),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.calendar_today_outlined),
                title: Text('Fecha: ${_fecha.day}/${_fecha.month}/${_fecha.year}'),
                trailing: TextButton(
                  child: const Text('Cambiar'),
                  onPressed: () async {
                    final d = await showDatePicker(
                      context: context,
                      initialDate: _fecha,
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2100),
                    );
                    if (d != null) setState(() => _fecha = d);
                  },
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _guardar,
                  child: const Text('Guardar Registro', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ),
      ),
      ),
    );
  }
}
