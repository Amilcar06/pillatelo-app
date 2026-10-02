class Devolucion {
  final int? id;
  final int loanId;
  final double monto;
  final int? accountId;
  final DateTime fecha;
  final String? notas;
  final DateTime? creadoEn;

  Devolucion({
    this.id,
    required this.loanId,
    required this.monto,
    this.accountId,
    required this.fecha,
    this.notas,
    this.creadoEn,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'loan_id': loanId,
        'monto': monto,
        'account_id': accountId,
        'fecha': fecha.toIso8601String(),
        'notas': notas,
        'creado_en': (creadoEn ?? DateTime.now()).toIso8601String(),
      };

  factory Devolucion.fromMap(Map<String, dynamic> map) => Devolucion(
        id: map['id'] as int?,
        loanId: map['loan_id'] as int,
        monto: (map['monto'] as num).toDouble(),
        accountId: map['account_id'] as int?,
        fecha: DateTime.parse(map['fecha'] as String),
        notas: map['notas'] as String?,
        creadoEn: map['creado_en'] != null ? DateTime.parse(map['creado_en'] as String) : null,
      );
}
