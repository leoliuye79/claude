import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lang_buddy/domain/entities/correction.dart';
import 'package:lang_buddy/presentation/widgets/chat/correction_bubble.dart';

void main() {
  final testCorrection = Correction(
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

  Widget buildTestWidget(Correction correction) {
    return MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          child: CorrectionBubble(correction: correction),
        ),
      ),
    );
  }

  testWidgets('displays correction header', (tester) async {
    await tester.pumpWidget(buildTestWidget(testCorrection));
    expect(find.text('语法纠正'), findsOneWidget);
  });

  testWidgets('displays original and corrected text', (tester) async {
    await tester.pumpWidget(buildTestWidget(testCorrection));
    expect(find.text('I goes to school'), findsOneWidget);
    expect(find.text('I go to school'), findsOneWidget);
  });

  testWidgets('displays 原文 and 修改 labels', (tester) async {
    await tester.pumpWidget(buildTestWidget(testCorrection));
    expect(find.text('原文'), findsOneWidget);
    expect(find.text('修改'), findsOneWidget);
  });

  testWidgets('details hidden by default', (tester) async {
    await tester.pumpWidget(buildTestWidget(testCorrection));
    // Detail text should not be visible initially
    expect(find.text('第一人称用动词原形'), findsNothing);
  });

  testWidgets('expands to show details on tap', (tester) async {
    await tester.pumpWidget(buildTestWidget(testCorrection));

    // Tap the header to expand
    await tester.tap(find.text('语法纠正'));
    await tester.pumpAndSettle();

    // Now details should be visible
    expect(find.text('第一人称用动词原形'), findsOneWidget);
  });

  testWidgets('shows example sentence when expanded', (tester) async {
    await tester.pumpWidget(buildTestWidget(testCorrection));

    await tester.tap(find.text('语法纠正'));
    await tester.pumpAndSettle();

    expect(find.textContaining('I go to school every day.'), findsOneWidget);
  });

  testWidgets('collapses details on second tap', (tester) async {
    await tester.pumpWidget(buildTestWidget(testCorrection));

    // Expand
    await tester.tap(find.text('语法纠正'));
    await tester.pumpAndSettle();
    expect(find.text('第一人称用动词原形'), findsOneWidget);

    // Collapse
    await tester.tap(find.text('语法纠正'));
    await tester.pumpAndSettle();
    expect(find.text('第一人称用动词原形'), findsNothing);
  });

  testWidgets('handles multiple correction details', (tester) async {
    final multiCorrection = Correction(
      originalText: 'I goes to school yesterday',
      correctedText: 'I went to school yesterday',
      details: [
        CorrectionDetail(
          incorrect: 'goes',
          correct: 'went',
          explanationZh: '过去时态需要用过去式',
          explanationEn: 'Past tense requires past form',
        ),
        CorrectionDetail(
          incorrect: 'goes',
          correct: 'went',
          explanationZh: 'go的过去式是不规则变化',
          explanationEn: 'go has irregular past tense',
          example: 'I went home after school.',
        ),
      ],
    );

    await tester.pumpWidget(buildTestWidget(multiCorrection));

    await tester.tap(find.text('语法纠正'));
    await tester.pumpAndSettle();

    expect(find.text('过去时态需要用过去式'), findsOneWidget);
    expect(find.text('go的过去式是不规则变化'), findsOneWidget);
  });
}
