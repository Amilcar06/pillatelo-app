class Presupuesto {
  final int? id;
  final int categoriaId;
  final double montoLimite;
  final String periodo;
  final DateTime? creadoEn;

  // Campos unidos (opcionales) desde la tabla de categorías
  final String? categoriaNombre;
  final String? categoriaColor;
  final double? gastado; // Para el UI (calculado o unido)

  Presupuesto({
    this.id,
    required this.categoriaId,
    required this.montoLimite,
    this.periodo = 'mensual',
    this.creadoEn,
    this.categoriaNombre,
    this.categoriaColor,
    this.gastado,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'categoria_id': categoriaId,
      'monto_limite': montoLimite,
      'periodo': periodo,
      'creado_en': (creadoEn ?? DateTime.now()).toIso8601String(),
    };
  }

  factory Presupuesto.fromMap(Map<String, dynamic> map) {
    return Presupuesto(
      id: map['id'] as int?,
      categoriaId: map['categoria_id'] as int,
      montoLimite: (map['monto_limite'] as num).toDouble(),
      periodo: map['periodo'] as String? ?? 'mensual',
      creadoEn: map['creado_en'] != null ? DateTime.parse(map['creado_en'] as String) : null,
      categoriaNombre: map['categoria_nombre'] as String?,
      categoriaColor: map['categoria_color'] as String?,
    );
  }

  Presupuesto copyWith({
    double? gastado,
  }) {
    return Presupuesto(
      id: id,
      categoriaId: categoriaId,
      montoLimite: montoLimite,
      periodo: periodo,
      creadoEn: creadoEn,
      categoriaNombre: categoriaNombre,
      categoriaColor: categoriaColor,
      gastado: gastado ?? this.gastado,
    );
  }
}
