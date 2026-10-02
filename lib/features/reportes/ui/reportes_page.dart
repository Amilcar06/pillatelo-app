import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../viewmodel/reporte_viewmodel.dart';
import '../widgets/grafico_balance.dart';
import 'detalle_reporte_page.dart';
import '../../../shared/services/export_service.dart';

class ReportesPage extends StatefulWidget {
  const ReportesPage({super.key});

  @override
  State<ReportesPage> createState() => _ReportesPageState();
}

class _ReportesPageState extends State<ReportesPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ReporteViewModel>().cargarReporte();
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ReporteViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reportes'),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.download),
            onSelected: (val) {
              if (val == 'csv') {
                ExportService.exportToCSV(vm.movimientosPeriodo, context);
              } else if (val == 'pdf') {
                ExportService.exportToPDF(vm, context);
              }
            },
            itemBuilder: (ctx) => const [
              PopupMenuItem(value: 'csv', child: Text('Exportar a CSV')),
              PopupMenuItem(value: 'pdf', child: Text('Exportar a PDF')),
            ],
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => vm.cargarReporte(),
        child: vm.isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // SELECTOR DE RANGO
                    SegmentedButton<String>(
                      segments: const [
                        ButtonSegment(value: 'semana', label: Text('Semana')),
                        ButtonSegment(value: 'mes', label: Text('Mes')),
                        ButtonSegment(value: 'ano', label: Text('Año')),
                      ],
                      selected: {vm.rangoSeleccionado},
                      onSelectionChanged: (val) {
                        vm.cambiarRango(val.first);
                      },
                    ),
                    const SizedBox(height: 24),

                    // MÉTRICAS CLAVE
                    Row(
                      children: [
                        Expanded(
                          child: _buildMetricCard(
                            'Ingresos',
                            'Bs. ${vm.totalIngresos.toStringAsFixed(2)}',
                            AppColors.ingreso,
                            Icons.arrow_downward,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildMetricCard(
                            'Gastos',
                            'Bs. ${vm.totalEgresos.toStringAsFixed(2)}',
                            AppColors.gasto,
                            Icons.arrow_upward,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildMetricCard(
                      'Balance Neto',
                      'Bs. ${vm.balanceNeto.toStringAsFixed(2)}',
                      vm.balanceNeto >= 0 ? AppColors.ingreso : AppColors.gasto,
                      Icons.account_balance_wallet_outlined,
                    ),

                    const SizedBox(height: 28),

                    // GRÁFICO
                    const Text('Comparativa de Balance', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: GraficoBalance(
                        ingresos: vm.totalIngresos,
                        egresos: vm.totalEgresos,
                      ),
                    ),

                    const SizedBox(height: 24),

                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const DetalleReportePage()),
                          );
                        },
                        icon: const Icon(Icons.list_alt),
                        label: const Text('Ver Desglose de Movimientos'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildMetricCard(String label, String value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: color.withValues(alpha: 0.12),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
