import 'dart:convert';
import 'package:drift/drift.dart';
import '../../domain/entities/correction.dart';
import '../../domain/entities/message.dart';
import '../../domain/repositories/message_repository.dart';
import '../datasources/local/daos/message_dao.dart';
import '../datasources/local/database.dart';

class MessageRepositoryImpl implements MessageRepository {
  final MessageDao _dao;

  MessageRepositoryImpl(this._dao);

  @override
  Future<List<Message>> getMessages(String conversationId) async {
    final rows = await _dao.getByConversationId(conversationId);
    return rows.map(_toEntity).toList();
  }

  @override
  Stream<List<Message>> watchMessages(String conversationId) {
    return _dao.watchByConversationId(conversationId).map(
          (rows) => rows.map(_toEntity).toList(),
        );
  }

  @override
  Future<void> insertMessage(Message message) {
    return _dao.insertOne(_toCompanion(message));
  }

  @override
  Future<void> updateMessage(Message message) {
    return _dao.updateOne(_toCompanion(message));
  }

  @override
  Future<void> deleteMessage(String messageId) {
    return _dao.deleteById(messageId);
  }

  Message _toEntity(MessagesTableData row) {
    Correction? correction;
    if (row.correctionJson != null) {
      try {
        final json = jsonDecode(row.correctionJson!);
        correction = Correction(
          originalText: json['original'] as String,
          correctedText: json['corrected'] as String,
          details: (json['details'] as List).map((d) {
            return CorrectionDetail(
              incorrect: d['incorrect'] as String,
              correct: d['correct'] as String,
              explanationZh: d['explanation_zh'] as String,
              explanationEn: d['explanation_en'] as String,
              example: d['example'] as String?,
            );
          }).toList(),
        );
      } catch (_) {}
    }

    return Message(
      id: row.id,
      conversationId: row.conversationId,
      sender: row.sender == 'user' ? MessageSender.user : MessageSender.agent,
      type: MessageType.values.firstWhere(
        (t) => t.name == row.type,
        orElse: () => MessageType.text,
      ),
      content: row.content,
      audioPath: row.audioPath,
      audioDurationMs: row.audioDurationMs,
      correction: correction,
      status: MessageStatus.values.firstWhere(
        (s) => s.name == row.status,
        orElse: () => MessageStatus.sent,
      ),
      createdAt: row.createdAt,
    );
  }

  MessagesTableCompanion _toCompanion(Message message) {
    String? correctionJson;
    if (message.correction != null) {
      correctionJson = jsonEncode({
        'original': message.correction!.originalText,
        'corrected': message.correction!.correctedText,
        'details': message.correction!.details
            .map((d) => {
                  'incorrect': d.incorrect,
                  'correct': d.correct,
                  'explanation_zh': d.explanationZh,
                  'explanation_en': d.explanationEn,
                  'example': d.example,
                })
            .toList(),
      });
    }

    return MessagesTableCompanion(
      id: Value(message.id),
      conversationId: Value(message.conversationId),
      sender: Value(message.sender.name),
      type: Value(message.type.name),
      content: Value(message.content),
      audioPath: Value(message.audioPath),
      audioDurationMs: Value(message.audioDurationMs),
      correctionJson: Value(correctionJson),
      status: Value(message.status.name),
      createdAt: Value(message.createdAt),
    );
  }
}
