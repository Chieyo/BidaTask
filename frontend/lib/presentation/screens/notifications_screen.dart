import 'package:flutter/material.dart';
import '../models/notification_model.dart';
import '../widgets/notification_tile.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  NotificationScreenState createState() => NotificationScreenState();
}

class NotificationScreenState extends State<NotificationScreen> {
  late List<NotificationItem> _notifications;
  
  @override
  void initState() {
    super.initState();
    _initializeNotifications();
  }

  void _initializeNotifications() {
    _notifications = [
      NotificationItem(
        id: '1',
        title: 'Task Accepted',
        message: 'You have accepted the task: Clean the garden',
        timeAgo: '10 min ago',
        isRead: false,
        type: NotificationType.success,
      ),
      NotificationItem(
        id: '2',
        title: 'Task Completed',
        message: 'Dingding A has marked "Take a photo" as completed',
        timeAgo: '1 hour ago',
        isRead: true,
        type: NotificationType.success,
      ),
      NotificationItem(
        id: '3',
        title: 'Task Overdue',
        message: '"Buy rose bouquet" is due in 1 hour',
        timeAgo: '5 hours ago',
        isRead: false,
        type: NotificationType.warning,
      ),
      NotificationItem(
        id: '4',
        title: 'Task Update',
        message: 'New comment on "Sort documents" from Reantazo J',
        timeAgo: '1 day ago',
        isRead: true,
        type: NotificationType.info,
      ),
      NotificationItem(
        id: '5',
        title: 'New Task Assigned',
        message: 'You have been assigned to "Review project proposal"',
        timeAgo: '2 days ago',
        isRead: false,
        type: NotificationType.info,
      ),
    ];
  }

  void _markAllAsRead() {
    if (!mounted) return;
    
    setState(() {
      _notifications = _notifications.map((notification) => 
        notification.copyWith(isRead: true)
      ).toList();
    });
    
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('All notifications marked as read')),
    );
  }

  void _onNotificationTap(int index) {
    if (!mounted) return;
    
    setState(() {
      _notifications = List<NotificationItem>.from(_notifications);
      _notifications[index] = _notifications[index].copyWith(isRead: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          TextButton(
            onPressed: _markAllAsRead,
            child: const Text(
              'Mark all as read',
              style: TextStyle(color: Colors.blue),
            ),
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: _notifications.length,
        itemBuilder: (context, index) {
          final notification = _notifications[index];
          return NotificationTile(
            notification: notification,
            onTap: () => _onNotificationTap(index),
          );
        },
      ),
    );
  }
}
