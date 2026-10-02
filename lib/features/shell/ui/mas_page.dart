import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class MasPage extends StatelessWidget {
  const MasPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Más Opciones'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text('Finanzas', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Card(
            child: Column(
              children: [
                _buildListTile(
                  context,
                  icon: Icons.flag_outlined,
                  color: AppColors.ingreso,
                  title: 'Metas Financieras',
                  subtitle: 'Tus objetivos de ahorro',
                  route: '/metas',
                ),
                const Divider(height: 1),
                _buildListTile(
                  context,
                  icon: Icons.bar_chart_outlined,
                  color: AppColors.banco,
                  title: 'Reportes y Análisis',
                  subtitle: 'Gráficos y estadísticas',
                  route: '/reportes',
                ),
                const Divider(height: 1),
                _buildListTile(
                  context,
                  icon: Icons.pie_chart_outline,
                  color: AppColors.accent,
                  title: 'Presupuestos por Categoría',
                  subtitle: 'Controla tus límites de gasto',
                  route: '/presupuestos',
                ),
                const Divider(height: 1),
                _buildListTile(
                  context,
                  icon: Icons.autorenew,
                  color: const Color(0xFFF59E0B),
                  title: 'Movimientos Recurrentes',
                  subtitle: 'Suscripciones y pagos fijos',
                  route: '/recurrentes',
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text('Configuración', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Card(
            child: Column(
              children: [
                _buildListTile(
                  context,
                  icon: Icons.settings_outlined,
                  color: AppColors.textSecondary,
                  title: 'Configuración General',
                  subtitle: 'Categorías, PIN, Tema',
                  route: '/configuracion',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListTile(
    BuildContext context, {
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required String route,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.15),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
      trailing: const Icon(Icons.chevron_right, size: 20),
      onTap: () => Navigator.pushNamed(context, route),
    );
  }
}
