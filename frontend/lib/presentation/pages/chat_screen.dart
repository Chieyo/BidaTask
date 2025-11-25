import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/chat.dart';
import '../../domain/repositories/chat_repository.dart';
import '../bloc/chat_bloc.dart';
import '../bloc/chat_list_cubit.dart';
import '../widgets/message_bubble.dart';

class ChatListPage extends StatefulWidget {
  const ChatListPage({super.key});

  @override
  State<ChatListPage> createState() => _ChatListPageState();
}

class _ChatListPageState extends State<ChatListPage> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FB),
      body: SafeArea(
        child: _currentIndex == 0
            ? const _ChatsTab()
            : Center(
                child: Text(
                  _currentIndex == 1 ? 'Friends coming soon' : 'Settings coming soon',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.chat_bubble_outline), label: 'Chats'),
          BottomNavigationBarItem(icon: Icon(Icons.group_outlined), label: 'Friends'),
          BottomNavigationBarItem(icon: Icon(Icons.settings_outlined), label: 'Settings'),
        ],
      ),
    );
  }
}

class _ChatsTab extends StatelessWidget {
  const _ChatsTab();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(onPressed: () {}, child: const Text('Edit')),
              Text(
                'Chats',
                style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
              ),
              IconButton(
                onPressed: () => context.read<ChatListCubit>().refresh(),
                icon: const Icon(Icons.edit_square, color: Color(0xFF007AFF)),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Search',
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: Colors.white,
              contentPadding: EdgeInsets.zero,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: BlocBuilder<ChatListCubit, ChatListState>(
            builder: (context, state) {
              switch (state.status) {
                case ChatListStatus.loading:
                  return const Center(child: CircularProgressIndicator());
                case ChatListStatus.error:
                  return _ChatListError(message: state.errorMessage ?? 'Failed to load chats.');
                case ChatListStatus.loaded:
                  if (state.chats.isEmpty) {
                    return const _EmptyChatsView();
                  }
                  return RefreshIndicator(
                    onRefresh: () => context.read<ChatListCubit>().refresh(),
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      itemBuilder: (context, index) {
                        final chat = state.chats[index];
                        return _ChatListTile(chat: chat);
                      },
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemCount: state.chats.length,
                    ),
                  );
                case ChatListStatus.initial:
                  return const SizedBox.shrink();
              }
            },
          ),
        ),
      ],
    );
  }
}

class _ChatListError extends StatelessWidget {
  const _ChatListError({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: () => context.read<ChatListCubit>().refresh(),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}

class _EmptyChatsView extends StatelessWidget {
  const _EmptyChatsView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.chat_outlined, size: 56, color: Colors.grey),
          const SizedBox(height: 12),
          Text(
            'No chats yet',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 4),
          const Text('Start a task to begin chatting.'),
        ],
      ),
    );
  }
}

class _ChatListTile extends StatelessWidget {
  const _ChatListTile({required this.chat});

  final Chat chat;

  @override
  Widget build(BuildContext context) {
    final lastMessage = chat.lastMessage;
    final preview = lastMessage?.content ?? chat.taskDescription;
    final timestamp = chat.lastMessageAt;
    final previewTime = _formatTimestamp(timestamp);
    final hasUnread = lastMessage != null && !lastMessage.isFromCurrentUser;

    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => ChatDetailPage(chat: chat)),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: const Color(0xFFE7ECF5),
              child: Text(
                chat.taskName.isNotEmpty ? chat.taskName[0].toUpperCase() : '?',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          chat.taskName,
                          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (previewTime != null)
                        Text(
                          previewTime,
                          style: const TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                      if (hasUnread)
                        Container(
                          margin: const EdgeInsets.only(left: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                          decoration: const BoxDecoration(
                            color: Color(0xFF007AFF),
                            borderRadius: BorderRadius.all(Radius.circular(12)),
                          ),
                          child: const Text(
                            'NEW',
                            style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    preview,
                    style: const TextStyle(color: Colors.black54),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String? _formatTimestamp(DateTime? timestamp) {
  if (timestamp == null) return null;
  final now = DateTime.now();
  final difference = now.difference(timestamp);
  if (difference.inDays == 0) {
    return DateFormat.jm().format(timestamp);
  }
  if (difference.inDays == 1) return 'Yesterday';
  if (difference.inDays < 7) {
    return DateFormat.E().format(timestamp);
  }
  return DateFormat.MMMd().format(timestamp);
}

class ChatDetailPage extends StatelessWidget {
  const ChatDetailPage({super.key, required this.chat});

  final Chat chat;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ChatBloc(chatRepository: context.read<ChatRepository>())
        ..add(LoadChat(chat.taskId)),
      child: _ChatDetailView(chat: chat),
    );
  }
}

class _ChatDetailView extends StatelessWidget {
  const _ChatDetailView({required this.chat});

  final Chat chat;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80),
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.of(context).maybePop(),
                  icon: const Icon(Icons.chevron_left, size: 30, color: Colors.black87),
                ),
                CircleAvatar(
                  radius: 22,
                  backgroundColor: const Color(0xFFE7ECF5),
                  child: Text(
                    chat.taskName.isNotEmpty ? chat.taskName[0].toUpperCase() : '?',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      chat.taskName,
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
                    ),
                    Text(
                      chat.status.name,
                      style: TextStyle(color: Colors.grey[600], fontSize: 13),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: BlocBuilder<ChatBloc, ChatState>(
              builder: (context, state) {
                if (state is ChatLoading || state is ChatInitial) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state is ChatError) {
                  return Center(child: Text(state.message));
                }
                final loaded = state as ChatLoaded;
                final messages = loaded.messages;
                if (messages.isEmpty) {
                  return const Center(child: Text('Say hello 👋'));
                }
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  reverse: true,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    return MessageBubble(
                      message: message,
                      isFromCurrentUser: message.isFromCurrentUser,
                    );
                  },
                );
              },
            ),
          ),
          BlocBuilder<ChatBloc, ChatState>(
            buildWhen: (previous, current) => false,
            builder: (context, state) {
              return _ChatComposer(taskId: chat.taskId);
            },
          ),
        ],
      ),
    );
  }
}

class _ChatComposer extends StatefulWidget {
  const _ChatComposer({required this.taskId});

  final String taskId;

  @override
  State<_ChatComposer> createState() => _ChatComposerState();
}

class _ChatComposerState extends State<_ChatComposer> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    context.read<ChatBloc>().add(SendMessage(taskId: widget.taskId, content: text));
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 16, right: 16, bottom: 24, top: 8),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 12)],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.add_circle_outline, color: Color(0xFF007AFF)),
            ),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F3F8),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: TextField(
                  controller: _controller,
                  decoration: const InputDecoration(
                    hintText: 'Type a message...',
                    border: InputBorder.none,
                  ),
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => _sendMessage(),
                ),
              ),
            ),
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.insert_emoticon, color: Color(0xFF8E8E93)),
            ),
            GestureDetector(
              onTap: _sendMessage,
              child: Container(
                width: 46,
                height: 46,
                decoration: const BoxDecoration(
                  color: Color(0xFF007AFF),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.send, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
