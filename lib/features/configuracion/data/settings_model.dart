class Configuracion {
  final int? id;
  final String? pin; // Nota: el PIN se gestionará en almacenamiento seguro
  final String moneda; // símbolo o código, ej: '$' o 'BOB'
  final double cashBalance;
  final double bankBalance;
  final bool setupComplete;

  Configuracion({
    this.id,
    this.pin,
    this.moneda = '\u0000',
    this.cashBalance = 0.0,
    this.bankBalance = 0.0,
    this.setupComplete = false,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'pin': pin,
        'moneda': moneda,
        'cash_balance': cashBalance,
        'bank_balance': bankBalance,
        'setup_complete': setupComplete ? 1 : 0,
      };

  factory Configuracion.fromMap(Map<String, dynamic> map) => Configuracion(
        id: map['id'] as int?,
        pin: map['pin'] as String?,
        moneda: (map['moneda'] as String?) ?? '\u0000',
        cashBalance: (map['cash_balance'] as num?)?.toDouble() ?? 0.0,
        bankBalance: (map['bank_balance'] as num?)?.toDouble() ?? 0.0,
        setupComplete: (map['setup_complete'] as int? ?? 0) == 1,
      );
}


