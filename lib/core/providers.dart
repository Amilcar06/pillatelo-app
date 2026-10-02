import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import '../features/cuentas/viewmodel/cuenta_viewmodel.dart';
import '../features/metas/viewmodel/meta_viewmodel.dart';
import '../features/movimientos/viewmodel/movimiento_viewmodel.dart';
import '../features/prestamos/viewmodel/prestamo_viewmodel.dart';
import '../features/configuracion/viewmodel/configuracion_viewmodel.dart';
import '../features/reportes/viewmodel/reporte_viewmodel.dart';
import '../features/presupuestos/viewmodel/presupuesto_viewmodel.dart';
import '../features/recurrentes/viewmodel/recurrente_viewmodel.dart';
import 'providers/privacy_provider.dart';

final List<SingleChildWidget> appProviders = [
  ChangeNotifierProvider<CuentaViewModel>(create: (_) => CuentaViewModel()),
  ChangeNotifierProvider<MovimientoViewModel>(create: (_) => MovimientoViewModel()),
  ChangeNotifierProvider<PrestamoViewModel>(create: (_) => PrestamoViewModel()),
  ChangeNotifierProvider<MetaViewModel>(create: (_) => MetaViewModel()),
  ChangeNotifierProvider<ConfiguracionViewModel>(create: (_) => ConfiguracionViewModel()),
  ChangeNotifierProvider<ReporteViewModel>(create: (_) => ReporteViewModel()),
  ChangeNotifierProvider<PrivacyProvider>(create: (_) => PrivacyProvider()),
  ChangeNotifierProvider<PresupuestoViewModel>(create: (_) => PresupuestoViewModel()),
  ChangeNotifierProvider<RecurrenteViewModel>(create: (_) => RecurrenteViewModel()),
];

