import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../cuentas/data/cuenta_model.dart';
import '../../cuentas/viewmodel/cuenta_viewmodel.dart';
import '../data/prestamo_model.dart';
import '../viewmodel/prestamo_viewmodel.dart';
import 'registrar_devolucion_modal.dart';

class DetallePrestamoPage extends StatelessWidget {
  final int prestamoId;

  const DetallePrestamoPage({super.key, required this.prestamoId});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<PrestamoViewModel>();
    final cuentas = context.watch<CuentaViewModel>().cuentas;

    final prestamo = vm.prestamos.firstWhere(
      (p) => p.id == prestamoId,
      orElse: () => Prestamo(
        tipo: 'prestado',
        nombrePersona: 'Desconocido',
        monto: 0,
      ),
    );

    final devoluciones = vm.getDevolucionesForLoan(prestamoId);
    final esPrestado = prestamo.tipo == 'prestado';
    final pagado = (prestamo.monto - prestamo.remainingAmount).clamp(0.0, double.infinity);
    final porcentaje = prestamo.monto > 0 ? (pagado / prestamo.monto).clamp(0.0, 1.0) : 0.0;

    final df = DateFormat('dd/MM/yyyy - HH:mm');

    return Scaffold(
      appBar: AppBar(
        title: Text(prestamo.nombrePersona),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline, color: AppColors.gasto),
            onPressed: () async {
              final ok = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Eliminar Préstamo'),
                  content: const Text('¿Estás seguro de borrar este registro y su historial de devoluciones?'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
                    TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Eliminar', style: TextStyle(color: AppColors.gasto))),
                  ],
                ),
              );
              if (ok == true && context.mounted) {
                final nav = Navigator.of(context);
                final cuentaVm = context.read<CuentaViewModel>();
                await vm.eliminarPrestamo(prestamoId);
                await cuentaVm.cargarCuentas();
                nav.pop();
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tarjeta Resumen Principal
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: const BorderSide(color: AppColors.border),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: (esPrestado ? AppColors.prestamo : AppColors.gasto).withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            esPrestado ? 'Prestado por mí (Me deben)' : 'Pedí prestado (Yo debo)',
                            style: TextStyle(
                              color: esPrestado ? AppColors.prestamo : AppColors.gasto,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: prestamo.status == 'settled' ? AppColors.ingreso.withValues(alpha: 0.15) : Colors.orange.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            prestamo.status == 'settled' ? 'Saldado' : 'Pendiente',
                            style: TextStyle(
                              color: prestamo.status == 'settled' ? AppColors.ingreso : Colors.orange.shade800,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Bs. ${prestamo.remainingAmount.toStringAsFixed(2)}',
                      style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                    ),
                    const Text('Saldo Restante Pendiente', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                    const SizedBox(height: 16),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: porcentaje,
                        minHeight: 10,
                        backgroundColor: AppColors.border,
                        color: prestamo.status == 'settled' ? AppColors.ingreso : AppColors.accent,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Total inicial: Bs. ${prestamo.monto.toStringAsFixed(2)}', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                        Text('Devuelto: Bs. ${pagado.toStringAsFixed(2)} (${(porcentaje * 100).toStringAsFixed(0)}%)', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Botón rápido de acción
            if (prestamo.status != 'settled')
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                      ),
                      builder: (_) => RegistrarDevolucionModal(prestamo: prestamo),
                    );
                  },
                  icon: const Icon(Icons.add_circle_outline),
                  label: Text(esPrestado ? 'Registrar Cobro / Devolución' : 'Registrar Abono / Pago'),
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                ),
              ),

            const SizedBox(height: 24),
            const Text('Historial de Devoluciones y Abonos', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),

            if (devoluciones.isEmpty)
              Container(
                padding: const EdgeInsets.all(24),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Theme.of(context).brightness == Brightness.dark ? Colors.transparent : AppColors.border),
                ),
                child: const Column(
                  children: [
                    Icon(Icons.history, size: 40, color: AppColors.textMuted),
                    SizedBox(height: 8),
                    Text('Sin devoluciones ni abonos registrados aún', style: TextStyle(color: AppColors.textSecondary)),
                  ],
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: devoluciones.length,
                itemBuilder: (ctx, i) {
                  final dev = devoluciones[i];
                  final cuenta = cuentas.firstWhere(
                    (c) => c.id == dev.accountId,
                    orElse: () => Cuenta(nombre: 'General', tipo: 'efectivo', saldoActual: 0),
                  );

                  return Card(
                    margin: const EdgeInsets.only(bottom: 10),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: AppColors.ingreso.withValues(alpha: 0.15),
                        child: const Icon(Icons.arrow_downward, color: AppColors.ingreso, size: 20),
                      ),
                      title: Text('Bs. ${dev.monto.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text('${df.format(dev.fecha)} • Cuenta: ${cuenta.nombre}\n${dev.notas ?? ''}'),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}
