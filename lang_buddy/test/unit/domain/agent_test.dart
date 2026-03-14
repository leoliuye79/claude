import 'package:flutter_test/flutter_test.dart';
import 'package:lang_buddy/domain/entities/agent.dart';

void main() {
  group('AgentRole', () {
    test('has correct labels', () {
      expect(AgentRole.teacher.label, '老师');
      expect(AgentRole.friend.label, '朋友');
      expect(AgentRole.colleague.label, '同事');
      expect(AgentRole.tutor.label, '辅导员');
      expect(AgentRole.travelBuddy.label, '旅行伙伴');
      expect(AgentRole.interviewCoach.label, '面试教练');
    });

    test('has all 6 values', () {
      expect(AgentRole.values.length, 6);
    });
  });

  group('TeachingStyle', () {
    test('has non-empty instructions', () {
      for (final style in TeachingStyle.values) {
        expect(style.instruction, isNotEmpty);
      }
    });

    test('has all 4 values', () {
      expect(TeachingStyle.values.length, 4);
    });
  });

  group('CorrectionMode', () {
    test('has non-empty instructions', () {
      for (final mode in CorrectionMode.values) {
        expect(mode.instruction, isNotEmpty);
      }
    });

    test('has all 3 values', () {
      expect(CorrectionMode.values.length, 3);
    });
  });

  group('Agent', () {
    late Agent agent;

    setUp(() {
      agent = Agent(
        id: 'test_id',
        name: 'Test Agent',
        nameZh: '测试助手',
        avatarUrl: 'test_avatar',
        role: AgentRole.teacher,
        style: TeachingStyle.encouraging,
        correctionMode: CorrectionMode.immediate,
        personality: 'Friendly and patient',
        greeting: 'Hello!',
        targetLevel: 'beginner',
        topics: ['daily life', 'greetings'],
        createdAt: DateTime(2024, 1, 1),
      );
    });

    test('creates with required fields', () {
      expect(agent.id, 'test_id');
      expect(agent.name, 'Test Agent');
      expect(agent.nameZh, '测试助手');
      expect(agent.role, AgentRole.teacher);
      expect(agent.topics.length, 2);
    });

    test('has correct default values', () {
      expect(agent.isCustom, false);
      expect(agent.isActive, true);
    });

    test('copyWith updates specified fields', () {
      final updated = agent.copyWith(
        name: 'Updated Name',
        role: AgentRole.friend,
      );
      expect(updated.name, 'Updated Name');
      expect(updated.role, AgentRole.friend);
      // Other fields preserved
      expect(updated.id, 'test_id');
      expect(updated.nameZh, '测试助手');
      expect(updated.personality, 'Friendly and patient');
    });

    test('copyWith preserves all fields when no args', () {
      final copy = agent.copyWith();
      expect(copy.id, agent.id);
      expect(copy.name, agent.name);
      expect(copy.nameZh, agent.nameZh);
      expect(copy.avatarUrl, agent.avatarUrl);
      expect(copy.role, agent.role);
      expect(copy.style, agent.style);
      expect(copy.correctionMode, agent.correctionMode);
      expect(copy.personality, agent.personality);
      expect(copy.greeting, agent.greeting);
      expect(copy.targetLevel, agent.targetLevel);
      expect(copy.topics, agent.topics);
      expect(copy.isCustom, agent.isCustom);
      expect(copy.isActive, agent.isActive);
      expect(copy.createdAt, agent.createdAt);
    });

    test('copyWith can override default values', () {
      final customAgent = agent.copyWith(
        isCustom: true,
        isActive: false,
      );
      expect(customAgent.isCustom, true);
      expect(customAgent.isActive, false);
    });
  });
}
