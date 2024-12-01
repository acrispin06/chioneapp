import '../db/database_helper.dart';

class NotificationService {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  Future<List<Map<String, dynamic>>> getAllNotifications() async {
    final db = await _dbHelper.database;
    return await db.query('notifications', orderBy: 'date DESC');
  }

  Future<int> addNotification(Map<String, dynamic> notification) async {
    final db = await _dbHelper.database;
    return await db.insert('notifications', notification);
  }

  Future<void> markAsRead(int notificationId) async {
    final db = await _dbHelper.database;
    await db.update('notifications', {'status': 'read'}, where: 'id = ?', whereArgs: [notificationId]);
  }
}
