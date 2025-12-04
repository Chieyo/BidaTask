import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../bloc/chat_bloc.dart';
import '../models/chat_model.dart';

class FirebaseChatRepository implements ChatRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Stream<List<Message>> getMessagesStream(String taskId) {
    return _firestore
        .collection('tasks')
        .doc(taskId)
        .collection('messages')
        .orderBy('sentAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return Message(
          id: doc.id,
          chatId: taskId,
          senderId: data['senderId'],
          senderName: data['senderName'] ?? 'Unknown',
          content: data['content'],
          sentAt: (data['sentAt'] as Timestamp).toDate(),
          status: _parseMessageStatus(data['status'] ?? 'sent'),
          isFromCurrentUser: data['senderId'] == _auth.currentUser?.uid,
        );
      }).toList();
    });
  }

  @override
  Future<void> sendMessage({
    required String taskId,
    required String content,
  }) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('User not authenticated');
    }

    await _firestore
        .collection('tasks')
        .doc(taskId)
        .collection('messages')
        .add({
      'senderId': user.uid,
      'senderName': user.displayName ?? 'Anonymous',
      'content': content,
      'sentAt': FieldValue.serverTimestamp(),
      'status': 'sent',
    });

    // Update the last message timestamp in the task document
    await _firestore.collection('tasks').doc(taskId).update({
      'lastMessageAt': FieldValue.serverTimestamp(),
      'lastMessage': content,
    });
  }

  @override
  Stream<List<Chat>> getChatsStream() {
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      return const Stream.empty();
    }

    return _firestore
        .collection('tasks')
        .where('participants', arrayContains: userId)
        .orderBy('lastMessageAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return Chat(
          id: doc.id,
          taskId: doc.id,
          taskName: data['title'] ?? 'Untitled Task',
          taskDescription: data['description'] ?? '',
          lastMessageAt: (data['lastMessageAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
          lastMessage: data['lastMessage'] != null
              ? Message(
                  id: 'last-message',
                  chatId: doc.id,
                  senderId: data['lastMessageSenderId'] ?? '',
                  senderName: data['lastMessageSenderName'] ?? 'Unknown',
                  content: data['lastMessage'],
                  sentAt: (data['lastMessageAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
                  status: MessageStatus.sent,
                  isFromCurrentUser: data['lastMessageSenderId'] == userId,
                )
              : null,
          status: _parseChatStatus(data['status'] ?? 'active'),
          otherParticipantId: (data['participants'] as List<dynamic>?)
              ?.firstWhere(
                (id) => id != userId,
                orElse: () => null,
              )
              ?.toString(),
        );
      }).toList();
    });
  }

  MessageStatus _parseMessageStatus(String status) {
    switch (status.toLowerCase()) {
      case 'sending':
        return MessageStatus.sending;
      case 'sent':
        return MessageStatus.sent;
      case 'delivered':
        return MessageStatus.delivered;
      case 'read':
        return MessageStatus.read;
      case 'error':
        return MessageStatus.error;
      default:
        return MessageStatus.sent;
    }
  }

  ChatStatus _parseChatStatus(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return ChatStatus.active;
      case 'completed':
        return ChatStatus.completed;
      case 'cancelled':
        return ChatStatus.cancelled;
      case 'pending':
        return ChatStatus.pending;
      default:
        return ChatStatus.active;
    }
  }
}
