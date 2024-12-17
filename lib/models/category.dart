class Category {
  int? id;
  String name;
  int type_id;
  int? iconId;
  DateTime createdAt;
  DateTime updatedAt;

  Category({
    this.id,
    required this.name,
    required this.type_id,
    this.iconId,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'type_id': type_id,
      'icon_id': iconId,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      id: map['id'],
      name: map['name'],
      type_id: map['type_id'],
      iconId: map['icon_id'],
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
    );
  }
}