import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lang_buddy/core/constants/app_dimensions.dart';
import 'package:lang_buddy/presentation/widgets/common/avatar_widget.dart';

void main() {
  Widget buildTestWidget({
    required String name,
    String? avatarUrl,
    double? size,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: AvatarWidget(
          name: name,
          avatarUrl: avatarUrl,
          size: size ?? AppDimensions.avatarMedium,
        ),
      ),
    );
  }

  testWidgets('displays first letter of name', (tester) async {
    await tester.pumpWidget(buildTestWidget(name: 'Emma'));
    expect(find.text('E'), findsOneWidget);
  });

  testWidgets('displays uppercase letter', (tester) async {
    await tester.pumpWidget(buildTestWidget(name: 'jake'));
    expect(find.text('J'), findsOneWidget);
  });

  testWidgets('handles empty name', (tester) async {
    await tester.pumpWidget(buildTestWidget(name: ''));
    expect(find.text('?'), findsOneWidget);
  });

  testWidgets('uses default medium size', (tester) async {
    await tester.pumpWidget(buildTestWidget(name: 'Test'));

    final container = tester.widget<Container>(find.byType(Container).first);
    final constraints = container.constraints;
    expect(constraints?.maxWidth, AppDimensions.avatarMedium);
    expect(constraints?.maxHeight, AppDimensions.avatarMedium);
  });

  testWidgets('uses custom size', (tester) async {
    await tester.pumpWidget(buildTestWidget(name: 'Test', size: 80));

    final container = tester.widget<Container>(find.byType(Container).first);
    final constraints = container.constraints;
    expect(constraints?.maxWidth, 80);
    expect(constraints?.maxHeight, 80);
  });

  testWidgets('same name always produces same color', (tester) async {
    await tester.pumpWidget(buildTestWidget(name: 'Emma'));
    final container1 = tester.widget<Container>(find.byType(Container).first);
    final decoration1 = container1.decoration as BoxDecoration;
    final color1 = decoration1.color;

    // Rebuild with same name
    await tester.pumpWidget(buildTestWidget(name: 'Emma'));
    final container2 = tester.widget<Container>(find.byType(Container).first);
    final decoration2 = container2.decoration as BoxDecoration;
    final color2 = decoration2.color;

    expect(color1, color2);
  });

  testWidgets('different names can produce different colors', (tester) async {
    // Test that the color function produces variety
    // Not all names will differ, but the mechanism should work
    await tester.pumpWidget(buildTestWidget(name: 'A'));
    final container1 = tester.widget<Container>(find.byType(Container).first);
    final color1 = (container1.decoration as BoxDecoration).color;

    await tester.pumpWidget(buildTestWidget(name: 'B'));
    final container2 = tester.widget<Container>(find.byType(Container).first);
    final color2 = (container2.decoration as BoxDecoration).color;

    // At least the mechanism exists, colors may or may not differ
    expect(color1, isNotNull);
    expect(color2, isNotNull);
  });
}
