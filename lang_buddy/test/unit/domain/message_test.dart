import 'package:flutter_test/flutter_test.dart';
import 'package:lang_buddy/domain/entities/message.dart';
import 'package:lang_buddy/domain/entities/correction.dart';

void main() {
  group('MessageType', () {
    test('has all 4 values', () {
      expect(MessageType.values.length, 4);
      expect(MessageType.values, contains(MessageType.text));
      expect(MessageType.values, contains(MessageType.voice));
      expect(MessageType.values, contains(MessageType.correction));
      expect(MessageType.values, contains(MessageType.systemNotice));
    });
  });

  group('MessageStatus', () {
    test('has all 3 values', () {
      expect(MessageStatus.values.length, 3);
      expect(MessageStatus.values, contains(MessageStatus.sending));
      expect(MessageStatus.values, contains(MessageStatus.sent));
      expect(MessageStatus.values, contains(MessageStatus.failed));
    });
  });

  group('MessageSender', () {
    test('has user and agent', () {
      expect(MessageSender.values.length, 2);
      expect(MessageSender.values, contains(MessageSender.user));
      expect(MessageSender.values, contains(MessageSender.agent));
    });
  });

  group('Message', () {
    late Message message;
    final now = DateTime.now();

    setUp(() {
      message = Message(
        id: 'msg_1',
        conversationId: 'conv_1',
        sender: MessageSender.user,
        type: MessageType.text,
        content: 'Hello world',
        createdAt: now,
      );
    });

    test('creates with required fields', () {
      expect(message.id, 'msg_1');
      expect(message.conversationId, 'conv_1');
      expect(message.sender, MessageSender.user);
      expect(message.type, MessageType.text);
      expect(message.content, 'Hello world');
      expect(message.createdAt, now);
    });

    test('has correct default values', () {
      expect(message.audioPath, isNull);
      expect(message.audioDurationMs, isNull);
      expect(message.correction, isNull);
      expect(message.status, MessageStatus.sent);
    });

    test('creates voice message with audio fields', () {
      final voiceMsg = Message(
        id: 'msg_2',
        conversationId: 'conv_1',
        sender: MessageSender.user,
        type: MessageType.voice,
        content: 'transcribed text',
        audioPath: '/audio/voice1.m4a',
        audioDurationMs: 5000,
        createdAt: now,
      );
      expect(voiceMsg.type, MessageType.voice);
      expect(voiceMsg.audioPath, '/audio/voice1.m4a');
      expect(voiceMsg.audioDurationMs, 5000);
    });

    test('creates message with correction', () {
      final correction = Correction(
        originalText: 'I goes to school',
        correctedText: 'I go to school',
        details: [
          CorrectionDetail(
            incorrect: 'goes',
            correct: 'go',
            explanationZh: '第一人称用动词原形',
            explanationEn: 'Use base form with first person',
            example: 'I go to school every day.',
          ),
        ],
      );

      final corrMsg = Message(
        id: 'msg_3',
        conversationId: 'conv_1',
        sender: MessageSender.agent,
        type: MessageType.correction,
        content: 'I go to school',
        correction: correction,
        createdAt: now,
      );

      expect(corrMsg.correction, isNotNull);
      expect(corrMsg.correction!.originalText, 'I goes to school');
      expect(corrMsg.correction!.details.length, 1);
    });

    test('copyWith updates specified fields', () {
      final updated = message.copyWith(
        content: 'Updated content',
        status: MessageStatus.failed,
      );
      expect(updated.content, 'Updated content');
      expect(updated.status, MessageStatus.failed);
      expect(updated.id, 'msg_1');
      expect(updated.sender, MessageSender.user);
    });

    test('copyWith preserves all fields when no args', () {
      final copy = message.copyWith();
      expect(copy.id, message.id);
      expect(copy.conversationId, message.conversationId);
      expect(copy.sender, message.sender);
      expect(copy.type, message.type);
      expect(copy.content, message.content);
      expect(copy.status, message.status);
      expect(copy.createdAt, message.createdAt);
    });
  });

  group('Correction', () {
    test('creates with details', () {
      final correction = Correction(
        originalText: 'She go home',
        correctedText: 'She goes home',
        details: [
          CorrectionDetail(
            incorrect: 'go',
            correct: 'goes',
            explanationZh: '第三人称单数加s',
            explanationEn: 'Third person singular needs -s ending',
            example: 'She goes home after work.',
          ),
        ],
      );

      expect(correction.originalText, 'She go home');
      expect(correction.correctedText, 'She goes home');
      expect(correction.details.length, 1);
      expect(correction.details[0].incorrect, 'go');
      expect(correction.details[0].correct, 'goes');
      expect(correction.details[0].explanationZh, isNotEmpty);
      expect(correction.details[0].explanationEn, isNotEmpty);
      expect(correction.details[0].example, isNotNull);
    });

    test('CorrectionDetail works without example', () {
      final detail = CorrectionDetail(
        incorrect: 'goed',
        correct: 'went',
        explanationZh: '不规则动词',
        explanationEn: 'Irregular verb',
      );
      expect(detail.example, isNull);
    });
  });
}
