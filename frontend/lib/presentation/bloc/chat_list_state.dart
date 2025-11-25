part of 'chat_list_cubit.dart';

enum ChatListStatus { initial, loading, loaded, error }

class ChatListState extends Equatable {
  const ChatListState({
    this.status = ChatListStatus.initial,
    this.chats = const [],
    this.errorMessage,
  });

  final ChatListStatus status;
  final List<Chat> chats;
  final String? errorMessage;

  ChatListState copyWith({
    ChatListStatus? status,
    List<Chat>? chats,
    String? errorMessage,
  }) {
    return ChatListState(
      status: status ?? this.status,
      chats: chats ?? this.chats,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, chats, errorMessage];
}
