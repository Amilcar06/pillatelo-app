class Movimiento {
  final int? id;
  final String tipo; // 'ingreso' | 'gasto'
  final double monto;
  final String descripcion;
  final int? categoriaId;
  final int? accountId;
  final String metodoPago; // 'efectivo' | 'banco' | 'tarjeta'
  final DateTime fecha;
  final DateTime? creadoEn;
  final DateTime? updatedAt;
  final bool isDeleted;
  final DateTime? syncedAt;

  Movimiento({
    this.id,
    required this.tipo,
    required this.monto,
    required this.descripcion,
    this.categoriaId,
    this.accountId,
    required this.metodoPago,
    required this.fecha,
    this.creadoEn,
    this.updatedAt,
    this.isDeleted = false,
    this.syncedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'tipo': tipo,
      'monto': monto,
      'descripcion': descripcion,
      'categoria_id': categoriaId,
      'account_id': accountId,
      'metodo_pago': metodoPago,
      'fecha': fecha.toIso8601String(),
      'creado_en': (creadoEn ?? DateTime.now()).toIso8601String(),
      'updated_at': (updatedAt ?? DateTime.now()).toIso8601String(),
      'is_deleted': isDeleted ? 1 : 0,
      'synced_at': syncedAt?.toIso8601String(),
    };
  }

  factory Movimiento.fromMap(Map<String, dynamic> map) {
    return Movimiento(
      id: map['id'] as int?,
      tipo: map['tipo'] as String,
      monto: (map['monto'] as num).toDouble(),
      descripcion: map['descripcion'] as String? ?? '',
      categoriaId: map['categoria_id'] as int?,
      accountId: map['account_id'] as int?,
      metodoPago: map['metodo_pago'] as String? ?? 'efectivo',
      fecha: DateTime.parse(map['fecha'] as String),
      creadoEn: map['creado_en'] != null ? DateTime.parse(map['creado_en'] as String) : null,
      updatedAt: map['updated_at'] != null ? DateTime.parse(map['updated_at'] as String) : null,
      isDeleted: (map['is_deleted'] as int? ?? 0) == 1,
      syncedAt: map['synced_at'] != null ? DateTime.parse(map['synced_at'] as String) : null,
    );
  }
}
