import 'package:dartz/dartz.dart';
import '../entities/chat.dart';
import '../entities/message.dart';

abstract class ChatRepository {
  Future<Either<String, List<Message>>> getMessages(String taskId, {int limit = 50, String? lastMessageId});
  Future<Either<String, Message>> sendMessage(String taskId, String content, {MessageType type = MessageType.text, String? imageUrl});
  Future<Either<String, void>> markMessageAsRead(String messageId);
  Future<Either<String, void>> sendTypingIndicator(String taskId, bool isTyping);
  Stream<List<Message>> getMessageStream(String taskId);
  Stream<bool> getTypingIndicatorStream(String taskId);
  Future<Either<String, Chat>> getChatByTaskId(String taskId);
  Future<Either<String, String>> uploadImage(String taskId, String filePath);
}
