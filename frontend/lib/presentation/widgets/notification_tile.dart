import 'package:flutter/material.dart';
import '../models/notification_model.dart';

/// A widget that displays a single notification item in a list
class NotificationTile extends StatelessWidget {
  /// The notification data to display
  final NotificationItem notification;
  
  /// Callback when the notification is tapped
  final VoidCallback? onTap;

  /// Creates a notification tile widget
  const NotificationTile({
    super.key,
    required this.notification,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: notification.isRead ? Colors.white : Colors.blue[50],
          border: Border(
            bottom: BorderSide(
              color: Colors.grey[200]!,
              width: 1.0,
            ),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Notification icon with status indicator
            _buildNotificationIcon(),
            const SizedBox(width: 12),
            _buildNotificationContent(),
          ],
        ),
      ),
    );
  }

  /// Builds the notification icon with status indicator
  Widget _buildNotificationIcon() {
    return Stack(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: _getIconColor(notification.type).withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(
            _getIcon(notification.type),
            color: _getIconColor(notification.type),
            size: 20,
          ),
        ),
        if (!notification.isRead) _buildUnreadIndicator(),
      ],
    );
  }

  /// Builds the unread indicator (blue dot)
  Widget _buildUnreadIndicator() {
    return const Positioned(
      right: 0,
      top: 0,
      child: SizedBox(
        width: 12,
        height: 12,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.blue,
            shape: BoxShape.circle,
            border: Border.fromBorderSide(
              BorderSide(color: Colors.white, width: 2),
            ),
          ),
        ),
      ),
    );
  }

  /// Builds the notification content (title, message, and time)
  Widget _buildNotificationContent() {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            notification.title,
            style: TextStyle(
              fontWeight: notification.isRead ? FontWeight.normal : FontWeight.bold,
              fontSize: 14,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            notification.message,
            style: TextStyle(
              fontWeight: notification.isRead ? FontWeight.normal : FontWeight.w500,
              fontSize: 13,
              color: Colors.black54,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            notification.timeAgo,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  /// Returns the appropriate icon based on notification type
  IconData _getIcon(NotificationType type) {
    switch (type) {
      case NotificationType.success:
        return Icons.check_circle_outline;
      case NotificationType.warning:
        return Icons.warning_amber_outlined;
      case NotificationType.info:
      default:
        return Icons.info_outline;
    }
  }

  /// Returns the appropriate color based on notification type
  Color _getIconColor(NotificationType type) {
    switch (type) {
      case NotificationType.success:
        return Colors.green;
      case NotificationType.warning:
        return Colors.orange;
      case NotificationType.info:
      default:
        return Colors.blue;
    }
  }
}
