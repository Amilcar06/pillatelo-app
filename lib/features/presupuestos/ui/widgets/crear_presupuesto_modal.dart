import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../data/database/database_helper.dart';
import '../../data/presupuesto_model.dart';
import '../../viewmodel/presupuesto_viewmodel.dart';

class CrearPresupuestoModal extends StatefulWidget {
  final Presupuesto? presupuestoAEditar;

  const CrearPresupuestoModal({super.key, this.presupuestoAEditar});

  @override
  State<CrearPresupuestoModal> createState() => _CrearPresupuestoModalState();
}

class _CrearPresupuestoModalState extends State<CrearPresupuestoModal> {
  final _formKey = GlobalKey<FormState>();
  final _montoCtrl = TextEditingController();
  int? _categoriaId;
  List<Map<String, dynamic>> _categorias = [];

  @override
  void initState() {
    super.initState();
    _loadCategorias();
    if (widget.presupuestoAEditar != null) {
      _montoCtrl.text = widget.presupuestoAEditar!.montoLimite.toString();
      _categoriaId = widget.presupuestoAEditar!.categoriaId;
    }
  }

  Future<void> _loadCategorias() async {
    final db = await DatabaseHelper.instance.database;
    final List<Map<String, dynamic>> maps = await db.query('categories', where: 'tipo = ?', whereArgs: ['gasto']);
    if (mounted) {
      setState(() {
        _categorias = maps;
        if (_categoriaId == null && _categorias.isNotEmpty) {
          _categoriaId = _categorias.first['id'] as int;
        }
      });
    }
  }

  @override
  void dispose() {
    _montoCtrl.dispose();
    super.dispose();
  }

  void _guardar() {
    if (!_formKey.currentState!.validate()) return;
    if (_categoriaId == null) return;

    final monto = double.tryParse(_montoCtrl.text.trim()) ?? 0.0;
    final p = Presupuesto(
      id: widget.presupuestoAEditar?.id,
      categoriaId: _categoriaId!,
      montoLimite: monto,
    );

    context.read<PresupuestoViewModel>().guardarPresupuesto(p);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.presupuestoAEditar != null;
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 20,
        right: 20,
        top: 24,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              isEditing ? 'Editar Presupuesto' : 'Nuevo Presupuesto',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            DropdownButtonFormField<int>(
              value: _categoriaId,
              decoration: InputDecoration(
                labelText: 'Categoría de Gasto',
                prefixIcon: const Icon(Icons.category_outlined),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
              ),
              items: _categorias.map((c) {
                return DropdownMenuItem<int>(
                  value: c['id'] as int,
                  child: Text(c['nombre'] as String),
                );
              }).toList(),
              onChanged: isEditing ? null : (v) => setState(() => _categoriaId = v), // No cambiar categoría si se edita
              validator: (v) => v == null ? 'Seleccione una categoría' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _montoCtrl,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: 'Límite Mensual (Bs.)',
                prefixIcon: const Icon(Icons.attach_money),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Requerido';
                if (double.tryParse(v.trim()) == null) return 'Inválido';
                return null;
              },
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _guardar,
                child: const Text('Guardar', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
