import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../data/prestamo_model.dart';
import '../viewmodel/prestamo_viewmodel.dart';
import 'detalle_prestamo_page.dart';
import 'registrar_devolucion_modal.dart';

class PrestamosPage extends StatefulWidget {
  const PrestamosPage({super.key});

  @override
  State<PrestamosPage> createState() => _PrestamosPageState();
}

class _PrestamosPageState extends State<PrestamosPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {});
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PrestamoViewModel>().cargarPrestamos();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<PrestamoViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Préstamos'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Theme.of(context).colorScheme.primary,
          labelColor: Theme.of(context).colorScheme.primary,
          unselectedLabelColor: Theme.of(context).textTheme.bodySmall?.color ?? AppColors.textSecondary,
          tabs: [
            Tab(text: 'Me Deben (Bs. ${vm.totalMeDeben.toStringAsFixed(2)})'),
            Tab(text: 'Debo (Bs. ${vm.totalDebo.toStringAsFixed(2)})'),
          ],
        ),
      ),
      body: vm.isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildLista(vm.prestadosPorMi, esPrestado: true),
                _buildLista(vm.recibidosDeOtros, esPrestado: false),
              ],
            ),
    );
  }

  Widget _buildLista(List<Prestamo> lista, {required bool esPrestado}) {
    if (lista.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              esPrestado ? Icons.account_balance_wallet_outlined : Icons.money_off_outlined,
              size: 56,
              color: AppColors.textMuted,
            ),
            const SizedBox(height: 12),
            Text(
              esPrestado ? 'No has prestado dinero a nadie aún' : 'No tienes deudas pendientes registradas',
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: lista.length,
      itemBuilder: (ctx, i) {
        final p = lista[i];
        final pagado = (p.monto - p.remainingAmount).clamp(0.0, double.infinity);
        final pct = p.monto > 0 ? (pagado / p.monto).clamp(0.0, 1.0) : 0.0;
        final esSaldado = p.status == 'settled';

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () {
              if (p.id != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => DetallePrestamoPage(prestamoId: p.id!)),
                );
              }
            },
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        p.nombrePersona,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: esSaldado ? AppColors.ingreso.withValues(alpha: 0.15) : Colors.orange.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          esSaldado ? 'Saldado' : 'Pendiente',
                          style: TextStyle(
                            color: esSaldado ? AppColors.ingreso : Colors.orange.shade800,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Pendiente: Bs. ${p.remainingAmount.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: esPrestado ? AppColors.prestamo : AppColors.gasto,
                              )),
                          Text('Total inicial: Bs. ${p.monto.toStringAsFixed(2)}',
                              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                        ],
                      ),
                      if (!esSaldado)
                        IconButton(
                          icon: const Icon(Icons.price_check, color: AppColors.accent),
                          tooltip: 'Registrar Devolución',
                          onPressed: () {
                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                              ),
                              builder: (_) => RegistrarDevolucionModal(prestamo: p),
                            );
                          },
                        ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: pct,
                      minHeight: 6,
                      backgroundColor: AppColors.border,
                      color: esSaldado ? AppColors.ingreso : AppColors.accent,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
