import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../shared/components/app_snackbar.dart';
import '../data/cuenta_model.dart';
import '../viewmodel/cuenta_viewmodel.dart';

class CrearCuentaModal extends StatefulWidget {
  final Cuenta? cuentaAEditar;

  const CrearCuentaModal({super.key, this.cuentaAEditar});

  @override
  State<CrearCuentaModal> createState() => _CrearCuentaModalState();
}

class _CrearCuentaModalState extends State<CrearCuentaModal> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _saldoController = TextEditingController(text: '0.00');
  String _tipo = 'banco'; // 'banco', 'efectivo', 'billetera'
  String _bancoSeleccionado = 'Banco Unión';
  String _color = '#2563EB';

  final List<String> _opcionesBanco = [
    'Banco Unión',
    'Banco Nacional de Bolivia (BNB)',
    'Banco de Crédito de Bolivia (BCP)',
    'Banco Mercantil Santa Cruz',
    'Banco Bisa',
    'Banco Económico',
    'Banco Fie',
    'Yape',
    'Tigo Money',
    'Efectivo',
    'Otro'
  ];

  final List<Map<String, String>> _coloresDisponibles = [
    {'nombre': 'Azul Cobalto', 'hex': '#2563EB'},
    {'nombre': 'Índigo', 'hex': '#6366F1'},
    {'nombre': 'Esmeralda', 'hex': '#10B981'},
    {'nombre': 'Verde Menta', 'hex': '#059669'},
    {'nombre': 'Púrpura', 'hex': '#7C3AED'},
    {'nombre': 'Violeta', 'hex': '#8B5CF6'},
    {'nombre': 'Coral', 'hex': '#EF4444'},
    {'nombre': 'Naranja', 'hex': '#F97316'},
    {'nombre': 'Ámbar', 'hex': '#F59E0B'},
    {'nombre': 'Rosa', 'hex': '#EC4899'},
    {'nombre': 'Cian', 'hex': '#06B6D4'},
    {'nombre': 'Teal', 'hex': '#0D9488'},
    {'nombre': 'Slate', 'hex': '#475569'},
    {'nombre': 'Oscuro', 'hex': '#0F172A'},
  ];

  @override
  void initState() {
    super.initState();
    if (widget.cuentaAEditar != null) {
      final c = widget.cuentaAEditar!;
      _saldoController.text = c.saldoActual.toStringAsFixed(2);
      _tipo = c.tipo;
      _color = c.color ?? '#2563EB';

      if (_opcionesBanco.contains(c.nombre)) {
        _bancoSeleccionado = c.nombre;
      } else {
        _bancoSeleccionado = 'Otro';
        _nombreController.text = c.nombre;
      }
    }
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _saldoController.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    final saldo = double.tryParse(_saldoController.text) ?? 0.0;

    final nombreCuenta = _bancoSeleccionado == 'Otro'
        ? _nombreController.text.trim()
        : _bancoSeleccionado;

    final icono = _tipo == 'efectivo'
        ? 'payments'
        : (_tipo == 'billetera' ? 'account_balance_wallet' : 'account_balance');

    final cuentaVm = context.read<CuentaViewModel>();

    final nav = Navigator.of(context);

    if (widget.cuentaAEditar != null) {
      final cuentaActualizada = widget.cuentaAEditar!.copyWith(
        nombre: nombreCuenta,
        tipo: _tipo,
        saldoActual: saldo,
        color: _color,
        icono: icono,
      );
      await cuentaVm.actualizarCuenta(cuentaActualizada);
    } else {
      final nuevaCuenta = Cuenta(
        nombre: nombreCuenta,
        tipo: _tipo,
        saldoActual: saldo,
        color: _color,
        icono: icono,
      );
      await cuentaVm.agregarCuenta(nuevaCuenta);
    }

    if (!mounted || !context.mounted) {
      return;
    }
    nav.pop();
    AppSnackBar.showSuccess(
      context,
      widget.cuentaAEditar != null
          ? 'Cuenta actualizada correctamente'
          : 'Cuenta agregada correctamente',
    );
  }

  Future<void> _eliminar() async {
    if (widget.cuentaAEditar?.id == null) {
      return;
    }
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar cuenta'),
        content: Text(
          '¿Estás seguro de eliminar "${widget.cuentaAEditar!.nombre}"? Los movimientos asociados seguirán en el historial.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Eliminar', style: TextStyle(color: AppColors.gasto)),
          ),
        ],
      ),
    );

    if (confirmar == true && mounted && context.mounted) {
      final cuentaVm = context.read<CuentaViewModel>();
      final nav = Navigator.of(context);

      await cuentaVm.eliminarCuenta(widget.cuentaAEditar!.id!);
      if (!mounted || !context.mounted) {
        return;
      }
      nav.pop();
      AppSnackBar.showSuccess(context, 'Cuenta eliminada');
    }
  }

  @override
  Widget build(BuildContext context) {
    final esEdicion = widget.cuentaAEditar != null;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        top: 20,
        left: 20,
        right: 20,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    esEdicion ? 'Editar Cuenta / Banco' : 'Agregar Nueva Cuenta / Banco',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _bancoSeleccionado,
                decoration: InputDecoration(
                  labelText: 'Banco o Billetera',
                  prefixIcon: const Icon(Icons.account_balance),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppColors.radiusMd),
                  ),
                ),
                items: _opcionesBanco
                    .map((b) => DropdownMenuItem(value: b, child: Text(b)))
                    .toList(),
                onChanged: (v) {
                  if (v != null) {
                    setState(() {
                      _bancoSeleccionado = v;
                      if (v == 'Efectivo') {
                        _tipo = 'efectivo';
                      } else if (v == 'Yape' || v == 'Tigo Money') {
                        _tipo = 'billetera';
                      } else {
                        _tipo = 'banco';
                      }
                    });
                  }
                },
              ),
              if (_bancoSeleccionado == 'Otro') ...[
                const SizedBox(height: 16),
                TextFormField(
                  controller: _nombreController,
                  decoration: InputDecoration(
                    labelText: 'Nombre personalizado',
                    prefixIcon: const Icon(Icons.edit_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppColors.radiusMd),
                    ),
                  ),
                  validator: (v) {
                    if (_bancoSeleccionado == 'Otro' && (v == null || v.trim().isEmpty)) {
                      return 'Nombre requerido';
                    }
                    return null;
                  },
                ),
              ],
              const SizedBox(height: 16),
              TextFormField(
                controller: _saldoController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: esEdicion ? 'Saldo actual (Bs.)' : 'Saldo inicial (Bs.)',
                  prefixIcon: const Icon(Icons.attach_money),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppColors.radiusMd),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _tipo,
                decoration: InputDecoration(
                  labelText: 'Tipo de cuenta',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppColors.radiusMd),
                  ),
                ),
                items: const [
                  DropdownMenuItem(value: 'banco', child: Text('Banco / Tarjeta')),
                  DropdownMenuItem(value: 'efectivo', child: Text('Efectivo')),
                  DropdownMenuItem(
                    value: 'billetera',
                    child: Text('Billetera Móvil (Tigo Money/QR)'),
                  ),
                ],
                onChanged: (v) {
                  setState(() {
                    _tipo = v ?? 'banco';
                  });
                },
              ),
              const SizedBox(height: 16),
              const Text(
                'Color distintivo:',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 12,
                runSpacing: 10,
                children: _coloresDisponibles.map((c) {
                  final hex = c['hex']!;
                  final colorInt = int.parse(hex.replaceAll('#', 'FF'), radix: 16);
                  final isSelected = _color.toUpperCase() == hex.toUpperCase();

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _color = hex;
                      });
                    },
                    child: Tooltip(
                      message: c['nombre'] ?? '',
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: isSelected ? 40 : 34,
                        height: isSelected ? 40 : 34,
                        decoration: BoxDecoration(
                          color: Color(colorInt),
                          shape: BoxShape.circle,
                          border: isSelected
                              ? Border.all(
                                  color: Theme.of(context).brightness == Brightness.dark
                                      ? Colors.white
                                      : AppColors.primary,
                                  width: 3,
                                )
                              : Border.all(
                                  color: Colors.black.withValues(alpha: 0.1),
                                  width: 1,
                                ),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: Color(colorInt).withValues(alpha: 0.4),
                                    blurRadius: 8,
                                    spreadRadius: 2,
                                  ),
                                ]
                              : null,
                        ),
                        child: isSelected
                            ? const Icon(Icons.check, color: Colors.white, size: 20)
                            : null,
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  if (esEdicion) ...[
                    IconButton.filledTonal(
                      onPressed: _eliminar,
                      icon: const Icon(Icons.delete_outline, color: AppColors.gasto),
                      style: IconButton.styleFrom(
                        padding: const EdgeInsets.all(14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppColors.radiusMd),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                  ],
                  Expanded(
                    child: SizedBox(
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _guardar,
                        child: Text(
                          esEdicion ? 'Actualizar Cuenta' : 'Guardar Cuenta',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
