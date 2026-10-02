class Categoria {
  final int? id;
  final String nombre;
  final String tipo; // ingreso | gasto
  final String color;
  final bool isDefault;

  Categoria({this.id, required this.nombre, required this.tipo, required this.color, this.isDefault = false});

  Map<String, dynamic> toMap() => {
        'id': id,
        'nombre': nombre,
        'tipo': tipo,
        'color': color,
        'is_default': isDefault ? 1 : 0,
      };

  factory Categoria.fromMap(Map<String, dynamic> map) => Categoria(
        id: map['id'] as int?,
        nombre: map['nombre'] as String,
        tipo: map['tipo'] as String,
        color: map['color'] as String? ?? '#607D8B',
        isDefault: (map['is_default'] as int? ?? 0) == 1,
      );
}


