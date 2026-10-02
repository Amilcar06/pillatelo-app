class Cuenta {
  final int? id;
  final String nombre;
  final String tipo; // 'efectivo', 'banco', 'billetera'
  final double saldoActual;
  final String? color;
  final String? icono;
  final DateTime? creadoEn;

  Cuenta({
    this.id,
    required this.nombre,
    required this.tipo,
    required this.saldoActual,
    this.color,
    this.icono,
    this.creadoEn,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'nombre': nombre,
        'tipo': tipo,
        'saldo_actual': saldoActual,
        'color': color ?? '#2196F3',
        'icono': icono ?? 'account_balance',
        'creado_en': (creadoEn ?? DateTime.now()).toIso8601String(),
      };

  factory Cuenta.fromMap(Map<String, dynamic> map) => Cuenta(
        id: map['id'] as int?,
        nombre: map['nombre'] as String,
        tipo: map['tipo'] as String,
        saldoActual: (map['saldo_actual'] as num).toDouble(),
        color: map['color'] as String?,
        icono: map['icono'] as String?,
        creadoEn: map['creado_en'] != null ? DateTime.parse(map['creado_en'] as String) : null,
      );

  Cuenta copyWith({
    int? id,
    String? nombre,
    String? tipo,
    double? saldoActual,
    String? color,
    String? icono,
    DateTime? creadoEn,
  }) {
    return Cuenta(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      tipo: tipo ?? this.tipo,
      saldoActual: saldoActual ?? this.saldoActual,
      color: color ?? this.color,
      icono: icono ?? this.icono,
      creadoEn: creadoEn ?? this.creadoEn,
    );
  }
}
