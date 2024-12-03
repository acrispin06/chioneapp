import 'package:flutter/foundation.dart';
import '../services/notification_service.dart';

class NotificationViewModel with ChangeNotifier {
  final NotificationService _notificationService = NotificationService();

  bool _isLoading = false;
  String _errorMessage = '';
  List<Map<String, dynamic>> _notifications = [];

  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  List<Map<String, dynamic>> get notifications => _notifications;

  /// Fetches all notifications from the service and updates the state.
  Future<void> fetchNotifications() async {
    _setLoadingState(true);

    try {
      _notifications = await _notificationService.getAllNotifications();
      _errorMessage = ''; // Clear any previous errors
    } catch (e) {
      _errorMessage = 'Error fetching notifications: ${e.toString()}';
    } finally {
      _setLoadingState(false);
    }
  }

  /// Marks a notification as read and updates the list.
  Future<void> markAsRead(int notificationId) async {
    try {
      await _notificationService.markNotificationAsRead(notificationId);
      _notifications = _notifications.map((notification) {
        if (notification['id'] == notificationId) {
          return {...notification, 'status': 'read'};
        }
        return notification;
      }).toList();
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Error marking notification as read: ${e.toString()}';
    }
  }

  /// Deletes a notification and updates the list.
  Future<void> deleteNotification(int notificationId) async {
    try {
      await _notificationService.deleteNotification(notificationId);
      _notifications = _notifications
          .where((notification) => notification['id'] != notificationId)
          .toList();
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Error deleting notification: ${e.toString()}';
    }
  }

  /// Clears all notifications.
  Future<void> clearAllNotifications() async {
    try {
      await _notificationService.clearAllNotifications();
      _notifications = [];
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Error clearing notifications: ${e.toString()}';
    }
  }

  /// Sets the loading state and notifies listeners if changed.
  void _setLoadingState(bool state) {
    if (_isLoading != state) {
      _isLoading = state;
      Future.delayed(Duration.zero, () {
        notifyListeners();
      });
    }
  }
}
