import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:app_gestion_financiera_personal/features/movimientos/data/movimiento_repository.dart';
import 'package:app_gestion_financiera_personal/features/movimientos/viewmodel/movimiento_viewmodel.dart';
import 'package:app_gestion_financiera_personal/features/movimientos/data/movimiento_model.dart';
import 'package:get_it/get_it.dart';

class MockMovimientoRepository extends Mock implements MovimientoRepository {}

void main() {
  late MovimientoViewModel viewModel;
  late MockMovimientoRepository mockRepo;

  setUp(() {
    mockRepo = MockMovimientoRepository();
    // Register the mock with get_it if the ViewModel uses get_it
    GetIt.I.registerSingleton<MovimientoRepository>(mockRepo);
    
    // Note: If MovimientoViewModel instantiate its own repo, 
    // it needs to be refactored to use GetIt for this test to be truly effective.
    // For this example, we'll assume it will use GetIt.
    viewModel = MovimientoViewModel();
  });

  tearDown(() {
    GetIt.I.reset();
  });

  test('cargarMovimientos actualiza la lista', () async {
    final movimientosDummy = [
      Movimiento(id: 1, tipo: 'ingreso', monto: 100, descripcion: 'Prueba', metodoPago: 'efectivo', fecha: DateTime.now())
    ];
    when(() => mockRepo.getAll()).thenAnswer((_) async => movimientosDummy);

    await viewModel.cargarMovimientos();

    expect(viewModel.movimientos.length, 1);
    expect(viewModel.movimientos.first.monto, 100);
  });

  test('totalIngresosMesActual y totalGastosMesActual calculan solo los del mes en curso', () async {
    final now = DateTime.now();
    final mesAnterior = DateTime(now.year, now.month - 1, 15);

    final movimientosDummy = [
      Movimiento(id: 1, tipo: 'ingreso', monto: 200, descripcion: 'Sueldo este mes', metodoPago: 'cuenta', fecha: now),
      Movimiento(id: 2, tipo: 'gasto', monto: 50, descripcion: 'Gasto este mes', metodoPago: 'cuenta', fecha: now),
      Movimiento(id: 3, tipo: 'ingreso', monto: 500, descripcion: 'Ingreso mes pasado', metodoPago: 'cuenta', fecha: mesAnterior),
      Movimiento(id: 4, tipo: 'gasto', monto: 300, descripcion: 'Gasto mes pasado', metodoPago: 'cuenta', fecha: mesAnterior),
    ];
    when(() => mockRepo.getAll()).thenAnswer((_) async => movimientosDummy);

    await viewModel.cargarMovimientos();

    // Histórico total
    expect(viewModel.totalIngresos, 700.0);
    expect(viewModel.totalGastos, 350.0);

    // Mes actual
    expect(viewModel.totalIngresosMesActual, 200.0);
    expect(viewModel.totalGastosMesActual, 50.0);
  });
}
