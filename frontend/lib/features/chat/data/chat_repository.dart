import '../models/chat_model.dart';

abstract class ChatRepository {
  Stream<List<Chat>> getChatsStream();
  
  Stream<List<Message>> getMessagesStream(String taskId);
  
  Future<void> sendMessage({
    required String taskId,
    required String content,
  });
  
  Future<void> markAsRead(String messageId, String taskId);
  
  Future<void> deleteMessage(String messageId, String taskId);
}
