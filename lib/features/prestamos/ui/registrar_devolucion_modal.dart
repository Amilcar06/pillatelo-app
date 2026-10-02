import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../shared/components/app_snackbar.dart';
import '../../cuentas/viewmodel/cuenta_viewmodel.dart';
import '../data/devolucion_model.dart';
import '../data/prestamo_model.dart';
import '../viewmodel/prestamo_viewmodel.dart';

class RegistrarDevolucionModal extends StatefulWidget {
  final Prestamo prestamo;

  const RegistrarDevolucionModal({super.key, required this.prestamo});

  @override
  State<RegistrarDevolucionModal> createState() => _RegistrarDevolucionModalState();
}

class _RegistrarDevolucionModalState extends State<RegistrarDevolucionModal> {
  final _formKey = GlobalKey<FormState>();
  final _montoController = TextEditingController();
  final _notasController = TextEditingController();
  DateTime _fecha = DateTime.now();
  int? _selectedAccountId;

  @override
  void initState() {
    super.initState();
    _montoController.text = widget.prestamo.remainingAmount > 0
        ? widget.prestamo.remainingAmount.toStringAsFixed(2)
        : '';
    final cuentas = context.read<CuentaViewModel>().cuentas;
    if (cuentas.isNotEmpty) {
      _selectedAccountId = cuentas.first.id;
    }
  }

  @override
  void dispose() {
    _montoController.dispose();
    _notasController.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;
    final monto = double.tryParse(_montoController.text) ?? 0.0;
    if (monto <= 0) return;

    final dev = Devolucion(
      loanId: widget.prestamo.id!,
      monto: monto,
      accountId: _selectedAccountId,
      fecha: _fecha,
      notas: _notasController.text.trim().isEmpty ? null : _notasController.text.trim(),
    );

    final prestamoVm = context.read<PrestamoViewModel>();
    final cuentaVm = context.read<CuentaViewModel>();

    await prestamoVm.registrarDevolucion(dev);
    if (_selectedAccountId != null) {
      await cuentaVm.cargarCuentas();
    }

    if (!mounted || !context.mounted) {
      return;
    }
    AppSnackBar.showSuccess(context, 'Devolución registrada correctamente');
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final cuentas = context.watch<CuentaViewModel>().cuentas;
    final esPrestado = widget.prestamo.tipo == 'prestado';

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        top: 20,
        left: 20,
        right: 20,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  esPrestado ? 'Registrar Cobro / Devolución' : 'Registrar Pago de Deuda',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Persona: ${widget.prestamo.nombrePersona} • Pendiente: Bs. ${widget.prestamo.remainingAmount.toStringAsFixed(2)}',
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _montoController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              decoration: InputDecoration(
                labelText: 'Monto devuelto (Bs.)',
                prefixIcon: const Icon(Icons.attach_money),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
              ),
              validator: (v) {
                if (v == null || v.isEmpty) return 'Ingresa un monto';
                if (double.tryParse(v) == null) return 'Monto inválido';
                return null;
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<int>(
              value: _selectedAccountId,
              decoration: InputDecoration(
                labelText: esPrestado ? '¿A qué cuenta ingresa?' : '¿De qué cuenta sale?',
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
              decoration: InputDecoration(
                labelText: 'Nota (opcional, ej. "Devolvió más por interés")',
                prefixIcon: const Icon(Icons.note_alt_outlined),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.calendar_today_outlined),
              title: Text('Fecha devolución: ${_fecha.day}/${_fecha.month}/${_fecha.year}'),
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
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _guardar,
                child: const Text('Guardar Devolución', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
