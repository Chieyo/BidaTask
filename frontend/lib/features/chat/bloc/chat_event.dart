part of 'chat_bloc.dart';

@immutable
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

  const SendMessage({required this.taskId, required this.content});

  @override
  List<Object> get props => [taskId, content];
}

class MessagesUpdated extends ChatEvent {
  final List<Message> messages;

  const MessagesUpdated(this.messages);

  @override
  List<Object> get props => [messages];
}

class MessageSent extends ChatEvent {
  final Message message;

  const MessageSent(this.message);

  @override
  List<Object> get props => [message];
}

class MessageError extends ChatEvent {
  final String message;

  const MessageError(this.message);

  @override
  List<Object> get props => [message];
}
