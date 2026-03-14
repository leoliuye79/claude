import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lang_buddy/core/constants/app_colors.dart';
import 'package:lang_buddy/domain/entities/message.dart';
import 'package:lang_buddy/presentation/widgets/chat/chat_bubble.dart';

void main() {
  Widget buildTestWidget(Message message) {
    return MaterialApp(
      home: Scaffold(
        body: ChatBubble(message: message),
      ),
    );
  }

  testWidgets('displays message content', (tester) async {
    final message = Message(
      id: '1',
      conversationId: 'c1',
      sender: MessageSender.user,
      type: MessageType.text,
      content: 'Hello World',
      createdAt: DateTime.now(),
    );

    await tester.pumpWidget(buildTestWidget(message));
    expect(find.text('Hello World'), findsOneWidget);
  });

  testWidgets('user message aligns to right', (tester) async {
    final message = Message(
      id: '1',
      conversationId: 'c1',
      sender: MessageSender.user,
      type: MessageType.text,
      content: 'User message',
      createdAt: DateTime.now(),
    );

    await tester.pumpWidget(buildTestWidget(message));

    final row = tester.widget<Row>(find.byType(Row).first);
    expect(row.mainAxisAlignment, MainAxisAlignment.end);
  });

  testWidgets('agent message aligns to left', (tester) async {
    final message = Message(
      id: '1',
      conversationId: 'c1',
      sender: MessageSender.agent,
      type: MessageType.text,
      content: 'Agent message',
      createdAt: DateTime.now(),
    );

    await tester.pumpWidget(buildTestWidget(message));

    final row = tester.widget<Row>(find.byType(Row).first);
    expect(row.mainAxisAlignment, MainAxisAlignment.start);
  });

  testWidgets('user bubble has green background', (tester) async {
    final message = Message(
      id: '1',
      conversationId: 'c1',
      sender: MessageSender.user,
      type: MessageType.text,
      content: 'Test',
      createdAt: DateTime.now(),
    );

    await tester.pumpWidget(buildTestWidget(message));

    final container = tester.widgetList<Container>(find.byType(Container))
        .where((c) {
      final decoration = c.decoration;
      if (decoration is BoxDecoration) {
        return decoration.color == AppColors.userBubble;
      }
      return false;
    });
    expect(container, isNotEmpty);
  });

  testWidgets('agent bubble has white background', (tester) async {
    final message = Message(
      id: '1',
      conversationId: 'c1',
      sender: MessageSender.agent,
      type: MessageType.text,
      content: 'Test',
      createdAt: DateTime.now(),
    );

    await tester.pumpWidget(buildTestWidget(message));

    final container = tester.widgetList<Container>(find.byType(Container))
        .where((c) {
      final decoration = c.decoration;
      if (decoration is BoxDecoration) {
        return decoration.color == AppColors.agentBubble;
      }
      return false;
    });
    expect(container, isNotEmpty);
  });

  testWidgets('displays formatted time', (tester) async {
    final now = DateTime.now();
    final message = Message(
      id: '1',
      conversationId: 'c1',
      sender: MessageSender.user,
      type: MessageType.text,
      content: 'Test',
      createdAt: DateTime(now.year, now.month, now.day, 14, 30),
    );

    await tester.pumpWidget(buildTestWidget(message));
    expect(find.text('14:30'), findsOneWidget);
  });
}
