import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../viewmodel/presupuesto_viewmodel.dart';
import 'widgets/presupuesto_card.dart';
import 'widgets/crear_presupuesto_modal.dart';

class PresupuestosPage extends StatefulWidget {
  const PresupuestosPage({super.key});

  @override
  State<PresupuestosPage> createState() => _PresupuestosPageState();
}

class _PresupuestosPageState extends State<PresupuestosPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PresupuestoViewModel>().cargarPresupuestos();
    });
  }

  void _mostrarModalCrear([presupuestoAEditar]) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => CrearPresupuestoModal(presupuestoAEditar: presupuestoAEditar),
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<PresupuestoViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Presupuestos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _mostrarModalCrear(),
          ),
        ],
      ),
      body: vm.isLoading
          ? const Center(child: CircularProgressIndicator())
          : vm.presupuestos.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.pie_chart_outline, size: 56, color: AppColors.textMuted),
                      const SizedBox(height: 12),
                      const Text('No hay presupuestos', style: TextStyle(color: AppColors.textSecondary)),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => _mostrarModalCrear(),
                        child: const Text('Crear Presupuesto'),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: vm.presupuestos.length,
                  itemBuilder: (ctx, i) {
                    final p = vm.presupuestos[i];
                    return PresupuestoCard(
                      presupuesto: p,
                      onEdit: () => _mostrarModalCrear(p),
                      onDelete: () {
                        if (p.id != null) vm.eliminarPresupuesto(p.id!);
                      },
                    );
                  },
                ),
    );
  }
}
