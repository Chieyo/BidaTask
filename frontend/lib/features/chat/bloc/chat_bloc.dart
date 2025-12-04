import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

import '../models/chat_model.dart';

part 'chat_event.dart';
part 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final ChatRepository chatRepository;
  StreamSubscription? _messagesSubscription;

  ChatBloc({required this.chatRepository}) : super(ChatInitial()) {
    on<LoadChat>(_onLoadChat);
    on<SendMessage>(_onSendMessage);
    on<MessagesUpdated>(_onMessagesUpdated);
    on<MessageSent>(_onMessageSent);
    on<MessageError>(_onMessageError);
  }

  Future<void> _onLoadChat(LoadChat event, Emitter<ChatState> emit) async {
    try {
      emit(ChatLoading());
      
      // Load chat messages
      _messagesSubscription?.cancel();
      _messagesSubscription = chatRepository
          .getMessagesStream(event.taskId)
          .listen(
            (messages) => add(MessagesUpdated(messages)),
            onError: (error) => add(MessageError(error.toString())),
          );
    } catch (e) {
      emit(ChatError(e.toString()));
    }
  }

  Future<void> _onSendMessage(SendMessage event, Emitter<ChatState> emit) async {
    if (state is! ChatLoaded) return;
    
    final currentState = state as ChatLoaded;
    final message = Message(
      id: 'temp-${DateTime.now().millisecondsSinceEpoch}',
      chatId: event.taskId,
      senderId: 'current_user_id', // Replace with actual user ID
      senderName: 'You', // Replace with actual user name
      content: event.content,
      sentAt: DateTime.now(),
      status: MessageStatus.sending,
      isFromCurrentUser: true,
    );

    // Optimistically add message
    emit(currentState.copyWith(
      messages: [message, ...currentState.messages],
    ));

    try {
      await chatRepository.sendMessage(
        taskId: event.taskId,
        content: event.content,
      );
      add(MessageSent(message.copyWith(status: MessageStatus.sent)));
    } catch (e) {
      add(MessageError('Failed to send message'));
    }
  }

  void _onMessagesUpdated(MessagesUpdated event, Emitter<ChatState> emit) {
    if (state is ChatLoaded) {
      emit((state as ChatLoaded).copyWith(messages: event.messages));
    } else {
      emit(ChatLoaded(event.messages));
    }
  }

  void _onMessageSent(MessageSent event, Emitter<ChatState> emit) {
    if (state is ChatLoaded) {
      final currentState = state as ChatLoaded;
      final updatedMessages = currentState.messages.map((msg) {
        return msg.id == event.message.id ? event.message : msg;
      }).toList();
      
      emit(currentState.copyWith(messages: updatedMessages));
    }
  }

  void _onMessageError(MessageError event, Emitter<ChatState> emit) {
    if (state is ChatLoaded) {
      final currentState = state as ChatLoaded;
      emit(currentState.copyWith(errorMessage: event.message));
      // Optionally, you could revert the optimistic update here
    } else {
      emit(ChatError(event.message));
    }
  }

  @override
  Future<void> close() {
    _messagesSubscription?.cancel();
    return super.close();
  }
}

// Chat Repository Interface
abstract class ChatRepository {
  Stream<List<Message>> getMessagesStream(String taskId);
  Future<void> sendMessage({required String taskId, required String content});
}
