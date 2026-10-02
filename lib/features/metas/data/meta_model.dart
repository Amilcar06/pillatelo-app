class Meta {
  final int? id;
  final String nombre;
  final double targetAmount;
  final double currentAmount;
  final DateTime fechaLimite;
  final String estado; // activa | completada
  final DateTime? creadoEn;

  Meta({
    this.id,
    required this.nombre,
    required this.targetAmount,
    this.currentAmount = 0.0,
    required this.fechaLimite,
    this.estado = 'activa',
    this.creadoEn,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'nombre': nombre,
        'target_amount': targetAmount,
        'current_amount': currentAmount,
        'fecha_limite': fechaLimite.toIso8601String(),
        'estado': estado,
        'creado_en': (creadoEn ?? DateTime.now()).toIso8601String(),
      };

  factory Meta.fromMap(Map<String, dynamic> map) => Meta(
        id: map['id'] as int?,
        nombre: map['nombre'] as String,
        targetAmount: (map['target_amount'] as num).toDouble(),
        currentAmount: (map['current_amount'] as num?)?.toDouble() ?? 0.0,
        fechaLimite: DateTime.parse(map['fecha_limite'] as String),
        estado: map['estado'] as String? ?? 'activa',
        creadoEn: map['creado_en'] != null ? DateTime.parse(map['creado_en'] as String) : null,
      );
}

class Contribution {
  final int? id;
  final int goalId;
  final double monto;
  final DateTime fecha;
  final DateTime? creadoEn;

  Contribution({this.id, required this.goalId, required this.monto, required this.fecha, this.creadoEn});

  Map<String, dynamic> toMap() => {
        'id': id,
        'goal_id': goalId,
        'monto': monto,
        'fecha': fecha.toIso8601String(),
        'creado_en': (creadoEn ?? DateTime.now()).toIso8601String(),
      };

  factory Contribution.fromMap(Map<String, dynamic> map) => Contribution(
        id: map['id'] as int?,
        goalId: map['goal_id'] as int,
        monto: (map['monto'] as num).toDouble(),
        fecha: DateTime.parse(map['fecha'] as String),
        creadoEn: map['creado_en'] != null ? DateTime.parse(map['creado_en'] as String) : null,
      );
}


