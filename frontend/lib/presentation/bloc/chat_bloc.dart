import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/message.dart';
import '../../domain/entities/chat.dart';
import '../../domain/repositories/chat_repository.dart';

part 'chat_event.dart';
part 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final ChatRepository _chatRepository;
  StreamSubscription<List<Message>>? _messagesSubscription;
  StreamSubscription<bool>? _typingSubscription;

  ChatBloc({required ChatRepository chatRepository})
      : _chatRepository = chatRepository,
        super(ChatInitial()) {
    on<LoadChat>(_onLoadChat);
    on<SendMessage>(_onSendMessage);
    on<SendImageMessage>(_onSendImageMessage);
    on<LoadMoreMessages>(_onLoadMoreMessages);
    on<MarkMessageAsRead>(_onMarkMessageAsRead);
    on<SendTypingIndicator>(_onSendTypingIndicator);
    on<UpdateMessages>(_onUpdateMessages);
    on<UpdateTypingIndicator>(_onUpdateTypingIndicator);
  }

  Future<void> _onLoadChat(LoadChat event, Emitter<ChatState> emit) async {
    emit(ChatLoading());
    
    try {
      // Get chat details
      final chatResult = await _chatRepository.getChatByTaskId(event.taskId);
      
      chatResult.fold(
        (error) {
          emit(ChatError(error));
        },
        (chat) async {
          // Get messages
          final messagesResult = await _chatRepository.getMessages(event.taskId);
          
          messagesResult.fold(
            (error) {
              emit(ChatError(error));
            },
            (messages) {
              emit(ChatLoaded(
                chat: chat,
                messages: messages,
                hasMoreMessages: messages.length >= 50,
              ));
              
              // Listen to message updates
              _subscribeToMessages(event.taskId);
              _subscribeToTypingIndicators(event.taskId);
            },
          );
        },
      );
    } catch (e) {
      emit(ChatError('Failed to load chat: $e'));
    }
  }

  Future<void> _onSendMessage(SendMessage event, Emitter<ChatState> emit) async {
    final currentState = state;
    if (currentState is! ChatLoaded) return;

    try {
      final result = await _chatRepository.sendMessage(
        event.taskId,
        event.content,
      );

      result.fold(
        (error) {
          emit(ChatError(error));
        },
        (message) {
          // Message will be added through the stream
        },
      );
    } catch (e) {
      emit(ChatError('Failed to send message: $e'));
    }
  }

  Future<void> _onSendImageMessage(SendImageMessage event, Emitter<ChatState> emit) async {
    final currentState = state;
    if (currentState is! ChatLoaded) return;

    try {
      // First upload the image
      final uploadResult = await _chatRepository.uploadImage(
        event.taskId,
        event.imagePath,
      );

      await uploadResult.fold(
        (error) {
          emit(ChatError(error));
        },
        (imageUrl) async {
          // Then send the message with the image URL
          final messageResult = await _chatRepository.sendMessage(
            event.taskId,
            '', // Empty content for image messages
            type: MessageType.image,
            imageUrl: imageUrl,
          );

          messageResult.fold(
            (error) {
              emit(ChatError(error));
            },
            (message) {
              // Message will be added through the stream
            },
          );
        },
      );
    } catch (e) {
      emit(ChatError('Failed to send image: $e'));
    }
  }

  Future<void> _onLoadMoreMessages(LoadMoreMessages event, Emitter<ChatState> emit) async {
    final currentState = state;
    if (currentState is! ChatLoaded || !currentState.hasMoreMessages) return;

    try {
      final lastMessageId = currentState.messages.isNotEmpty 
          ? currentState.messages.last.id 
          : null;
      
      final result = await _chatRepository.getMessages(
        event.taskId,
        lastMessageId: lastMessageId,
      );

      result.fold(
        (error) {
          emit(ChatError(error));
        },
        (newMessages) {
          final allMessages = [...currentState.messages, ...newMessages];
          emit(currentState.copyWith(
            messages: allMessages,
            hasMoreMessages: newMessages.length >= 50,
          ));
        },
      );
    } catch (e) {
      emit(ChatError('Failed to load more messages: $e'));
    }
  }

  Future<void> _onMarkMessageAsRead(MarkMessageAsRead event, Emitter<ChatState> emit) async {
    try {
      await _chatRepository.markMessageAsRead(event.messageId);
    } catch (e) {
      // Silently fail for read receipts
    }
  }

  Future<void> _onSendTypingIndicator(SendTypingIndicator event, Emitter<ChatState> emit) async {
    try {
      await _chatRepository.sendTypingIndicator(event.taskId, event.isTyping);
    } catch (e) {
      // Silently fail for typing indicators
    }
  }

  Future<void> _onUpdateMessages(UpdateMessages event, Emitter<ChatState> emit) async {
    final currentState = state;
    if (currentState is ChatLoaded) {
      emit(currentState.copyWith(messages: event.messages));
    }
  }

  Future<void> _onUpdateTypingIndicator(UpdateTypingIndicator event, Emitter<ChatState> emit) async {
    final currentState = state;
    if (currentState is ChatLoaded) {
      emit(currentState.copyWith(isTyping: event.isTyping));
    }
  }

  void _subscribeToMessages(String taskId) {
    _messagesSubscription = _chatRepository.getMessageStream(taskId).listen(
      (messages) {
        add(UpdateMessages(messages));
      },
    );
  }

  void _subscribeToTypingIndicators(String taskId) {
    _typingSubscription = _chatRepository.getTypingIndicatorStream(taskId).listen(
      (isTyping) {
        add(UpdateTypingIndicator(isTyping));
      },
    );
  }

  @override
  Future<void> close() {
    _messagesSubscription?.cancel();
    _typingSubscription?.cancel();
    return super.close();
  }
}
