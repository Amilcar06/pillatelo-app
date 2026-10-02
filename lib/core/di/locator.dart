import 'package:get_it/get_it.dart';
import '../../features/movimientos/data/movimiento_repository.dart';
import '../../features/cuentas/data/cuenta_repository.dart';
import '../../features/prestamos/data/prestamo_repository.dart';
import '../../features/metas/data/meta_repository.dart';
import '../../features/configuracion/data/configuracion_repository.dart';
import '../../features/configuracion/data/categoria_repository.dart';
import '../../features/presupuestos/data/presupuesto_repository.dart';
import '../../features/recurrentes/data/recurrente_repository.dart';

final locator = GetIt.instance;

void setupLocator() {
  // Repositorios
  locator.registerLazySingleton<MovimientoRepository>(() => MovimientoRepository());
  locator.registerLazySingleton<CuentaRepository>(() => CuentaRepository());
  locator.registerLazySingleton<PrestamoRepository>(() => PrestamoRepository());
  locator.registerLazySingleton<MetaRepository>(() => MetaRepository());
  locator.registerLazySingleton<ConfiguracionRepository>(() => ConfiguracionRepository());
  locator.registerLazySingleton<CategoriaRepository>(() => CategoriaRepository());
  locator.registerLazySingleton<PresupuestoRepository>(() => PresupuestoRepository());
  locator.registerLazySingleton<RecurrenteRepository>(() => RecurrenteRepository());
}
