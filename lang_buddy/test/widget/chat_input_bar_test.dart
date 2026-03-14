import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lang_buddy/presentation/widgets/chat/chat_input_bar.dart';

void main() {
  Widget buildTestWidget({required Function(String) onSend}) {
    return MaterialApp(
      home: Scaffold(
        body: ChatInputBar(onSend: onSend),
      ),
    );
  }

  testWidgets('renders text input field', (tester) async {
    await tester.pumpWidget(buildTestWidget(onSend: (_) {}));
    expect(find.byType(TextField), findsOneWidget);
  });

  testWidgets('shows placeholder text', (tester) async {
    await tester.pumpWidget(buildTestWidget(onSend: (_) {}));
    expect(find.text('输入消息...'), findsOneWidget);
  });

  testWidgets('shows mic button', (tester) async {
    await tester.pumpWidget(buildTestWidget(onSend: (_) {}));
    expect(find.byIcon(Icons.mic_none), findsOneWidget);
  });

  testWidgets('shows add button when no text', (tester) async {
    await tester.pumpWidget(buildTestWidget(onSend: (_) {}));
    expect(find.byIcon(Icons.add_circle_outline), findsOneWidget);
    expect(find.byIcon(Icons.send), findsNothing);
  });

  testWidgets('shows send button when text is entered', (tester) async {
    await tester.pumpWidget(buildTestWidget(onSend: (_) {}));

    await tester.enterText(find.byType(TextField), 'Hello');
    await tester.pump();

    expect(find.byIcon(Icons.send), findsOneWidget);
    expect(find.byIcon(Icons.add_circle_outline), findsNothing);
  });

  testWidgets('calls onSend with entered text', (tester) async {
    String? sentText;
    await tester.pumpWidget(buildTestWidget(onSend: (text) {
      sentText = text;
    }));

    await tester.enterText(find.byType(TextField), 'Hello World');
    await tester.pump();

    await tester.tap(find.byIcon(Icons.send));
    await tester.pump();

    expect(sentText, 'Hello World');
  });

  testWidgets('clears text after send', (tester) async {
    await tester.pumpWidget(buildTestWidget(onSend: (_) {}));

    await tester.enterText(find.byType(TextField), 'Hello');
    await tester.pump();

    await tester.tap(find.byIcon(Icons.send));
    await tester.pump();

    // Send button should be gone (text cleared)
    expect(find.byIcon(Icons.send), findsNothing);
    expect(find.byIcon(Icons.add_circle_outline), findsOneWidget);
  });

  testWidgets('does not send empty text', (tester) async {
    bool wasCalled = false;
    await tester.pumpWidget(buildTestWidget(onSend: (_) {
      wasCalled = true;
    }));

    // No text entered, send button shouldn't exist
    expect(find.byIcon(Icons.send), findsNothing);
    expect(wasCalled, false);
  });

  testWidgets('does not send whitespace-only text', (tester) async {
    bool wasCalled = false;
    await tester.pumpWidget(buildTestWidget(onSend: (_) {
      wasCalled = true;
    }));

    await tester.enterText(find.byType(TextField), '   ');
    await tester.pump();

    // Whitespace-only shouldn't show send button
    expect(find.byIcon(Icons.send), findsNothing);
    expect(wasCalled, false);
  });
}
