import 'package:flutter/material.dart';
import '../models/notification_model.dart';
import '../widgets/notification_tile.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final List<NotificationItem> notifications = [
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
    NotificationItem(
      id: '6',
      title: 'Tasks Near You',
      message: '3 tasks available within 1km of your location',
      timeAgo: 'Just now',
      isRead: false,
      type: NotificationType.info,
    ),
    NotificationItem(
      id: '7',
      title: 'Task Nearby',
      message: '"Deliver package to Espana Blvd." is 200m away',
      timeAgo: '30 min ago',
      isRead: false,
      type: NotificationType.info,
    ),
    NotificationItem(
      id: '8',
      title: 'Location-Based Task',
      message: 'You\'re near the office - consider completing "Office supply restock"',
      timeAgo: '1 hour ago',
      isRead: true,
      type: NotificationType.info,
    ),
  ];

  void _markAllAsRead() {
    setState(() {
      for (var notification in notifications) {
        notification.isRead = true;
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('All notifications marked as read')),
    );
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
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          final notification = notifications[index];
          return NotificationTile(
            notification: notification,
            onTap: () {
              setState(() {
                notification.isRead = true;
              });
            },
          );
        },
      ),
    );
  }
}
