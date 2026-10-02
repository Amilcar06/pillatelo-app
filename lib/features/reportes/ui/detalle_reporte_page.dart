import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../viewmodel/reporte_viewmodel.dart';

class DetalleReportePage extends StatelessWidget {
  const DetalleReportePage({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ReporteViewModel>();
    final df = DateFormat('dd MMM yyyy');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Desglose de Reporte'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Movimientos del Período',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            if (vm.movimientosPeriodo.isEmpty)
              const Center(child: Text('Sin movimientos registrados en este período'))
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: vm.movimientosPeriodo.length,
                itemBuilder: (ctx, i) {
                  final m = vm.movimientosPeriodo[i];
                  final esIngreso = m.tipo == 'ingreso';

                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: (esIngreso ? AppColors.ingreso : AppColors.gasto).withValues(alpha: 0.12),
                        child: Icon(
                          esIngreso ? Icons.arrow_downward : Icons.arrow_upward,
                          color: esIngreso ? AppColors.ingreso : AppColors.gasto,
                        ),
                      ),
                      title: Text(m.descripcion, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(df.format(m.fecha)),
                      trailing: Text(
                        '${esIngreso ? '+' : '-'} Bs. ${m.monto.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: esIngreso ? AppColors.ingreso : AppColors.gasto,
                        ),
                      ),
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
