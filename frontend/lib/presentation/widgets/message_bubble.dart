import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/message.dart';

class MessageBubble extends StatelessWidget {
  const MessageBubble({
    super.key,
    required this.message,
    required this.isFromCurrentUser,
  });

  final Message message;
  final bool isFromCurrentUser;

  @override
  Widget build(BuildContext context) {
    final bubbleColor = isFromCurrentUser
        ? const Color(0xFF007AFF)
        : Colors.white;
    final textColor = isFromCurrentUser ? Colors.white : const Color(0xFF101828);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
      child: Column(
        crossAxisAlignment:
            isFromCurrentUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          if (!isFromCurrentUser)
            Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 4),
              child: Text(
                message.senderName,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: const Color(0xFF8E8E93),
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
          Container(
            padding: message.type == MessageType.text
                ? const EdgeInsets.symmetric(horizontal: 16, vertical: 12)
                : EdgeInsets.zero,
            constraints: const BoxConstraints(maxWidth: 280),
            decoration: BoxDecoration(
              color: bubbleColor,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(isFromCurrentUser ? 20 : 8),
                topRight: Radius.circular(isFromCurrentUser ? 8 : 20),
                bottomLeft: const Radius.circular(20),
                bottomRight: const Radius.circular(20),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: _buildMessageContent(textColor),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment:
                isFromCurrentUser ? MainAxisAlignment.end : MainAxisAlignment.start,
            children: [
              Text(
                _formatTime(message.timestamp),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: const Color(0xFF8E8E93),
                      fontSize: 11,
                    ),
              ),
              if (isFromCurrentUser) ...[
                const SizedBox(width: 4),
                Icon(
                  _getStatusIcon(message.status),
                  size: 12,
                  color: const Color(0xFFB0B0B8),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMessageContent(Color textColor) {
    switch (message.type) {
      case MessageType.text:
        return Text(
          message.content,
          style: TextStyle(
            color: textColor,
            height: 1.4,
          ),
        );
      case MessageType.image:
        if (message.imageUrl == null) return _imagePlaceholder();
        return ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: CachedNetworkImage(
            imageUrl: message.imageUrl!,
            width: 220,
            height: 220,
            fit: BoxFit.cover,
            placeholder: (context, url) => Container(
              width: 220,
              height: 220,
              color: Colors.grey[200],
              child: const Center(child: CircularProgressIndicator()),
            ),
            errorWidget: (context, url, error) => _imagePlaceholder(),
          ),
        );
      case MessageType.system:
        return Text(
          message.content,
          style: TextStyle(
            fontStyle: FontStyle.italic,
            color: textColor,
          ),
        );
    }
  }

  Widget _imagePlaceholder() {
    return Container(
      width: 220,
      height: 220,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(18),
      ),
      child: const Icon(Icons.image, color: Colors.grey),
    );
  }

  String _formatTime(DateTime timestamp) {
    return DateFormat.jm().format(timestamp);
  }

  IconData _getStatusIcon(MessageStatus status) {
    switch (status) {
      case MessageStatus.sent:
        return Icons.check;
      case MessageStatus.delivered:
        return Icons.done_all;
      case MessageStatus.read:
        return Icons.done_all;
    }
  }
}
