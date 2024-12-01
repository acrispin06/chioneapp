class AppNotification {
  int? id;
  String title;
  String message;
  DateTime date;
  String type;
  int? entityId;
  String? entityType;
  String status;
  DateTime createdAt;
  DateTime updatedAt;

  AppNotification({
    this.id,
    required this.title,
    required this.message,
    required this.date,
    required this.type,
    this.entityId,
    this.entityType,
    this.status = 'unread',
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'date': date.toIso8601String(),
      'type': type,
      'entity_id': entityId,
      'entity_type': entityType,
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory AppNotification.fromMap(Map<String, dynamic> map) {
    return AppNotification(
      id: map['id'],
      title: map['title'],
      message: map['message'],
      date: DateTime.parse(map['date']),
      type: map['type'],
      entityId: map['entity_id'],
      entityType: map['entity_type'],
      status: map['status'],
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
    );
  }
}
