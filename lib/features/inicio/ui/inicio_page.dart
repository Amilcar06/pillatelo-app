import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../cuentas/ui/crear_cuenta_modal.dart';
import '../../cuentas/viewmodel/cuenta_viewmodel.dart';
import '../../movimientos/viewmodel/movimiento_viewmodel.dart';
import '../../prestamos/viewmodel/prestamo_viewmodel.dart';
import '../../../core/providers/privacy_provider.dart';


class InicioPage extends StatefulWidget {
  const InicioPage({super.key});

  @override
  State<InicioPage> createState() => _InicioPageState();
}

class _InicioPageState extends State<InicioPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CuentaViewModel>().cargarCuentas();
      context.read<MovimientoViewModel>().cargarMovimientos();
      context.read<PrestamoViewModel>().cargarPrestamos();
    });
  }

  @override
  Widget build(BuildContext context) {
    final cuentaVm = context.watch<CuentaViewModel>();
    final movVm = context.watch<MovimientoViewModel>();
    final prestamoVm = context.watch<PrestamoViewModel>();

    final privacy = context.watch<PrivacyProvider>();
    final df = DateFormat('dd MMM, yyyy');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Dinero Al Día'),
        actions: [
          IconButton(
            icon: Icon(privacy.isPrivate ? Icons.visibility_off : Icons.visibility),
            onPressed: () => privacy.toggle(),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await cuentaVm.cargarCuentas();
          await movVm.cargarMovimientos();
          await prestamoVm.cargarPrestamos();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- HERO CARD: SALDO TOTAL UNIFICADO ---
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.12),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            'SALDO TOTAL UNIFICADO',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: AppColors.textMuted,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${cuentaVm.cuentas.length} Cuentas',
                            style: const TextStyle(color: Colors.white70, fontSize: 11),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    TweenAnimationBuilder<double>(
                      tween: Tween<double>(begin: 0, end: cuentaVm.saldoTotalUnificado),
                      duration: const Duration(milliseconds: 800),
                      curve: Curves.easeOutCubic,
                      builder: (context, value, child) {
                        return Text(
                          privacy.isPrivate ? 'Bs. ••••••' : 'Bs. ${value.toStringAsFixed(2)}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 34,
                            fontWeight: FontWeight.bold,
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: _buildResumenChip(
                            'Ingresos (Mes)',
                            privacy.isPrivate ? 'Bs. ••••' : 'Bs. ${movVm.totalIngresosMesActual.toStringAsFixed(2)}',
                            AppColors.ingreso,
                            Icons.arrow_downward,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildResumenChip(
                            'Gastos (Mes)',
                            privacy.isPrivate ? 'Bs. ••••' : 'Bs. ${movVm.totalGastosMesActual.toStringAsFixed(2)}',
                            AppColors.gasto,
                            Icons.arrow_upward,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // --- SECCIÓN MIS BANCOS / CUENTAS ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Mis Bancos y Cuentas', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  TextButton.icon(
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                        ),
                        builder: (_) => const CrearCuentaModal(),
                      );
                    },
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Agregar'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (cuentaVm.cuentas.isEmpty)
                const Text('Sin cuentas registradas aún')
              else
                SizedBox(
                  height: 94,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: cuentaVm.cuentas.length,
                    itemBuilder: (ctx, i) {
                      final c = cuentaVm.cuentas[i];
                      final colorHex = c.color ?? '#2196F3';
                      final colorInt = int.parse(colorHex.replaceAll('#', 'FF'), radix: 16);
                      final baseColor = Color(colorInt);

                      // Tipo legible
                      String tipoLabel;
                      IconData tipoIcon;
                      if (c.tipo == 'efectivo') {
                        tipoLabel = 'Efectivo';
                        tipoIcon = Icons.payments_outlined;
                      } else if (c.tipo == 'billetera') {
                        tipoLabel = 'Billetera';
                        tipoIcon = Icons.account_balance_wallet_outlined;
                      } else {
                        tipoLabel = 'Banco';
                        tipoIcon = Icons.account_balance_outlined;
                      }

                      return Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(AppColors.radiusMd),
                          onTap: () {
                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                              ),
                              builder: (_) => CrearCuentaModal(cuentaAEditar: c),
                            );
                          },
                          child: Container(
                            width: 170,
                            margin: const EdgeInsets.only(right: 12),
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  baseColor,
                                  baseColor.withValues(alpha: 0.75),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(AppColors.radiusMd),
                              boxShadow: [
                                BoxShadow(
                                  color: baseColor.withValues(alpha: 0.3),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        c.nombre,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ),
                                    Icon(tipoIcon, color: Colors.white70, size: 16),
                                  ],
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      tipoLabel,
                                      style: const TextStyle(
                                        color: Colors.white60,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      privacy.isPrivate ? 'Bs. ••••' : 'Bs. ${c.saldoActual.toStringAsFixed(2)}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

              const SizedBox(height: 24),

              // SECCIÓN PRÉSTAMOS REMOVIDA (Ahora en MÁS)

              // --- SECCIÓN ÚLTIMOS MOVIMIENTOS ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Últimos Movimientos', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  if (movVm.movimientos.isNotEmpty)
                    TextButton(
                      onPressed: () => Navigator.pushNamed(context, '/movimientos'),
                      child: const Text('Ver todos'),
                    ),
                ],
              ),
              const SizedBox(height: 8),

              if (movVm.movimientos.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Theme.of(context).brightness == Brightness.dark ? Colors.transparent : AppColors.border),
                  ),
                  child: const Column(
                    children: [
                      Icon(Icons.receipt_long_outlined, size: 48, color: AppColors.textMuted),
                      SizedBox(height: 12),
                      Text('No hay movimientos registrados hoy', style: TextStyle(color: AppColors.textSecondary)),
                    ],
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: movVm.movimientos.length.clamp(0, 6),
                  itemBuilder: (ctx, i) {
                    final m = movVm.movimientos[i];
                    final esIngreso = m.tipo == 'ingreso';

                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: (esIngreso ? AppColors.ingreso : AppColors.gasto).withValues(alpha: 0.12),
                          child: Icon(
                            esIngreso ? Icons.arrow_downward : Icons.arrow_upward,
                            color: esIngreso ? AppColors.ingreso : AppColors.gasto,
                            size: 20,
                          ),
                        ),
                        title: Text(m.descripcion, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(df.format(m.fecha)),
                        trailing: Text(
                          privacy.isPrivate 
                            ? 'Bs. ••••' 
                            : '${esIngreso ? '+' : '-'} Bs. ${m.monto.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: esIngreso ? AppColors.ingreso : Theme.of(context).textTheme.bodyLarge?.color,
                          ),
                        ),
                      ),
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResumenChip(String label, String value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 12,
            backgroundColor: color.withValues(alpha: 0.2),
            child: Icon(icon, size: 14, color: color),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(color: Colors.white60, fontSize: 10)),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
