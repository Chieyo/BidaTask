enum NotificationType {
  success,
  warning,
  info,
}

class NotificationItem {
  final String id;
  final String title;
  final String message;
  final String timeAgo;
  bool isRead;
  final NotificationType type;

  NotificationItem({
    required this.id,
    required this.title,
    required this.message,
    required this.timeAgo,
    this.isRead = false,
    this.type = NotificationType.info,
  });
}
