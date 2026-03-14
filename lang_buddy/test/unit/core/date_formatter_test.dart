import 'package:flutter_test/flutter_test.dart';
import 'package:lang_buddy/core/utils/date_formatter.dart';

void main() {
  group('DateFormatter.formatChatTime', () {
    test('returns HH:mm for today', () {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day, 14, 30);
      final result = DateFormatter.formatChatTime(today);
      expect(result, '14:30');
    });

    test('returns 昨天 HH:mm for yesterday', () {
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      final dt = DateTime(yesterday.year, yesterday.month, yesterday.day, 9, 15);
      final result = DateFormatter.formatChatTime(dt);
      expect(result, startsWith('昨天'));
      expect(result, contains('09:15'));
    });

    test('returns weekday name for 2-6 days ago', () {
      final twoDaysAgo = DateTime.now().subtract(const Duration(days: 2));
      final dt = DateTime(
          twoDaysAgo.year, twoDaysAgo.month, twoDaysAgo.day, 10, 0);
      final result = DateFormatter.formatChatTime(dt);
      expect(
        result,
        anyOf([
          '周一', '周二', '周三', '周四', '周五', '周六', '周日',
        ]),
      );
    });

    test('returns MM/dd for older messages', () {
      final oldDate = DateTime.now().subtract(const Duration(days: 30));
      final dt = DateTime(oldDate.year, oldDate.month, oldDate.day, 8, 0);
      final result = DateFormatter.formatChatTime(dt);
      expect(result, matches(RegExp(r'\d{2}/\d{2}')));
    });
  });

  group('DateFormatter.formatConversationTime', () {
    test('returns HH:mm for today', () {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day, 18, 45);
      final result = DateFormatter.formatConversationTime(today);
      expect(result, '18:45');
    });

    test('returns 昨天 for yesterday', () {
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      final dt = DateTime(yesterday.year, yesterday.month, yesterday.day, 10, 0);
      final result = DateFormatter.formatConversationTime(dt);
      expect(result, '昨天');
    });

    test('returns weekday name for 2-6 days ago', () {
      final threeDaysAgo = DateTime.now().subtract(const Duration(days: 3));
      final dt = DateTime(
          threeDaysAgo.year, threeDaysAgo.month, threeDaysAgo.day, 10, 0);
      final result = DateFormatter.formatConversationTime(dt);
      expect(
        result,
        anyOf([
          '周一', '周二', '周三', '周四', '周五', '周六', '周日',
        ]),
      );
    });

    test('returns MM/dd for older conversations', () {
      final oldDate = DateTime.now().subtract(const Duration(days: 14));
      final dt = DateTime(oldDate.year, oldDate.month, oldDate.day, 12, 0);
      final result = DateFormatter.formatConversationTime(dt);
      expect(result, matches(RegExp(r'\d{2}/\d{2}')));
    });

    test('conversation time is shorter than chat time for yesterday', () {
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      final dt = DateTime(yesterday.year, yesterday.month, yesterday.day, 14, 30);
      final chatTime = DateFormatter.formatChatTime(dt);
      final convTime = DateFormatter.formatConversationTime(dt);
      // Chat time includes HH:mm, conversation time just says 昨天
      expect(chatTime.length, greaterThan(convTime.length));
    });
  });
}
