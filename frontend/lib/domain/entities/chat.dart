import 'package:equatable/equatable.dart';
import 'message.dart';

enum ChatStatus { active, ended, archived }

class Chat extends Equatable {
  final String id;
  final String taskId;
  final String taskName;
  final String taskDescription;
  final List<String> participants;
  final String requesterId;
  final String taskerId;
  final DateTime createdAt;
  final DateTime? lastMessageAt;
  final Message? lastMessage;
  final ChatStatus status;
  final bool isTyping;
  final String? typingUserId;

  const Chat({
    required this.id,
    required this.taskId,
    required this.taskName,
    required this.taskDescription,
    required this.participants,
    required this.requesterId,
    required this.taskerId,
    required this.createdAt,
    this.lastMessageAt,
    this.lastMessage,
    required this.status,
    this.isTyping = false,
    this.typingUserId,
  });

  Chat copyWith({
    String? id,
    String? taskId,
    String? taskName,
    String? taskDescription,
    List<String>? participants,
    String? requesterId,
    String? taskerId,
    DateTime? createdAt,
    DateTime? lastMessageAt,
    Message? lastMessage,
    ChatStatus? status,
    bool? isTyping,
    String? typingUserId,
  }) {
    return Chat(
      id: id ?? this.id,
      taskId: taskId ?? this.taskId,
      taskName: taskName ?? this.taskName,
      taskDescription: taskDescription ?? this.taskDescription,
      participants: participants ?? this.participants,
      requesterId: requesterId ?? this.requesterId,
      taskerId: taskerId ?? this.taskerId,
      createdAt: createdAt ?? this.createdAt,
      lastMessageAt: lastMessageAt ?? this.lastMessageAt,
      lastMessage: lastMessage ?? this.lastMessage,
      status: status ?? this.status,
      isTyping: isTyping ?? this.isTyping,
      typingUserId: typingUserId ?? this.typingUserId,
    );
  }

  @override
  List<Object?> get props => [
        id,
        taskId,
        taskName,
        taskDescription,
        participants,
        requesterId,
        taskerId,
        createdAt,
        lastMessageAt,
        lastMessage,
        status,
        isTyping,
        typingUserId,
      ];
}
