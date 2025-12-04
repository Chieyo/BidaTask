import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

import '../models/chat_model.dart';
import '../data/chat_repository.dart';

part 'chat_list_state.dart';

class ChatListCubit extends Cubit<ChatListState> {
  final ChatRepository chatRepository;
  StreamSubscription? _chatsSubscription;

  ChatListCubit({required this.chatRepository}) : super(ChatListInitial());

  Future<void> loadChats() async {
    try {
      emit(ChatListLoading());
      
      _chatsSubscription?.cancel();
      _chatsSubscription = chatRepository
          .getChatsStream()
          .listen(
            (chats) => emit(ChatListLoaded(chats)),
            onError: (error) => emit(ChatListError(error.toString())),
          );
    } catch (e) {
      emit(ChatListError(e.toString()));
    }
  }

  Future<void> refresh() async {
    await loadChats();
  }

  @override
  Future<void> close() {
    _chatsSubscription?.cancel();
    return super.close();
  }
}
