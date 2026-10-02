import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../shared/components/discard_guard.dart';
import '../../../shared/components/app_snackbar.dart';
import '../../cuentas/viewmodel/cuenta_viewmodel.dart';
import '../data/prestamo_model.dart';
import '../viewmodel/prestamo_viewmodel.dart';

class RegistrarPrestamoPage extends StatefulWidget {
  final String initialTipo;
  const RegistrarPrestamoPage({super.key, this.initialTipo = 'prestado'});

  @override
  State<RegistrarPrestamoPage> createState() => _RegistrarPrestamoPageState();
}

class _RegistrarPrestamoPageState extends State<RegistrarPrestamoPage> {
  final _formKey = GlobalKey<FormState>();
  late String _tipo; // 'prestado' (me deben) | 'recibido' (yo debo)
  final _personaController = TextEditingController();
  final _montoController = TextEditingController();
  final _notasController = TextEditingController();
  DateTime _fecha = DateTime.now();
  int? _selectedAccountId;

  @override
  void initState() {
    super.initState();
    _tipo = widget.initialTipo;
    final cuentas = context.read<CuentaViewModel>().cuentas;
    if (cuentas.isNotEmpty) {
      _selectedAccountId = cuentas.first.id;
    }
  }

  @override
  void dispose() {
    _personaController.dispose();
    _montoController.dispose();
    _notasController.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;
    final monto = double.tryParse(_montoController.text) ?? 0.0;
    if (monto <= 0) return;

    final prestamo = Prestamo(
      tipo: _tipo,
      nombrePersona: _personaController.text.trim(),
      monto: monto,
      remainingAmount: monto,
      accountId: _selectedAccountId,
      notas: _notasController.text.trim().isEmpty ? null : _notasController.text.trim(),
      creadoEn: _fecha,
    );

    final prestamoVm = context.read<PrestamoViewModel>();
    final cuentaVm = context.read<CuentaViewModel>();

    final prestamoId = await prestamoVm.registrarPrestamo(prestamo);

    // Ajustar saldo de la cuenta si aplica
    if (_selectedAccountId != null) {
      final delta = (_tipo == 'prestado') ? -monto : monto;
      await cuentaVm.ajustarSaldo(_selectedAccountId!, delta);
    }

    if (!mounted || !context.mounted) {
      return;
    }
    HapticFeedback.heavyImpact();
    AppSnackBar.showSuccessWithUndo(
      context: context,
      message: 'Préstamo registrado exitosamente',
      onUndo: () async {
        await prestamoVm.eliminarPrestamo(prestamoId);
        if (_selectedAccountId != null) {
          final reverseDelta = (_tipo == 'prestado') ? monto : -monto;
          await cuentaVm.ajustarSaldo(_selectedAccountId!, reverseDelta);
        }
      },
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final cuentas = context.watch<CuentaViewModel>().cuentas;

    final hasData = _personaController.text.trim().isNotEmpty || _montoController.text.trim().isNotEmpty;

    return DiscardGuard(
      hasUnsavedChanges: hasData,
      child: Scaffold(
        appBar: AppBar(title: const Text('Nuevo Préstamo')),
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
                        onTap: () => setState(() => _tipo = 'prestado'),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: _tipo == 'prestado' ? AppColors.prestamo : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            'Presté (Me deben)',
                            style: TextStyle(
                              color: _tipo == 'prestado' ? Colors.white : Theme.of(context).textTheme.bodySmall?.color,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _tipo = 'recibido'),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: _tipo == 'recibido' ? AppColors.gasto : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            'Pedí (Debo)',
                            style: TextStyle(
                              color: _tipo == 'recibido' ? Colors.white : Theme.of(context).textTheme.bodySmall?.color,
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
                controller: _personaController,
                decoration: InputDecoration(
                  labelText: _tipo == 'prestado' ? '¿A quién le prestaste?' : '¿Quién te prestó?',
                  prefixIcon: const Icon(Icons.person_outline),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                ),
                validator: (v) => v == null || v.trim().isEmpty ? 'Nombre requerido' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _montoController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                decoration: InputDecoration(
                  labelText: 'Monto total (Bs.)',
                  prefixIcon: const Icon(Icons.attach_money),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Ingresa el monto';
                  if (double.tryParse(v) == null) return 'Monto no válido';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<int>(
                value: _selectedAccountId,
                decoration: InputDecoration(
                  labelText: _tipo == 'prestado' ? '¿De qué cuenta salió el dinero?' : '¿A qué cuenta ingresó?',
                  prefixIcon: const Icon(Icons.account_balance_wallet_outlined),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                ),
                items: cuentas.map((c) {
                  return DropdownMenuItem<int>(
                    value: c.id,
                    child: Text('${c.nombre} (Bs. ${c.saldoActual.toStringAsFixed(2)})'),
                  );
                }).toList(),
                onChanged: (val) => setState(() => _selectedAccountId = val),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _notasController,
                maxLines: 2,
                decoration: InputDecoration(
                  labelText: 'Notas / Detalles opcionales',
                  prefixIcon: const Icon(Icons.note_alt_outlined),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.calendar_today_outlined),
                title: Text('Fecha del préstamo: ${_fecha.day}/${_fecha.month}/${_fecha.year}'),
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
                  child: const Text('Guardar Préstamo'),
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
