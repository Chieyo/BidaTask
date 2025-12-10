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
    // Check if this is a task acceptance notification and determine if it's for task owner or taker
    bool isTaskTaker = false;
    bool isTaskOwner = false;
    
    if (notification.type == NotificationType.task && 
        notification.message.contains('accepted')) {
      isTaskTaker = notification.message.startsWith('You accepted');
      isTaskOwner = !isTaskTaker;
    }
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: notification.isRead 
            ? Colors.white 
            : (isTaskTaker ? Colors.blue[50] : Colors.green[50]),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: notification.isRead 
              ? Colors.grey[200]!
              : (isTaskTaker ? Colors.blue[200]! : Colors.green[200]!),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
          if (!notification.isRead)
            BoxShadow(
              color: (isTaskTaker ? Colors.blue : Colors.green).withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildNotificationIcon(),
                const SizedBox(width: 12),
                Expanded(child: _buildNotificationContent()),
                if (!notification.isRead) 
                  const SizedBox(width: 6),
                if (!notification.isRead) _buildUnreadIndicator(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Builds the notification icon with status indicator
  Widget _buildNotificationIcon() {
    // Check if this is a task acceptance notification and determine if it's for task owner or taker
    bool isTaskTaker = false;
    bool isTaskOwner = false;
    
    if (notification.type == NotificationType.task && 
        notification.message.contains('accepted')) {
      isTaskTaker = notification.message.startsWith('You accepted');
      isTaskOwner = !isTaskTaker;
    }
    
    Color iconColor = isTaskTaker ? Colors.blue[600]! : Colors.green[600]!;
    Color bgColor = isTaskTaker ? Colors.blue[100]! : Colors.green[100]!;
    IconData iconData;
    
    if (isTaskTaker) {
      iconData = Icons.check_circle;
    } else if (isTaskOwner) {
      iconData = Icons.person_add;
    } else {
      iconData = _getIcon(notification.type);
      iconColor = _getIconColor(notification.type);
      bgColor = _getIconColor(notification.type).withOpacity(0.1);
    }
    
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: iconColor.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Icon(
        iconData,
        color: iconColor,
        size: 20,
      ),
    );
  }

  /// Builds the unread indicator (blue dot)
  Widget _buildUnreadIndicator() {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        color: Colors.blue[600],
        shape: BoxShape.circle,
      ),
    );
  }

  /// Builds the notification content (title, message, and time)
  Widget _buildNotificationContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          notification.title,
          style: TextStyle(
            fontWeight: notification.isRead ? FontWeight.w600 : FontWeight.bold,
            fontSize: 14,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 2),
        _buildHighlightedMessage(),
        const SizedBox(height: 4),
        Text(
          notification.timeAgo,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey[500],
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  /// Builds the message with highlighted name for task acceptance
  Widget _buildHighlightedMessage() {
    String message = notification.message;
    
    // Check if this is a task acceptance notification and extract the name
    if (notification.type == NotificationType.task && 
        message.contains('accepted') && 
        message.contains('"')) {
      
      // Check if this is "You accepted" (task taker) or "Someone accepted" (task owner)
      bool isTaskTaker = message.startsWith('You accepted');
      
      if (isTaskTaker) {
        // Task taker: "You accepted 'Task Name'"
        return RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: 'You',
                style: TextStyle(
                  fontWeight: notification.isRead ? FontWeight.w600 : FontWeight.bold,
                  fontSize: 13,
                  color: Colors.blue[700],
                ),
              ),
              TextSpan(
                text: message.substring(3), // " accepted 'Task Name'"
                style: TextStyle(
                  fontWeight: notification.isRead ? FontWeight.normal : FontWeight.w500,
                  fontSize: 13,
                  color: Colors.black54,
                ),
              ),
            ],
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        );
      } else {
        // Task owner: "PersonName accepted 'Task Name'"
        int acceptedIndex = message.indexOf(' accepted');
        if (acceptedIndex > 0) {
          String personName = message.substring(0, acceptedIndex);
          String restOfMessage = message.substring(acceptedIndex);
          
          return RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: personName,
                  style: TextStyle(
                    fontWeight: notification.isRead ? FontWeight.w600 : FontWeight.bold,
                    fontSize: 13,
                    color: Colors.green[700],
                  ),
                ),
                TextSpan(
                  text: restOfMessage,
                  style: TextStyle(
                    fontWeight: notification.isRead ? FontWeight.normal : FontWeight.w500,
                    fontSize: 13,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          );
        }
      }
    }
    
    // Default message display
    return Text(
      message,
      style: TextStyle(
        fontWeight: notification.isRead ? FontWeight.normal : FontWeight.w500,
        fontSize: 13,
        color: Colors.black54,
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  /// Returns the appropriate icon based on notification type
  IconData _getIcon(NotificationType type) {
    switch (type) {
      case NotificationType.task:
        return Icons.task_alt_outlined;
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
      case NotificationType.task:
        return Colors.purple;
      case NotificationType.success:
        return Colors.green;
      case NotificationType.warning:
        return Colors.orange;
      case NotificationType.info:
      default:
        return Colors.blue;
    }
  }

  /// Returns the appropriate title color based on notification type
  Color _getTitleColor(NotificationType type) {
    switch (type) {
      case NotificationType.task:
        return Colors.purple[700]!;
      case NotificationType.success:
        return Colors.green[700]!;
      case NotificationType.warning:
        return Colors.orange[700]!;
      case NotificationType.info:
      default:
        return Colors.blue[700]!;
    }
  }
}
