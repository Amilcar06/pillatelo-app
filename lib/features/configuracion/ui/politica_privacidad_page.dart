import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class PoliticaPrivacidadPage extends StatelessWidget {
  const PoliticaPrivacidadPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Política de Privacidad'),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        children: [
          // Banner destacado
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDark ? AppColors.primaryLight : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.accent.withValues(alpha: 0.25),
                width: 1.5,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.accent.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.shield_outlined,
                    color: AppColors.accent,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '100% Offline y Privado',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Tus datos financieros residen exclusivamente en tu teléfono. Nunca se comparten ni se suben a la nube.',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          _buildSection(
            icon: Icons.storage_outlined,
            title: '1. Almacenamiento Exclusivamente Local',
            content:
                'Pillatelo funciona bajo el principio de "Local-First". Todos los registros de transacciones, saldos, cuentas bancarias, deudas, préstamos, metas de ahorro y presupuestos se guardan en una base de datos local SQLite dentro del espacio aislado (sandbox) de tu teléfono. Ninguna información financiera se transmite a servidores externos.',
            isDark: isDark,
          ),
          const SizedBox(height: 16),

          _buildSection(
            icon: Icons.person_off_outlined,
            title: '2. Sin Creación de Cuentas ni Rastreo',
            content:
                'No solicitamos registros, nombres de usuario ni contraseñas externas. La aplicación no recopila identificadores de publicidad (Advertising ID), no incluye rastreadores de terceros ni comparte información con redes comerciales.',
            isDark: isDark,
          ),
          const SizedBox(height: 16),

          _buildSection(
            icon: Icons.lock_outline,
            title: '3. Seguridad y Protección por PIN',
            content:
                'Pillatelo ofrece un mecanismo de protección por código PIN local. Dicho código se cifra y valida únicamente dentro de tu dispositivo para prevenir el acceso físico no autorizado por otras personas.',
            isDark: isDark,
          ),
          const SizedBox(height: 16),

          _buildSection(
            icon: Icons.share_outlined,
            title: '4. Exportación y Permisos',
            content:
                'La exportación a formato PDF o CSV es iniciada únicamente por ti mediante el menú de exportación. El archivo generado se procesa en el dispositivo y se comparte mediante el gestor nativo de Android con las aplicaciones que tú decidas. La aplicación puede solicitar permisos para notificaciones locales únicamente para recordatorios de vencimiento de préstamos o metas.',
            isDark: isDark,
          ),
          const SizedBox(height: 16),

          _buildSection(
            icon: Icons.delete_outline,
            title: '5. Control Total y Eliminación de Datos',
            content:
                'Tú tienes el control absoluto de tus finanzas. Si deseas eliminar todos los datos almacenados, puedes borrar la información de la aplicación desde los Ajustes del sistema de tu dispositivo o simplemente desinstalar la app. Al hacerlo, toda la información se elimina permanentemente sin dejar copias en la nube.',
            isDark: isDark,
          ),
          const SizedBox(height: 16),

          _buildSection(
            icon: Icons.contact_support_outlined,
            title: '6. Contacto y Consultas',
            content:
                'Si tienes dudas, sugerencias o inquietudes respecto a esta política de privacidad o al funcionamiento de Pillatelo, puedes comunicarte con el equipo de soporte.',
            isDark: isDark,
          ),
          const SizedBox(height: 24),

          Center(
            child: Text(
              'Última actualización: Octubre 2026\nPillatelo — Finanzas y Gastos',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: isDark ? AppColors.textMuted : Colors.grey.shade600,
                height: 1.4,
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildSection({
    required IconData icon,
    required String title,
    required String content,
    required bool isDark,
  }) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.06),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 20, color: AppColors.accent),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              content,
              style: const TextStyle(
                fontSize: 13.5,
                height: 1.45,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
