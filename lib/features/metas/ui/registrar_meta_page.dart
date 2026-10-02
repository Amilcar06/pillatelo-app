import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../shared/components/discard_guard.dart';
import '../../../shared/components/app_snackbar.dart';
import '../data/meta_model.dart';
import '../viewmodel/meta_viewmodel.dart';

class RegistrarMetaPage extends StatefulWidget {
  const RegistrarMetaPage({super.key});

  @override
  State<RegistrarMetaPage> createState() => _RegistrarMetaPageState();
}

class _RegistrarMetaPageState extends State<RegistrarMetaPage> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _montoObjetivoController = TextEditingController();
  final _aporteInicialController = TextEditingController();

  DateTime _fechaLimite = DateTime.now().add(const Duration(days: 30));
  bool _isSaving = false;

  @override
  void dispose() {
    _nombreController.dispose();
    _montoObjetivoController.dispose();
    _aporteInicialController.dispose();
    super.dispose();
  }

  Future<void> _seleccionarFecha(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _fechaLimite,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
    );
    if (picked != null) {
      setState(() => _fechaLimite = picked);
    }
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final nombre = _nombreController.text.trim();
      final targetAmount = double.parse(_montoObjetivoController.text);
      final aporteInicial = double.tryParse(_aporteInicialController.text) ?? 0.0;

      final meta = Meta(
        nombre: nombre,
        targetAmount: targetAmount,
        currentAmount: aporteInicial,
        fechaLimite: _fechaLimite,
        estado: aporteInicial >= targetAmount ? 'completada' : 'activa',
      );

      final metaVm = context.read<MetaViewModel>();
      await metaVm.registrarMeta(meta);

      if (!mounted || !context.mounted) {
        return;
      }
      AppSnackBar.showSuccess(context, 'Meta creada con éxito');
      Navigator.pop(context);
    } catch (e) {
      if (!mounted || !context.mounted) {
        return;
      }
      AppSnackBar.showError(context, 'Error al guardar: $e');
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final df = DateFormat('dd MMM yyyy');

    final hasData = _nombreController.text.trim().isNotEmpty || _montoObjetivoController.text.trim().isNotEmpty;

    return DiscardGuard(
      hasUnsavedChanges: hasData,
      child: Scaffold(
      appBar: AppBar(
        title: const Text('Nueva Meta Financiera'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _nombreController,
                decoration: const InputDecoration(
                  labelText: 'Nombre de la meta *',
                  hintText: 'Ej. Fondo de emergencia, Viaje, Laptop',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.flag_outlined),
                ),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Ingresa el nombre' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _montoObjetivoController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Monto Objetivo (Bs.) *',
                  prefixText: 'Bs. ',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.monetization_on_outlined),
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Ingresa el monto objetivo';
                  final val = double.tryParse(v);
                  if (val == null || val <= 0) return 'Ingresa un monto mayor a 0';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _aporteInicialController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Aporte Inicial (Opcional)',
                  prefixText: 'Bs. ',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.savings_outlined),
                  helperText: 'Monto con el que inicias esta meta',
                ),
              ),
              const SizedBox(height: 20),
              InkWell(
                onTap: () => _seleccionarFecha(context),
                borderRadius: BorderRadius.circular(12),
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Fecha Límite',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.calendar_today),
                  ),
                  child: Text(df.format(_fechaLimite)),
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _guardar,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppColors.radiusMd)),
                  ),
                  child: _isSaving
                      ? const CircularProgressIndicator()
                      : const Text('Guardar Meta', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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
