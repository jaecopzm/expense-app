import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../services/notification_service.dart';

class NotificationPanel extends StatelessWidget {
  const NotificationPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<NotificationService>(
      builder: (context, notificationService, _) {
        final notifications = notificationService.notifications;

        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Notifications',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    if (notifications.isNotEmpty)
                      TextButton(
                        onPressed: () => notificationService.markAllAsRead(),
                        child: const Text('Mark all read'),
                      ),
                  ],
                ),
              ),
              if (notifications.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(32),
                  child: Column(
                    children: [
                      Icon(Icons.notifications_none, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text('No notifications', style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                )
              else
                Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: notifications.length,
                    itemBuilder: (context, index) {
                      final notification = notifications[index];
                      return Dismissible(
                        key: Key(notification.id),
                        background: Container(color: Colors.red),
                        onDismissed: (_) => notificationService.markAsRead(notification.id),
                        child: ListTile(
                          leading: _getIcon(notification.type),
                          title: Text(
                            notification.title,
                            style: TextStyle(
                              fontWeight: notification.isRead ? FontWeight.normal : FontWeight.bold,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(notification.message),
                              const SizedBox(height: 4),
                              Text(
                                _formatTime(notification.timestamp),
                                style: const TextStyle(fontSize: 12, color: Colors.grey),
                              ),
                            ],
                          ),
                          tileColor: notification.isRead ? null : Colors.blue.withOpacity(0.05),
                          onTap: () => notificationService.markAsRead(notification.id),
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _getIcon(String type) {
    switch (type) {
      case 'warning':
        return const CircleAvatar(
          backgroundColor: Colors.orange,
          child: Icon(Icons.warning, color: Colors.white, size: 20),
        );
      case 'error':
        return const CircleAvatar(
          backgroundColor: Colors.red,
          child: Icon(Icons.error, color: Colors.white, size: 20),
        );
      case 'success':
        return const CircleAvatar(
          backgroundColor: Colors.green,
          child: Icon(Icons.check_circle, color: Colors.white, size: 20),
        );
      default:
        return const CircleAvatar(
          backgroundColor: Colors.blue,
          child: Icon(Icons.info, color: Colors.white, size: 20),
        );
    }
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);

    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inDays < 1) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return DateFormat('MMM d').format(time);
  }
}
