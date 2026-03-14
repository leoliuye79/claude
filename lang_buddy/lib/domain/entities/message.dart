import 'correction.dart';

enum MessageType { text, voice, correction, systemNotice }

enum MessageStatus { sending, sent, failed }

enum MessageSender { user, agent }

class Message {
  final String id;
  final String conversationId;
  final MessageSender sender;
  final MessageType type;
  final String content;
  final String? audioPath;
  final int? audioDurationMs;
  final Correction? correction;
  final MessageStatus status;
  final DateTime createdAt;

  const Message({
    required this.id,
    required this.conversationId,
    required this.sender,
    required this.type,
    required this.content,
    this.audioPath,
    this.audioDurationMs,
    this.correction,
    this.status = MessageStatus.sent,
    required this.createdAt,
  });

  Message copyWith({
    String? id,
    String? conversationId,
    MessageSender? sender,
    MessageType? type,
    String? content,
    String? audioPath,
    int? audioDurationMs,
    Correction? correction,
    MessageStatus? status,
    DateTime? createdAt,
  }) {
    return Message(
      id: id ?? this.id,
      conversationId: conversationId ?? this.conversationId,
      sender: sender ?? this.sender,
      type: type ?? this.type,
      content: content ?? this.content,
      audioPath: audioPath ?? this.audioPath,
      audioDurationMs: audioDurationMs ?? this.audioDurationMs,
      correction: correction ?? this.correction,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
