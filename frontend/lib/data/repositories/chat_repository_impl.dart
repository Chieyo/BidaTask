import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart' as firestore;
import 'package:firebase_database/firebase_database.dart' as database;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:dartz/dartz.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../../domain/entities/message.dart';
import '../../domain/entities/chat.dart';
import '../../domain/repositories/chat_repository.dart';

class ChatRepositoryImpl implements ChatRepository {
  final firestore.FirebaseFirestore _firestore = firestore.FirebaseFirestore.instance;
  final database.FirebaseDatabase _database = database.FirebaseDatabase.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Future<Either<String, List<Message>>> getMessages(
    String taskId, {
    int limit = 50,
    String? lastMessageId,
  }) async {
    try {
      firestore.Query query = _firestore
          .collection('tasks')
          .doc(taskId)
          .collection('messages')
          .orderBy('timestamp', descending: true)
          .limit(limit);

      if (lastMessageId != null) {
        query = query.startAfterDocument(
          await _firestore.collection('tasks').doc(taskId).collection('messages').doc(lastMessageId).get(),
        );
      }

      firestore.QuerySnapshot snapshot = await query.get();
      
      List<Message> messages = snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return Message(
          id: doc.id,
          taskId: taskId,
          senderId: data['senderId'],
          senderName: data['senderName'],
          senderAvatar: data['senderAvatar'],
          content: data['content'],
          type: MessageType.values.firstWhere(
            (type) => type.toString() == data['type'],
            orElse: () => MessageType.text,
          ),
          timestamp: (data['timestamp'] as firestore.Timestamp).toDate(),
          status: MessageStatus.values.firstWhere(
            (status) => status.toString() == data['status'],
            orElse: () => MessageStatus.sent,
          ),
          isFromCurrentUser: data['senderId'] == _auth.currentUser?.uid,
          imageUrl: data['imageUrl'],
        );
      }).toList();

      return Right(messages.reversed.toList());
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
      String? currentUserId = _auth.currentUser?.uid;
      if (currentUserId == null) {
        return Left('User not authenticated');
      }

      firestore.DocumentReference messageRef = _firestore
          .collection('tasks')
          .doc(taskId)
          .collection('messages')
          .doc();

      Message message = Message(
        id: messageRef.id,
        taskId: taskId,
        senderId: currentUserId,
        senderName: _auth.currentUser?.displayName ?? 'Unknown',
        senderAvatar: _auth.currentUser?.photoURL,
        content: content,
        type: type,
        timestamp: DateTime.now(),
        status: MessageStatus.sent,
        isFromCurrentUser: true,
        imageUrl: imageUrl,
      );

      await messageRef.set({
        'senderId': message.senderId,
        'senderName': message.senderName,
        'senderAvatar': message.senderAvatar,
        'content': message.content,
        'type': message.type.toString(),
        'timestamp': firestore.Timestamp.fromDate(message.timestamp),
        'status': message.status.toString(),
        'imageUrl': message.imageUrl,
      });

      return Right(message);
    } catch (e) {
      return Left('Failed to send message: $e');
    }
  }

  @override
  Future<Either<String, void>> markMessageAsRead(String messageId) async {
    try {
      await _firestore.collection('messages').doc(messageId).update({
        'status': MessageStatus.read.toString(),
      });
      return Right(null);
    } catch (e) {
      return Left('Failed to mark message as read: $e');
    }
  }

  @override
  Future<Either<String, void>> sendTypingIndicator(String taskId, bool isTyping) async {
    try {
      String? currentUserId = _auth.currentUser?.uid;
      if (currentUserId == null) return Left('User not authenticated');

      await _database.ref('tasks/$taskId/typing').set({
        currentUserId: isTyping,
        'timestamp': database.ServerValue.timestamp,
      });

      return Right(null);
    } catch (e) {
      return Left('Failed to send typing indicator: $e');
    }
  }

  @override
  Stream<List<Message>> getMessageStream(String taskId) {
    return _firestore
        .collection('tasks')
        .doc(taskId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data();
        return Message(
          id: doc.id,
          taskId: taskId,
          senderId: data['senderId'],
          senderName: data['senderName'],
          senderAvatar: data['senderAvatar'],
          content: data['content'],
          type: MessageType.values.firstWhere(
            (type) => type.toString() == data['type'],
            orElse: () => MessageType.text,
          ),
          timestamp: (data['timestamp'] as firestore.Timestamp).toDate(),
          status: MessageStatus.values.firstWhere(
            (status) => status.toString() == data['status'],
            orElse: () => MessageStatus.sent,
          ),
          isFromCurrentUser: data['senderId'] == _auth.currentUser?.uid,
          imageUrl: data['imageUrl'],
        );
      }).toList();
    });
  }

  @override
  Stream<bool> getTypingIndicatorStream(String taskId) {
    return _database.ref('tasks/$taskId/typing').onValue.map((event) {
      Map<dynamic, dynamic>? data = event.snapshot.value as Map<dynamic, dynamic>?;
      if (data == null) return false;

      String? currentUserId = _auth.currentUser?.uid;
      if (currentUserId == null) return false;

      bool isOtherUserTyping = false;
      data.forEach((key, value) {
        if (key != currentUserId && value == true) {
          isOtherUserTyping = true;
        }
      });

      return isOtherUserTyping;
    });
  }

  @override
  Future<Either<String, Chat>> getChatByTaskId(String taskId) async {
    try {
      String? currentUserId = _auth.currentUser?.uid;
      if (currentUserId == null) {
        return Left('User not authenticated');
      }

      firestore.DocumentSnapshot taskDoc = await _firestore.collection('tasks').doc(taskId).get();
      if (!taskDoc.exists) {
        return Left('Task not found');
      }

      Map<String, dynamic> taskData = taskDoc.data() as Map<String, dynamic>;
      
      // Check if user is a participant (client or provider)
      String? clientId = taskData['clientId'];
      String? providerId = taskData['providerId'];
      
      if (clientId != currentUserId && providerId != currentUserId) {
        return Left('Access denied: You are not a participant in this task');
      }
      
      // Check if task is active
      String? status = taskData['status'];
      if (status != 'active' && status != 'in_progress') {
        return Left('Chat is only available for active tasks');
      }
      
      firestore.QuerySnapshot messagesSnapshot = await _firestore
          .collection('tasks')
          .doc(taskId)
          .collection('messages')
          .orderBy('timestamp', descending: true)
          .limit(1)
          .get();

      Message? lastMessage;
      if (messagesSnapshot.docs.isNotEmpty) {
        firestore.DocumentSnapshot lastMessageDoc = messagesSnapshot.docs.first;
        Map<String, dynamic> messageData = lastMessageDoc.data() as Map<String, dynamic>;
        lastMessage = Message(
          id: lastMessageDoc.id,
          taskId: taskId,
          senderId: messageData['senderId'],
          senderName: messageData['senderName'],
          senderAvatar: messageData['senderAvatar'],
          content: messageData['content'],
          type: MessageType.values.firstWhere(
            (type) => type.toString() == messageData['type'],
            orElse: () => MessageType.text,
          ),
          timestamp: (messageData['timestamp'] as firestore.Timestamp).toDate(),
          status: MessageStatus.values.firstWhere(
            (status) => status.toString() == messageData['status'],
            orElse: () => MessageStatus.sent,
          ),
          isFromCurrentUser: messageData['senderId'] == _auth.currentUser?.uid,
          imageUrl: messageData['imageUrl'],
        );
      }

      Chat chat = Chat(
        id: taskId,
        taskId: taskId,
        taskName: taskData['title'] ?? 'Unknown Task',
        taskDescription: taskData['description'] ?? '',
        participants: List<String>.from(taskData['participants'] ?? []),
        requesterId: taskData['requesterId'] ?? '',
        taskerId: taskData['taskerId'] ?? '',
        createdAt: (taskData['createdAt'] as firestore.Timestamp?)?.toDate() ?? DateTime.now(),
        lastMessageAt: lastMessage?.timestamp,
        lastMessage: lastMessage,
        status: ChatStatus.active,
      );

      return Right(chat);
    } catch (e) {
      return Left('Failed to get chat: $e');
    }
  }

  @override
  Future<Either<String, String>> uploadImage(String taskId, String filePath) async {
    try {
      File file = File(filePath);
      String fileName = '${taskId}_${DateTime.now().millisecondsSinceEpoch}';
      
      Reference ref = _storage.ref().child('chat_images/$fileName');
      UploadTask uploadTask = ref.putFile(file);
      
      TaskSnapshot snapshot = await uploadTask;
      String downloadUrl = await snapshot.ref.getDownloadURL();
      
      return Right(downloadUrl);
    } catch (e) {
      return Left('Failed to upload image: $e');
    }
  }
}
