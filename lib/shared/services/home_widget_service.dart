import 'package:home_widget/home_widget.dart';

/// Servicio para actualizar el widget nativo de la pantalla de inicio
/// de Android con datos del saldo y último registro.
class HomeWidgetService {
  /// Nombre del grupo de widgets (debe coincidir con el
  /// AppWidgetProvider registrado en AndroidManifest.xml).
  static const _androidWidgetName = 'FinanceHomeWidgetProvider';

  /// Inicializa el servicio de Home Widget.
  static Future<void> init() async {
    await HomeWidget.setAppGroupId('com.example.app_gestion_financiera_personal');
  }

  /// Actualiza el widget nativo con el saldo total y una
  /// descripción del último movimiento registrado.
  static Future<void> actualizarWidget({
    required double saldoTotal,
    required String ultimoRegistro,
  }) async {
    await HomeWidget.saveWidgetData<String>(
      'saldo_total',
      saldoTotal.toStringAsFixed(2),
    );
    await HomeWidget.saveWidgetData<String>(
      'ultimo_registro',
      ultimoRegistro,
    );
    await HomeWidget.updateWidget(
      androidName: _androidWidgetName,
    );
  }
}
