import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/notification_view_model.dart';
import '../models/app_notification.dart';

class NotificationScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final notificationViewModel = Provider.of<NotificationViewModel>(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        elevation: 0,
        title: Text("Notification", style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications, color: Colors.white),
            onPressed: () {
              // Acción al presionar el botón de notificación
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            _buildNotificationSection(context, "Today", notificationViewModel.getNotificationsByDate("Today")),
            _buildNotificationSection(context, "Yesterday", notificationViewModel.getNotificationsByDate("Yesterday")),
            _buildNotificationSection(context, "This Weekend", notificationViewModel.getNotificationsByDate("This Weekend")),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationSection(BuildContext context, String title, List<AppNotification> notifications) {
    if (notifications.isEmpty) return SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        SizedBox(height: 8),
        ...notifications.map((notification) => _buildNotificationTile(context, notification)).toList(),
        SizedBox(height: 16),
      ],
    );
  }

  Widget _buildNotificationTile(BuildContext context, AppNotification notification) {
    return Column(
      children: [
        ListTile(
          leading: CircleAvatar(
            backgroundColor: Colors.green.shade100,
            child: _getNotificationIcon(notification.type),
          ),
          title: Text(
            notification.title,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          subtitle: Text(
            notification.message,
            style: TextStyle(fontSize: 14, color: Colors.black54),
          ),
          trailing: Text(
            "${notification.date.hour}:${notification.date.minute.toString().padLeft(2, '0')} - ${_formatDate(notification.date)}",
            style: TextStyle(color: Colors.grey, fontSize: 12),
          ),
        ),
        Divider(),
      ],
    );
  }

  Icon _getNotificationIcon(String type) {
    switch (type) {
      case "reminder":
        return Icon(Icons.notifications, color: Colors.green);
      case "update":
        return Icon(Icons.star, color: Colors.blue);
      case "transaction":
        return Icon(Icons.attach_money, color: Colors.green);
      case "expense_record":
        return Icon(Icons.trending_down, color: Colors.red);
      default:
        return Icon(Icons.notifications, color: Colors.grey);
    }
  }

  String _formatDate(DateTime date) {
    // Puedes personalizar esta función para mostrar las fechas como prefieras.
    return "${date.day} - ${_getMonthName(date.month)}";
  }

  String _getMonthName(int month) {
    const months = [
      "January",
      "February",
      "March",
      "April",
      "May",
      "June",
      "July",
      "August",
      "September",
      "October",
      "November",
      "December"
    ];
    return months[month - 1];
  }
}
