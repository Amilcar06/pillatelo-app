import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../viewmodel/recurrente_viewmodel.dart';

class RecurrentesPage extends StatefulWidget {
  const RecurrentesPage({super.key});

  @override
  State<RecurrentesPage> createState() => _RecurrentesPageState();
}

class _RecurrentesPageState extends State<RecurrentesPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RecurrenteViewModel>().cargarRecurrentes();
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<RecurrenteViewModel>();
    final df = DateFormat('dd/MM/yyyy');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Movimientos Recurrentes'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => Navigator.pushNamed(context, '/recurrentes/registrar'),
          ),
        ],
      ),
      body: vm.isLoading
          ? const Center(child: CircularProgressIndicator())
          : vm.recurrentes.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.autorenew, size: 56, color: AppColors.textMuted),
                      const SizedBox(height: 12),
                      const Text('No hay pagos recurrentes', style: TextStyle(color: AppColors.textSecondary)),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => Navigator.pushNamed(context, '/recurrentes/registrar'),
                        child: const Text('Agregar Recurrente'),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: vm.recurrentes.length,
                  itemBuilder: (ctx, i) {
                    final r = vm.recurrentes[i];
                    final esIngreso = r.tipo == 'ingreso';

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: (esIngreso ? AppColors.ingreso : AppColors.gasto).withValues(alpha: 0.12),
                          child: Icon(
                            esIngreso ? Icons.arrow_downward : Icons.arrow_upward,
                            color: esIngreso ? AppColors.ingreso : AppColors.gasto,
                            size: 20,
                          ),
                        ),
                        title: Text(r.descripcion, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text('Frecuencia: ${r.frecuencia}\nInicio: ${df.format(r.fechaInicio)}'),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '${esIngreso ? '+' : '-'} Bs. ${r.monto.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                color: esIngreso ? AppColors.ingreso : AppColors.textPrimary,
                              ),
                            ),
                            Switch(
                              value: r.activo,
                              onChanged: (val) {
                                vm.guardarRecurrente(r.copyWith(activo: val));
                              },
                            )
                          ],
                        ),
                        isThreeLine: true,
                      ),
                    );
                  },
                ),
    );
  }
}
