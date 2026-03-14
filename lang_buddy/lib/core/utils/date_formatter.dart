import 'package:intl/intl.dart';

class DateFormatter {
  DateFormatter._();

  static String formatChatTime(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDay = DateTime(dateTime.year, dateTime.month, dateTime.day);
    final difference = today.difference(messageDay).inDays;

    if (difference == 0) {
      return DateFormat('HH:mm').format(dateTime);
    } else if (difference == 1) {
      return '昨天 ${DateFormat('HH:mm').format(dateTime)}';
    } else if (difference < 7) {
      const weekdays = ['周一', '周二', '周三', '周四', '周五', '周六', '周日'];
      return weekdays[dateTime.weekday - 1];
    } else {
      return DateFormat('MM/dd').format(dateTime);
    }
  }

  static String formatConversationTime(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDay = DateTime(dateTime.year, dateTime.month, dateTime.day);
    final difference = today.difference(messageDay).inDays;

    if (difference == 0) {
      return DateFormat('HH:mm').format(dateTime);
    } else if (difference == 1) {
      return '昨天';
    } else if (difference < 7) {
      const weekdays = ['周一', '周二', '周三', '周四', '周五', '周六', '周日'];
      return weekdays[dateTime.weekday - 1];
    } else {
      return DateFormat('MM/dd').format(dateTime);
    }
  }
}
