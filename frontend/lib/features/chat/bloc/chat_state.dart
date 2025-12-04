part of 'chat_bloc.dart';

@immutable
abstract class ChatState extends Equatable {
  const ChatState();

  @override
  List<Object?> get props => [];
}

class ChatInitial extends ChatState {}

class ChatLoading extends ChatState {}

class ChatLoaded extends ChatState {
  final List<Message> messages;
  final String? errorMessage;

  const ChatLoaded(
    this.messages, {
    this.errorMessage,
  });

  ChatLoaded copyWith({
    List<Message>? messages,
    String? errorMessage,
  }) {
    return ChatLoaded(
      messages ?? this.messages,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [messages, errorMessage];
}

class ChatError extends ChatState {
  final String message;

  const ChatError(this.message);

  @override
  List<Object> get props => [message];
}
