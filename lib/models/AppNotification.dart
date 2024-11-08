class AppNotification {
  final int id;
  final String title;
  final String message;
  final DateTime date;
  final String type; // "reminder", "update", "transaction"

  AppNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.date,
    required this.type,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'date': date.toIso8601String(),
      'type': type,
    };
  }

  factory AppNotification.fromMap(Map<String, dynamic> map) {
    return AppNotification(
      id: map['id'],
      title: map['title'],
      message: map['message'],
      date: DateTime.parse(map['date']),
      type: map['type'],
    );
  }
}
