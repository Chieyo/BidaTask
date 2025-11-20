/// Represents the type of notification
enum NotificationType {
  /// Informational notification
  info,
  
  /// Success notification
  success,
  
  /// Warning notification
  warning,
}

/// Represents a single notification item in the app
class NotificationItem {
  /// Unique identifier for the notification
  final String id;
  
  /// Title of the notification
  final String title;
  
  /// Detailed message of the notification
  final String message;
  
  /// Time when the notification was received (e.g., '2 hours ago')
  final String timeAgo;
  
  /// Whether the notification has been read
  final bool isRead;
  
  /// Type of the notification
  final NotificationType type;

  /// Creates a new notification item
  const NotificationItem({
    required this.id,
    required this.title,
    required this.message,
    required this.timeAgo,
    this.isRead = false,
    this.type = NotificationType.info,
  });

  /// Creates a copy of this notification with the given fields replaced with the new values
  NotificationItem copyWith({
    String? id,
    String? title,
    String? message,
    String? timeAgo,
    bool? isRead,
    NotificationType? type,
  }) {
    return NotificationItem(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      timeAgo: timeAgo ?? this.timeAgo,
      isRead: isRead ?? this.isRead,
      type: type ?? this.type,
    );
  }
}
