import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../domain/entities/chat.dart';
import '../../domain/repositories/chat_repository.dart';

part 'chat_list_state.dart';

class ChatListCubit extends Cubit<ChatListState> {
  ChatListCubit({required ChatRepository chatRepository})
      : _chatRepository = chatRepository,
        super(const ChatListState());

  final ChatRepository _chatRepository;
  StreamSubscription<List<Chat>>? _subscription;

  void subscribeToChats({int limit = 50}) {
    emit(state.copyWith(status: ChatListStatus.loading, errorMessage: null));
    _subscription?.cancel();
    _subscription = _chatRepository.getUserChatsStream(limit: limit).listen(
      (chats) {
        emit(state.copyWith(status: ChatListStatus.loaded, chats: chats));
      },
      onError: (error) {
        emit(
          state.copyWith(
            status: ChatListStatus.error,
            errorMessage: error.toString(),
          ),
        );
      },
    );
  }

  Future<void> refresh({int limit = 50}) async {
    emit(state.copyWith(status: ChatListStatus.loading, errorMessage: null));
    final result = await _chatRepository.getUserChats(limit: limit);
    result.fold(
      (error) => emit(state.copyWith(status: ChatListStatus.error, errorMessage: error)),
      (chats) => emit(state.copyWith(status: ChatListStatus.loaded, chats: chats)),
    );
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
