import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../data/presupuesto_model.dart';

class PresupuestoCard extends StatelessWidget {
  final Presupuesto presupuesto;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const PresupuestoCard({
    super.key,
    required this.presupuesto,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final gastado = presupuesto.gastado ?? 0.0;
    final limite = presupuesto.montoLimite;
    final pct = (limite > 0) ? (gastado / limite) : 0.0;
    final pctClamp = pct.clamp(0.0, 1.0);
    
    Color barColor;
    if (pct < 0.7) {
      barColor = AppColors.ingreso;
    } else if (pct < 0.9) {
      barColor = const Color(0xFFF59E0B); // Amber
    } else {
      barColor = AppColors.gasto;
    }

    final colorHex = presupuesto.categoriaColor ?? '#607D8B';
    final colorInt = int.parse(colorHex.replaceAll('#', 'FF'), radix: 16);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 12,
                  backgroundColor: Color(colorInt),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    presupuesto.categoriaNombre ?? 'Categoría',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
                if (onEdit != null || onDelete != null)
                  PopupMenuButton(
                    itemBuilder: (ctx) => [
                      if (onEdit != null)
                        const PopupMenuItem(value: 'edit', child: Text('Editar')),
                      if (onDelete != null)
                        const PopupMenuItem(value: 'delete', child: Text('Eliminar')),
                    ],
                    onSelected: (val) {
                      if (val == 'edit') onEdit?.call();
                      if (val == 'delete') onDelete?.call();
                    },
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Bs. ${gastado.toStringAsFixed(2)} / Bs. ${limite.toStringAsFixed(2)}'),
                Text(
                  '${(pct * 100).toStringAsFixed(0)}%',
                  style: TextStyle(fontWeight: FontWeight.bold, color: barColor),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: pctClamp,
                backgroundColor: AppColors.border,
                color: barColor,
                minHeight: 8,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
