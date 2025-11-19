part of 'chat_bloc.dart';

abstract class ChatState extends Equatable {
  const ChatState();

  @override
  List<Object> get props => [];
}

class ChatInitial extends ChatState {}

class ChatLoading extends ChatState {}

class ChatLoaded extends ChatState {
  final Chat chat;
  final List<Message> messages;
  final bool hasMoreMessages;
  final bool isTyping;

  const ChatLoaded({
    required this.chat,
    required this.messages,
    this.hasMoreMessages = true,
    this.isTyping = false,
  });

  ChatLoaded copyWith({
    Chat? chat,
    List<Message>? messages,
    bool? hasMoreMessages,
    bool? isTyping,
  }) {
    return ChatLoaded(
      chat: chat ?? this.chat,
      messages: messages ?? this.messages,
      hasMoreMessages: hasMoreMessages ?? this.hasMoreMessages,
      isTyping: isTyping ?? this.isTyping,
    );
  }

  @override
  List<Object> get props => [chat, messages, hasMoreMessages, isTyping];
}

class ChatError extends ChatState {
  final String message;

  const ChatError(this.message);

  @override
  List<Object> get props => [message];
}
