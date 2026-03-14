import '../entities/message.dart';

abstract class MessageRepository {
  Future<List<Message>> getMessages(String conversationId);
  Stream<List<Message>> watchMessages(String conversationId);
  Future<void> insertMessage(Message message);
  Future<void> updateMessage(Message message);
  Future<void> deleteMessage(String messageId);
}
