import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../data/meta_model.dart';
import '../viewmodel/meta_viewmodel.dart';

class DetalleMetaPage extends StatefulWidget {
  final Meta meta;

  const DetalleMetaPage({super.key, required this.meta});

  @override
  State<DetalleMetaPage> createState() => _DetalleMetaPageState();
}

class _DetalleMetaPageState extends State<DetalleMetaPage> {
  final _montoController = TextEditingController();
  final df = DateFormat('dd MMM yyyy');

  @override
  void dispose() {
    _montoController.dispose();
    super.dispose();
  }

  void _mostrarDialogoAporte(BuildContext context, Meta metaActual) {
    _montoController.clear();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Agregar Aporte'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'El monto aportado se descontará de tu saldo de efectivo.',
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _montoController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Monto (Bs.)',
                prefixText: 'Bs. ',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              final monto = double.tryParse(_montoController.text);
              if (monto == null || monto <= 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Ingresa un monto válido')),
                );
                return;
              }

              final contrib = Contribution(
                goalId: metaActual.id!,
                monto: monto,
                fecha: DateTime.now(),
              );

              final metaVm = context.read<MetaViewModel>();
              final messenger = ScaffoldMessenger.of(context);
              final nav = Navigator.of(ctx);
              await metaVm.agregarAporte(contrib, metaActual);
              nav.pop();
              messenger.showSnackBar(
                const SnackBar(content: Text('Aporte registrado correctamente')),
              );
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final metaVm = context.watch<MetaViewModel>();
    // Find updated meta object from viewmodel list
    final meta = metaVm.metas.firstWhere(
      (m) => m.id == widget.meta.id,
      orElse: () => widget.meta,
    );

    final porcentaje = meta.targetAmount > 0
        ? (meta.currentAmount / meta.targetAmount).clamp(0.0, 1.0)
        : 0.0;
    final esCompletada = meta.estado == 'completada' || porcentaje >= 1.0;
    final aportes = meta.id != null ? metaVm.getContributionsForGoal(meta.id!) : <Contribution>[];

    return Scaffold(
      appBar: AppBar(
        title: Text(meta.nombre),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline, color: AppColors.gasto),
            onPressed: () async {
              final nav = Navigator.of(context);
              final confirm = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('¿Eliminar meta?'),
                  content: const Text('Esta acción eliminará la meta y su historial de aportes.'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      child: const Text('Eliminar', style: TextStyle(color: AppColors.gasto)),
                    ),
                  ],
                ),
              );

              if (confirm == true && meta.id != null) {
                await metaVm.eliminarMeta(meta.id!);
                nav.pop();
              }
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
            // CARD DE PROGRESO PRINCIPAL
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        esCompletada ? '¡META ALCANZADA! 🎉' : 'EN PROGRESO',
                        style: TextStyle(
                          color: esCompletada ? AppColors.ingreso : AppColors.accent,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.1,
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        '${(porcentaje * 100).toStringAsFixed(1)}%',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: porcentaje,
                      minHeight: 12,
                      backgroundColor: Colors.white12,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        esCompletada ? AppColors.ingreso : AppColors.accent,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Actual', style: TextStyle(color: Colors.white60, fontSize: 12)),
                          Text(
                            'Bs. ${meta.currentAmount.toStringAsFixed(2)}',
                            style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text('Objetivo', style: TextStyle(color: Colors.white60, fontSize: 12)),
                          Text(
                            'Bs. ${meta.targetAmount.toStringAsFixed(2)}',
                            style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Icon(Icons.calendar_today, size: 14, color: Colors.white60),
                      const SizedBox(width: 6),
                      Text(
                        'Fecha límite: ${df.format(meta.fechaLimite)}',
                        style: const TextStyle(color: Colors.white70, fontSize: 13),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // BOTONES DE ACCIÓN
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: esCompletada ? null : () => _mostrarDialogoAporte(context, meta),
                    icon: const Icon(Icons.add),
                    label: const Text('Añadir Aporte'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                ),
                if (!esCompletada) ...[
                  const SizedBox(width: 12),
                  OutlinedButton.icon(
                    onPressed: () async {
                      final messenger = ScaffoldMessenger.of(context);
                      await metaVm.marcarCompletada(meta);
                      messenger.showSnackBar(
                        const SnackBar(content: Text('Meta marcada como completada 🎉')),
                      );
                    },
                    icon: const Icon(Icons.check_circle_outline, color: AppColors.ingreso),
                    label: const Text('Completar'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                ],
              ],
            ),

            const SizedBox(height: 28),

            // HISTORIAL DE APORTES
            const Text(
              'Historial de Aportes',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            if (aportes.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                ),
                child: const Column(
                  children: [
                    Icon(Icons.savings_outlined, size: 40, color: AppColors.textMuted),
                    SizedBox(height: 8),
                    Text('Aún no realizaste ningún aporte a esta meta', style: TextStyle(color: AppColors.textSecondary)),
                  ],
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: aportes.length,
                itemBuilder: (ctx, i) {
                  final contrib = aportes[i];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: const CircleAvatar(
                        backgroundColor: Color(0x1F10B981),
                        child: Icon(Icons.arrow_upward, color: AppColors.ingreso, size: 20),
                      ),
                      title: Text(
                        'Bs. ${contrib.monto.toStringAsFixed(2)}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(df.format(contrib.fecha)),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
      if (esCompletada)
        Positioned.fill(
          child: IgnorePointer(
            child: Lottie.network(
              'https://assets9.lottiefiles.com/packages/lf20_u4yrau.json',
              repeat: false,
              errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
            ),
          ),
        ),
    ],
  ),
);
  }
}
