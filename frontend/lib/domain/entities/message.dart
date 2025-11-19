import 'package:equatable/equatable.dart';

enum MessageType { text, image, system }

enum MessageStatus { sent, delivered, read }

class Message extends Equatable {
  final String id;
  final String taskId;
  final String senderId;
  final String senderName;
  final String? senderAvatar;
  final String content;
  final MessageType type;
  final DateTime timestamp;
  final MessageStatus status;
  final bool isFromCurrentUser;
  final String? imageUrl;

  const Message({
    required this.id,
    required this.taskId,
    required this.senderId,
    required this.senderName,
    this.senderAvatar,
    required this.content,
    required this.type,
    required this.timestamp,
    required this.status,
    required this.isFromCurrentUser,
    this.imageUrl,
  });

  Message copyWith({
    String? id,
    String? taskId,
    String? senderId,
    String? senderName,
    String? senderAvatar,
    String? content,
    MessageType? type,
    DateTime? timestamp,
    MessageStatus? status,
    bool? isFromCurrentUser,
    String? imageUrl,
  }) {
    return Message(
      id: id ?? this.id,
      taskId: taskId ?? this.taskId,
      senderId: senderId ?? this.senderId,
      senderName: senderName ?? this.senderName,
      senderAvatar: senderAvatar ?? this.senderAvatar,
      content: content ?? this.content,
      type: type ?? this.type,
      timestamp: timestamp ?? this.timestamp,
      status: status ?? this.status,
      isFromCurrentUser: isFromCurrentUser ?? this.isFromCurrentUser,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }

  @override
  List<Object?> get props => [
        id,
        taskId,
        senderId,
        senderName,
        senderAvatar,
        content,
        type,
        timestamp,
        status,
        isFromCurrentUser,
        imageUrl,
      ];
}
