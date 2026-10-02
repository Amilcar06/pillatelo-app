import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../cuentas/viewmodel/cuenta_viewmodel.dart';
import '../../../shared/components/discard_guard.dart';
import '../../../shared/components/app_snackbar.dart';
import '../data/recurrente_model.dart';
import '../viewmodel/recurrente_viewmodel.dart';

class RegistrarRecurrentePage extends StatefulWidget {
  const RegistrarRecurrentePage({super.key});

  @override
  State<RegistrarRecurrentePage> createState() => _RegistrarRecurrentePageState();
}

class _RegistrarRecurrentePageState extends State<RegistrarRecurrentePage> {
  final _formKey = GlobalKey<FormState>();
  String _tipo = 'gasto';
  final _montoCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  String _categoriaSeleccionada = 'Comida';
  String _frecuencia = 'mensual'; // 'diario', 'semanal', 'mensual', 'anual'

  final List<String> _categoriasEgresos = ['Comida', 'Transporte', 'Servicios', 'Otros'];
  final List<String> _categoriasIngresos = ['Sueldo', 'Ventas', 'Otros'];
  final List<String> _frecuencias = ['diario', 'semanal', 'mensual', 'anual'];

  DateTime _fechaInicio = DateTime.now();
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

    final r = MovimientoRecurrente(
      tipo: _tipo,
      monto: monto,
      descripcion: _descCtrl.text.trim().isEmpty ? _categoriaSeleccionada : _descCtrl.text.trim(),
      frecuencia: _frecuencia,
      fechaInicio: _fechaInicio,
      accountId: _selectedAccountId,
    );

    await context.read<RecurrenteViewModel>().guardarRecurrente(r);

    if (!mounted || !context.mounted) {
      return;
    }
    AppSnackBar.showSuccess(context, 'Movimiento programado correctamente');
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final cuentas = context.watch<CuentaViewModel>().cuentas;
    final hasData = _montoCtrl.text.trim().isNotEmpty || _descCtrl.text.trim().isNotEmpty;

    return DiscardGuard(
      hasUnsavedChanges: hasData,
      child: Scaffold(
      appBar: AppBar(title: const Text('Nuevo Recurrente')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Tipo (Ingreso / Egreso)
              Row(
                children: [
                  Expanded(
                    child: RadioListTile<String>(
                      title: const Text('Gasto'),
                      value: 'gasto',
                      groupValue: _tipo,
                      onChanged: (v) => setState(() {
                        _tipo = v!;
                        _categoriaSeleccionada = _categoriasEgresos.first;
                      }),
                    ),
                  ),
                  Expanded(
                    child: RadioListTile<String>(
                      title: const Text('Ingreso'),
                      value: 'ingreso',
                      groupValue: _tipo,
                      onChanged: (v) => setState(() {
                        _tipo = v!;
                        _categoriaSeleccionada = _categoriasIngresos.first;
                      }),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _montoCtrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: 'Monto (Bs.)',
                  prefixIcon: const Icon(Icons.attach_money),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Requerido';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descCtrl,
                decoration: InputDecoration(
                  labelText: 'Descripción',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Requerido';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _frecuencia,
                decoration: InputDecoration(
                  labelText: 'Frecuencia',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                ),
                items: _frecuencias.map((f) => DropdownMenuItem(value: f, child: Text(f.toUpperCase()))).toList(),
                onChanged: (v) => setState(() => _frecuencia = v!),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<int>(
                value: _selectedAccountId,
                decoration: InputDecoration(
                  labelText: 'Cuenta de origen/destino',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                ),
                items: cuentas.map((c) => DropdownMenuItem(value: c.id, child: Text(c.nombre))).toList(),
                onChanged: (v) => setState(() => _selectedAccountId = v),
              ),
              const SizedBox(height: 16),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.calendar_today_outlined),
                title: Text('Fecha de Inicio: ${_fechaInicio.day}/${_fechaInicio.month}/${_fechaInicio.year}'),
                trailing: TextButton(
                  child: const Text('Cambiar'),
                  onPressed: () async {
                    final d = await showDatePicker(
                      context: context,
                      initialDate: _fechaInicio,
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2100),
                    );
                    if (d != null) setState(() => _fechaInicio = d);
                  },
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _guardar,
                  child: const Text('Guardar', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
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
