class MovimientoRecurrente {
  final int? id;
  final String tipo; // 'ingreso', 'gasto'
  final double monto;
  final String descripcion;
  final int? categoriaId;
  final int? accountId;
  final String frecuencia; // 'diario', 'semanal', 'mensual', 'anual'
  final int? diaEjecucion; // Dia del mes o de la semana
  final DateTime fechaInicio;
  final DateTime? fechaFin;
  final bool activo;
  final DateTime? ultimaEjecucion;
  final DateTime? creadoEn;

  MovimientoRecurrente({
    this.id,
    required this.tipo,
    required this.monto,
    required this.descripcion,
    this.categoriaId,
    this.accountId,
    required this.frecuencia,
    this.diaEjecucion,
    required this.fechaInicio,
    this.fechaFin,
    this.activo = true,
    this.ultimaEjecucion,
    this.creadoEn,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'tipo': tipo,
      'monto': monto,
      'descripcion': descripcion,
      'categoria_id': categoriaId,
      'account_id': accountId,
      'frecuencia': frecuencia,
      'dia_ejecucion': diaEjecucion,
      'fecha_inicio': fechaInicio.toIso8601String(),
      'fecha_fin': fechaFin?.toIso8601String(),
      'activo': activo ? 1 : 0,
      'ultima_ejecucion': ultimaEjecucion?.toIso8601String(),
      'creado_en': (creadoEn ?? DateTime.now()).toIso8601String(),
    };
  }

  factory MovimientoRecurrente.fromMap(Map<String, dynamic> map) {
    return MovimientoRecurrente(
      id: map['id'] as int?,
      tipo: map['tipo'] as String,
      monto: (map['monto'] as num).toDouble(),
      descripcion: map['descripcion'] as String,
      categoriaId: map['categoria_id'] as int?,
      accountId: map['account_id'] as int?,
      frecuencia: map['frecuencia'] as String,
      diaEjecucion: map['dia_ejecucion'] as int?,
      fechaInicio: DateTime.parse(map['fecha_inicio'] as String),
      fechaFin: map['fecha_fin'] != null ? DateTime.parse(map['fecha_fin'] as String) : null,
      activo: (map['activo'] as int) == 1,
      ultimaEjecucion: map['ultima_ejecucion'] != null ? DateTime.parse(map['ultima_ejecucion'] as String) : null,
      creadoEn: map['creado_en'] != null ? DateTime.parse(map['creado_en'] as String) : null,
    );
  }

  MovimientoRecurrente copyWith({
    bool? activo,
    DateTime? ultimaEjecucion,
  }) {
    return MovimientoRecurrente(
      id: id,
      tipo: tipo,
      monto: monto,
      descripcion: descripcion,
      categoriaId: categoriaId,
      accountId: accountId,
      frecuencia: frecuencia,
      diaEjecucion: diaEjecucion,
      fechaInicio: fechaInicio,
      fechaFin: fechaFin,
      activo: activo ?? this.activo,
      ultimaEjecucion: ultimaEjecucion ?? this.ultimaEjecucion,
      creadoEn: creadoEn,
    );
  }
}
