import 'package:flutter/material.dart';
import '../../features/setup/ui/bienvenida_page.dart';
import '../../features/setup/ui/saldo_inicial_page.dart';
import '../../features/seguridad/ui/pin_page.dart';
import '../../features/setup/ui/configuracion_inicial_page.dart';
import '../../features/movimientos/ui/movimientos_page.dart';
import '../../features/movimientos/ui/registrar_movimiento_page.dart';
import '../../features/prestamos/ui/prestamos_page.dart';
import '../../features/prestamos/ui/registrar_prestamo_page.dart';
import '../../features/seguridad/ui/pin_login_page.dart';
import '../../features/shell/ui/main_shell.dart';
import '../../features/configuracion/ui/configuracion_page.dart';
import '../../features/metas/ui/metas_page.dart';
import '../../features/metas/ui/registrar_meta_page.dart';
import '../../features/reportes/ui/reportes_page.dart';
import '../../features/configuracion/ui/categorias_page.dart';
import '../../features/configuracion/ui/acerca_de_page.dart';
import '../../features/configuracion/ui/politica_privacidad_page.dart';
import '../../features/presupuestos/ui/presupuestos_page.dart';
import '../../features/recurrentes/ui/recurrentes_page.dart';
import '../../features/recurrentes/ui/registrar_recurrente_page.dart';

class AppRouter {
  static Map<String, WidgetBuilder> routes = {
    '/setup/bienvenida': (_) => BienvenidaPage(),
    '/setup/saldo-inicial': (_) => SaldoInicialPage(),
    '/setup/pin': (_) => PinPage(),
    '/setup/preferencias': (_) => ConfiguracionInicialPage(),
    '/pin/login': (_) => PinLoginPage(),
    '/inicio': (_) => const MainShell(),
    '/movimientos': (_) => const MovimientosPage(),
    '/movimientos/registrar': (_) => const RegistrarMovimientoPage(),
    '/prestamos': (_) => const PrestamosPage(),
    '/prestamos/registrar': (_) => const RegistrarPrestamoPage(),
    '/metas': (_) => const MetasPage(),
    '/metas/registrar': (_) => const RegistrarMetaPage(),
    '/reportes': (_) => const ReportesPage(),
    '/configuracion': (_) => const ConfiguracionPage(),
    '/configuracion/categorias': (_) => const CategoriasPage(),
    '/configuracion/acerca': (_) => const AcercaDePage(),
    '/configuracion/privacidad': (_) => const PoliticaPrivacidadPage(),
    '/presupuestos': (_) => const PresupuestosPage(),
    '/recurrentes': (_) => const RecurrentesPage(),
    '/recurrentes/registrar': (_) => const RegistrarRecurrentePage(),
  };
}
