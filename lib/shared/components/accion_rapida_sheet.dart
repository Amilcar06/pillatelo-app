import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../features/cuentas/ui/crear_cuenta_modal.dart';
import '../../features/metas/ui/registrar_meta_page.dart';
import '../../features/movimientos/ui/registrar_movimiento_page.dart';
import '../../features/prestamos/ui/registrar_prestamo_page.dart';

import 'package:flutter_animate/flutter_animate.dart';

class AccionRapidaSheet extends StatelessWidget {
  const AccionRapidaSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).padding.bottom + 16,
        top: 24,
        left: 24,
        right: 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Nuevo Registro',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ).animate().fadeIn(duration: 200.ms),
          const SizedBox(height: 24),
          _buildOption(
            context,
            icon: Icons.receipt_long_outlined,
            color: AppColors.accent,
            title: 'Movimiento',
            subtitle: 'Ingreso o Gasto regular',
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (_) => const RegistrarMovimientoPage()));
            },
          ).animate().slideY(begin: 0.2, end: 0, duration: 300.ms, curve: Curves.easeOutCubic).fadeIn(duration: 250.ms),
          const SizedBox(height: 12),
          _buildOption(
            context,
            icon: Icons.handshake_outlined,
            color: AppColors.prestamo,
            title: 'Préstamo o Deuda',
            subtitle: 'Dinero prestado o recibido',
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (_) => const RegistrarPrestamoPage()));
            },
          ).animate(delay: 50.ms).slideY(begin: 0.2, end: 0, duration: 300.ms, curve: Curves.easeOutCubic).fadeIn(duration: 250.ms),
          const SizedBox(height: 12),
          _buildOption(
            context,
            icon: Icons.flag_outlined,
            color: AppColors.ingreso,
            title: 'Meta Financiera',
            subtitle: 'Nuevo objetivo de ahorro',
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (_) => const RegistrarMetaPage()));
            },
          ).animate(delay: 100.ms).slideY(begin: 0.2, end: 0, duration: 300.ms, curve: Curves.easeOutCubic).fadeIn(duration: 250.ms),
          const SizedBox(height: 12),
          _buildOption(
            context,
            icon: Icons.account_balance_wallet_outlined,
            color: AppColors.banco,
            title: 'Cuenta / Banco',
            subtitle: 'Agregar origen de fondos',
            onTap: () {
              Navigator.pop(context);
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                ),
                builder: (_) => const CrearCuentaModal(),
              );
            },
          ).animate(delay: 150.ms).slideY(begin: 0.2, end: 0, duration: 300.ms, curve: Curves.easeOutCubic).fadeIn(duration: 250.ms),
        ],
      ),
    );
  }

  Widget _buildOption(
    BuildContext context, {
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 0,
      color: Theme.of(context).cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: AppColors.border.withValues(alpha: 0.5)),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 4),
                    Text(subtitle, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: AppColors.textMuted),
            ],
          ),
        ),
      ),
    );
  }
}
