class Prestamo {
  final int? id;
  final String tipo; // 'prestado' (preste/me deben) | 'recibido' (pedi/debo)
  final String nombrePersona;
  final double monto;
  final double remainingAmount;
  final double? interes;
  final DateTime? dueDate;
  final String status; // 'active' | 'settled' | 'overdue'
  final String? notas;
  final int? accountId;
  final DateTime? creadoEn;

  Prestamo({
    this.id,
    required this.tipo,
    required this.nombrePersona,
    required this.monto,
    double? remainingAmount,
    this.interes,
    this.dueDate,
    this.status = 'active',
    this.notas,
    this.accountId,
    this.creadoEn,
  }) : remainingAmount = remainingAmount ?? monto;

  Map<String, dynamic> toMap() => {
        'id': id,
        'tipo': tipo,
        'nombre_persona': nombrePersona,
        'monto': monto,
        'remaining_amount': remainingAmount,
        'interes': interes,
        'due_date': dueDate?.toIso8601String(),
        'status': status,
        'notas': notas,
        'account_id': accountId,
        'creado_en': (creadoEn ?? DateTime.now()).toIso8601String(),
      };

  factory Prestamo.fromMap(Map<String, dynamic> map) => Prestamo(
        id: map['id'] as int?,
        tipo: map['tipo'] as String,
        nombrePersona: map['nombre_persona'] as String,
        monto: (map['monto'] as num).toDouble(),
        remainingAmount: (map['remaining_amount'] as num?)?.toDouble() ?? (map['monto'] as num).toDouble(),
        interes: (map['interes'] as num?)?.toDouble(),
        dueDate: map['due_date'] != null ? DateTime.parse(map['due_date'] as String) : null,
        status: map['status'] as String? ?? 'active',
        notas: map['notas'] as String?,
        accountId: map['account_id'] as int?,
        creadoEn: map['creado_en'] != null ? DateTime.parse(map['creado_en'] as String) : null,
      );

  Prestamo copyWith({
    int? id,
    String? tipo,
    String? nombrePersona,
    double? monto,
    double? remainingAmount,
    double? interes,
    DateTime? dueDate,
    String? status,
    String? notas,
    int? accountId,
    DateTime? creadoEn,
  }) {
    return Prestamo(
      id: id ?? this.id,
      tipo: tipo ?? this.tipo,
      nombrePersona: nombrePersona ?? this.nombrePersona,
      monto: monto ?? this.monto,
      remainingAmount: remainingAmount ?? this.remainingAmount,
      interes: interes ?? this.interes,
      dueDate: dueDate ?? this.dueDate,
      status: status ?? this.status,
      notas: notas ?? this.notas,
      accountId: accountId ?? this.accountId,
      creadoEn: creadoEn ?? this.creadoEn,
    );
  }
}
