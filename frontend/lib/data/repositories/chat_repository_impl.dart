import 'dart:async';
import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import '../../domain/entities/chat.dart';
import '../../domain/entities/message.dart';
import '../../domain/repositories/chat_repository.dart';

class ChatRepositoryImpl implements ChatRepository {
  ChatRepositoryImpl({SupabaseClient? client, String storageBucket = 'chat-images'})
      : _client = client ?? Supabase.instance.client,
        _storageBucket = storageBucket;

  final SupabaseClient _client;
  final String _storageBucket;
  final Uuid _uuid = const Uuid();

  String? get _currentUserId => _client.auth.currentUser?.id;
  String? get _currentUserName =>
      (_client.auth.currentUser?.userMetadata?['full_name'] as String?) ??
      _client.auth.currentUser?.email ??
      'Unknown';
  String? get _currentUserAvatar => _client.auth.currentUser?.userMetadata?['avatar_url'] as String?;

  @override
  Future<Either<String, List<Message>>> getMessages(
    String taskId, {
    int limit = 50,
    String? lastMessageId,
  }) async {
    try {
      final currentUserId = _currentUserId;
      if (currentUserId == null) {
        return Left('User not authenticated');
      }

      PostgrestFilterBuilder query = _client
          .from('messages')
          .select()
          .eq('task_id', taskId);

      if (lastMessageId != null) {
        final lastMessage = await _client
            .from('messages')
            .select('created_at')
            .eq('id', lastMessageId)
            .maybeSingle();
        final lastCreatedAt = lastMessage?['created_at'] as String?;
        if (lastCreatedAt != null) {
          query = query.lt('created_at', lastCreatedAt);
        }
      }

      final rows = await query.order('created_at', ascending: false).limit(limit);
      final messages = rows
          .map<Message>((row) => _mapRowToMessage(row, currentUserId))
          .toList()
          .reversed
          .toList();

      return Right(messages);
    } catch (e) {
      return Left('Failed to get messages: $e');
    }
  }

  @override
  Future<Either<String, Message>> sendMessage(
    String taskId,
    String content, {
    MessageType type = MessageType.text,
    String? imageUrl,
  }) async {
    try {
      final currentUserId = _currentUserId;
      if (currentUserId == null) {
        return Left('User not authenticated');
      }

      final now = DateTime.now().toUtc();
      final messageId = _uuid.v4();
      final payload = {
        'id': messageId,
        'task_id': taskId,
        'sender_id': currentUserId,
        'sender_name': _currentUserName,
        'sender_avatar': _currentUserAvatar,
        'content': content,
        'type': type.name,
        'status': MessageStatus.sent.name,
        'image_url': imageUrl,
        'created_at': now.toIso8601String(),
      };

      final row = await _client.from('messages').insert(payload).select().single();

      await _client.from('tasks').update({
        'last_message_at': row['created_at'],
        'last_message': row,
      }).eq('id', taskId);

      return Right(_mapRowToMessage(row, currentUserId));
    } catch (e) {
      return Left('Failed to send message: $e');
    }
  }

  @override
  Future<Either<String, void>> markMessageAsRead(String messageId) async {
    try {
      await _client
          .from('messages')
          .update({'status': MessageStatus.read.name})
          .eq('id', messageId);
      return Right(null);
    } catch (e) {
      return Left('Failed to mark message as read: $e');
    }
  }

  @override
  Future<Either<String, void>> sendTypingIndicator(String taskId, bool isTyping) async {
    try {
      final currentUserId = _currentUserId;
      if (currentUserId == null) {
        return Left('User not authenticated');
      }

      await _client.from('task_typing_status').upsert({
        'task_id': taskId,
        'user_id': currentUserId,
        'is_typing': isTyping,
        'updated_at': DateTime.now().toUtc().toIso8601String(),
      });

      return Right(null);
    } catch (e) {
      return Left('Failed to send typing indicator: $e');
    }
  }

  @override
  Stream<List<Message>> getMessageStream(String taskId) {
    final currentUserId = _currentUserId;
    return _client
        .from('messages')
        .stream(primaryKey: ['id'])
        .eq('task_id', taskId)
        .order('created_at')
        .map((rows) => rows
            .map<Message>((row) => _mapRowToMessage(row, currentUserId))
            .toList());
  }

  @override
  Stream<bool> getTypingIndicatorStream(String taskId) {
    final currentUserId = _currentUserId;
    if (currentUserId == null) {
      return Stream<bool>.value(false);
    }

    return _client
        .from('task_typing_status')
        .stream(primaryKey: ['task_id', 'user_id'])
        .eq('task_id', taskId)
        .map((rows) {
      return rows.any((row) =>
          row['user_id'] != currentUserId && (row['is_typing'] as bool? ?? false));
    });
  }

  @override
  Future<Either<String, Chat>> getChatByTaskId(String taskId) async {
    try {
      final currentUserId = _currentUserId;
      if (currentUserId == null) {
        return Left('User not authenticated');
      }

      final row = await _client.from('tasks').select().eq('id', taskId).maybeSingle();
      if (row == null) {
        return Left('Task not found');
      }

      final participants = _parseParticipants(row['participants']);
      if (!participants.contains(currentUserId)) {
        return Left('Access denied: You are not a participant in this task');
      }

      final status = row['status'] as String?;
      if (status != null && status != 'active' && status != 'in_progress') {
        return Left('Chat is only available for active tasks');
      }

      return Right(_mapTaskRowToChat(row, currentUserId));
    } catch (e) {
      return Left('Failed to load chats: $e');
    }
  }

  @override
  Future<Either<String, List<Chat>>> getUserChats({int limit = 50}) async {
    try {
      final currentUserId = _currentUserId;
      if (currentUserId == null) {
        return Left('User not authenticated');
      }

      final rows = await _client
          .from('tasks')
          .select()
          .contains('participants', [currentUserId])
          .order('last_message_at', ascending: false)
          .limit(limit);

      final chats = rows.map<Chat>((row) => _mapTaskRowToChat(row, currentUserId)).toList();
      return Right(chats);
    } catch (e) {
      return Left('Failed to load chats: $e');
    }
  }

  @override
  Stream<List<Chat>> getUserChatsStream({int limit = 50}) {
    final currentUserId = _currentUserId;
    if (currentUserId == null) {
      return Stream<List<Chat>>.empty();
    }

    return _client
        .from('tasks')
        .stream(primaryKey: ['id'])
        .order('last_message_at', ascending: false)
        .map((rows) {
      final filtered = rows.where((row) {
        final participants = _parseParticipants(row['participants']);
        return participants.contains(currentUserId);
      }).take(limit);

      return filtered.map((row) => _mapTaskRowToChat(row, currentUserId)).toList();
    });
  }

  Chat _mapTaskRowToChat(Map<String, dynamic> row, String? currentUserId) {
    return Chat(
      id: row['id']?.toString() ?? '',
      taskId: row['id']?.toString() ?? '',
      taskName: row['title']?.toString() ?? 'Unknown Task',
      taskDescription: row['description']?.toString() ?? '',
      participants: _parseParticipants(row['participants']),
      requesterId: row['requester_id']?.toString() ?? '',
      taskerId: row['tasker_id']?.toString() ?? '',
      createdAt: _parseDateTime(row['created_at']) ?? DateTime.now(),
      lastMessageAt: _parseDateTime(row['last_message_at']),
      lastMessage: _mapEmbeddedMessage(row['id']?.toString() ?? '', row['last_message'], currentUserId),
      status: _parseStatus(row['status']?.toString()),
      isTyping: row['is_typing'] as bool? ?? false,
      typingUserId: row['typing_user_id']?.toString(),
    );
  }

  List<String> _parseParticipants(dynamic raw) {
    if (raw is List) {
      return raw.map((participant) => participant.toString()).toList();
    }
    return const <String>[];
  }

  ChatStatus _parseStatus(String? raw) {
    switch (raw) {
      case 'ended':
        return ChatStatus.ended;
      case 'archived':
        return ChatStatus.archived;
      default:
        return ChatStatus.active;
    }
  }

  Message? _mapEmbeddedMessage(String taskId, dynamic raw, String? currentUserId) {
    if (raw is! Map<String, dynamic>) return null;
    return Message(
      id: raw['id']?.toString() ?? '',
      taskId: taskId,
      senderId: raw['sender_id']?.toString() ?? '',
      senderName: raw['sender_name']?.toString() ?? '',
      senderAvatar: raw['sender_avatar']?.toString(),
      content: raw['content']?.toString() ?? '',
      type: _parseMessageType(raw['type']?.toString()),
      timestamp: _parseDateTime(raw['created_at']) ?? DateTime.now(),
      status: _parseMessageStatus(raw['status']?.toString()),
      isFromCurrentUser: raw['sender_id']?.toString() == currentUserId,
      imageUrl: raw['image_url']?.toString(),
    );
  }

  Message _mapRowToMessage(Map<String, dynamic> row, String? currentUserId) {
    return Message(
      id: row['id']?.toString() ?? '',
      taskId: row['task_id']?.toString() ?? '',
      senderId: row['sender_id']?.toString() ?? '',
      senderName: row['sender_name']?.toString() ?? 'Unknown',
      senderAvatar: row['sender_avatar']?.toString(),
      content: row['content']?.toString() ?? '',
      type: _parseMessageType(row['type']?.toString()),
      timestamp: _parseDateTime(row['created_at']) ?? DateTime.now(),
      status: _parseMessageStatus(row['status']?.toString()),
      isFromCurrentUser: row['sender_id']?.toString() == currentUserId,
      imageUrl: row['image_url']?.toString(),
    );
  }

  MessageType _parseMessageType(String? raw) {
    switch (raw) {
      case 'MessageType.image':
      case 'image':
        return MessageType.image;
      case 'MessageType.system':
      case 'system':
        return MessageType.system;
      default:
        return MessageType.text;
    }
  }

  MessageStatus _parseMessageStatus(String? raw) {
    switch (raw) {
      case 'MessageStatus.delivered':
      case 'delivered':
        return MessageStatus.delivered;
      case 'MessageStatus.read':
      case 'read':
        return MessageStatus.read;
      default:
        return MessageStatus.sent;
    }
  }

  DateTime? _parseDateTime(dynamic raw) {
    if (raw is String) {
      return DateTime.tryParse(raw)?.toLocal();
    }
    if (raw is DateTime) {
      return raw;
    }
    return null;
  }

  @override
  Future<Either<String, String>> uploadImage(String taskId, String filePath) async {
    try {
      final file = File(filePath);
      if (!file.existsSync()) {
        return Left('File not found');
      }

      final bytes = await file.readAsBytes();
      final objectPath = 'chat-images/$taskId/${DateTime.now().millisecondsSinceEpoch}_${file.uri.pathSegments.last}';

      await _client.storage.from(_storageBucket).uploadBinary(
            objectPath,
            bytes,
            fileOptions: const FileOptions(upsert: false),
          );

      final publicUrl = _client.storage.from(_storageBucket).getPublicUrl(objectPath);
      return Right(publicUrl);
    } catch (e) {
      return Left('Failed to upload image: $e');
    }
  }
}
