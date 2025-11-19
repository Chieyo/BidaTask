part of 'chat_bloc.dart';

abstract class ChatEvent extends Equatable {
  const ChatEvent();

  @override
  List<Object> get props => [];
}

class LoadChat extends ChatEvent {
  final String taskId;

  const LoadChat(this.taskId);

  @override
  List<Object> get props => [taskId];
}

class SendMessage extends ChatEvent {
  final String taskId;
  final String content;

  const SendMessage({
    required this.taskId,
    required this.content,
  });

  @override
  List<Object> get props => [taskId, content];
}

class SendImageMessage extends ChatEvent {
  final String taskId;
  final String imagePath;

  const SendImageMessage({
    required this.taskId,
    required this.imagePath,
  });

  @override
  List<Object> get props => [taskId, imagePath];
}

class LoadMoreMessages extends ChatEvent {
  final String taskId;

  const LoadMoreMessages(this.taskId);

  @override
  List<Object> get props => [taskId];
}

class MarkMessageAsRead extends ChatEvent {
  final String messageId;

  const MarkMessageAsRead(this.messageId);

  @override
  List<Object> get props => [messageId];
}

class SendTypingIndicator extends ChatEvent {
  final String taskId;
  final bool isTyping;

  const SendTypingIndicator({
    required this.taskId,
    required this.isTyping,
  });

  @override
  List<Object> get props => [taskId, isTyping];
}

class UpdateMessages extends ChatEvent {
  final List<Message> messages;

  const UpdateMessages(this.messages);

  @override
  List<Object> get props => [messages];
}

class UpdateTypingIndicator extends ChatEvent {
  final bool isTyping;

  const UpdateTypingIndicator(this.isTyping);

  @override
  List<Object> get props => [isTyping];
}
