import '../data/recurrente_repository.dart';
import '../../movimientos/data/movimiento_repository.dart';
import '../../movimientos/data/movimiento_model.dart';
import '../data/recurrente_model.dart';
import 'package:flutter/foundation.dart';

class RecurrenteExecutor {
  static Future<void> ejecutarPendientes() async {
    try {
      final recurrenteRepo = RecurrenteRepository();
      final movRepo = MovimientoRepository();
      
      final activos = await recurrenteRepo.getActivos();
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      
      for (var r in activos) {
        if (r.fechaFin != null && today.isAfter(r.fechaFin!)) {
          // Ya expiró, marcar inactivo
          await recurrenteRepo.update(r.copyWith(activo: false));
          continue;
        }

        DateTime nextRun = _calculateNextRun(r);

        // Mientras nextRun sea <= today, ejecutar
        while (nextRun.isBefore(today) || nextRun.isAtSameMomentAs(today)) {
          // Crear el movimiento
          final mov = Movimiento(
            tipo: r.tipo,
            monto: r.monto,
            descripcion: r.descripcion,
            categoriaId: r.categoriaId,
            accountId: r.accountId,
            metodoPago: 'cuenta', // o lo que corresponda
            fecha: nextRun,
          );
          await movRepo.create(mov);

          // Actualizar ultimaEjecucion a nextRun
          await recurrenteRepo.update(r.copyWith(ultimaEjecucion: nextRun));
          r = r.copyWith(ultimaEjecucion: nextRun); // actualizar local loop
          
          nextRun = _calculateNextRun(r);
        }
      }
    } catch (e) {
      debugPrint('Error ejecutando movimientos recurrentes: $e');
    }
  }

  static DateTime _calculateNextRun(MovimientoRecurrente model) {
    // Si nunca se ejecutó, la próxima es la fecha de inicio
    if (model.ultimaEjecucion == null) {
      return DateTime(model.fechaInicio.year, model.fechaInicio.month, model.fechaInicio.day);
    }
    
    final last = model.ultimaEjecucion!;
    
    switch (model.frecuencia) {
      case 'diario':
        return last.add(const Duration(days: 1));
      case 'semanal':
        return last.add(const Duration(days: 7));
      case 'mensual':
        return DateTime(last.year, last.month + 1, last.day);
      case 'anual':
        return DateTime(last.year + 1, last.month, last.day);
      default:
        return last.add(const Duration(days: 30));
    }
  }
}
