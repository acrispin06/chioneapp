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

  Future<void> fetchNotifications() async {
    _isLoading = true;
    notifyListeners();

    try {
      _notifications = await _notificationService.getAllNotifications();
    } catch (e) {
      _errorMessage = 'Error fetching notifications';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
