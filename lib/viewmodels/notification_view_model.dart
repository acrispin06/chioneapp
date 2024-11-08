import 'package:flutter/material.dart';
import '../db/database_helper.dart';
import '../models/AppNotification.dart';

class NotificationViewModel extends ChangeNotifier {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<AppNotification> _notifications = [];

  List<AppNotification> get notifications => _notifications;

  Future<void> fetchNotifications() async {
    _notifications = await _dbHelper.getNotifications();
    notifyListeners();
  }

  Future<void> addNotification(AppNotification notification) async {
    await _dbHelper.insertNotification(notification);
    await fetchNotifications();
  }

  List<AppNotification> getNotificationsByDate(String dateLabel) {
    DateTime now = DateTime.now();

    return _notifications.where((notification) {
      if (dateLabel == "Today") {
        return notification.date.day == now.day &&
            notification.date.month == now.month &&
            notification.date.year == now.year;
      } else if (dateLabel == "Yesterday") {
        return notification.date.day == now.subtract(Duration(days: 1)).day &&
            notification.date.month == now.month &&
            notification.date.year == now.year;
      } else if (dateLabel == "This Weekend") {
        DateTime weekendStart = now.subtract(Duration(days: now.weekday));
        DateTime weekendEnd = weekendStart.add(Duration(days: 2));
        return notification.date.isAfter(weekendStart) && notification.date.isBefore(weekendEnd);
      }
      return false;
    }).toList();
  }
}
