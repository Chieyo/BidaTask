import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

class Chat extends Equatable {
  final String id;
  final String taskId;
  final String taskName;
  final String taskDescription;
  final DateTime lastMessageAt;
  final Message? lastMessage;
  final ChatStatus status;
  final String? otherParticipantId;
  final String? otherParticipantName;
  final String? otherParticipantImage;

  const Chat({
    required this.id,
    required this.taskId,
    required this.taskName,
    this.taskDescription = '',
    required this.lastMessageAt,
    this.lastMessage,
    this.status = ChatStatus.active,
    this.otherParticipantId,
    this.otherParticipantName,
    this.otherParticipantImage,
  });

  @override
  List<Object?> get props => [
        id,
        taskId,
        taskName,
        taskDescription,
        lastMessageAt,
        lastMessage,
        status,
        otherParticipantId,
        otherParticipantName,
        otherParticipantImage,
      ];
}

class Message extends Equatable {
  final String id;
  final String chatId;
  final String senderId;
  final String senderName;
  final String content;
  final DateTime sentAt;
  final MessageStatus status;
  final bool isFromCurrentUser;
  
  bool get isRead => status == MessageStatus.read;

  const Message({
    required this.id,
    required this.chatId,
    required this.senderId,
    required this.senderName,
    required this.content,
    required this.sentAt,
    this.status = MessageStatus.sent,
    this.isFromCurrentUser = false,
  });

  Message copyWith({
    String? id,
    String? chatId,
    String? senderId,
    String? senderName,
    String? content,
    DateTime? sentAt,
    MessageStatus? status,
    bool? isFromCurrentUser,
  }) {
    return Message(
      id: id ?? this.id,
      chatId: chatId ?? this.chatId,
      senderId: senderId ?? this.senderId,
      senderName: senderName ?? this.senderName,
      content: content ?? this.content,
      sentAt: sentAt ?? this.sentAt,
      status: status ?? this.status,
      isFromCurrentUser: isFromCurrentUser ?? this.isFromCurrentUser,
    );
  }

  @override
  List<Object?> get props => [
        id,
        chatId,
        senderId,
        senderName,
        content,
        sentAt,
        status,
        isFromCurrentUser,
      ];
}

enum ChatStatus {
  active,
  completed,
  cancelled,
  pending,
}

enum MessageStatus {
  sending,
  sent,
  delivered,
  read,
  error;

  bool get isRead => this == MessageStatus.read;
}
