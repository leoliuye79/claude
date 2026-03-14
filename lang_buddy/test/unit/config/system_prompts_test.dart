import 'package:flutter_test/flutter_test.dart';
import 'package:lang_buddy/config/prompts/system_prompts.dart';
import 'package:lang_buddy/config/agents/default_agents.dart';
import 'package:lang_buddy/domain/entities/agent.dart';

void main() {
  group('SystemPromptBuilder', () {
    test('builds prompt with agent identity', () {
      final prompt = SystemPromptBuilder.build(DefaultAgents.emma);
      expect(prompt, contains('Emma Wilson'));
      expect(prompt, contains('艾玛老师'));
      expect(prompt, contains('老师'));
    });

    test('builds prompt with teaching configuration', () {
      final prompt = SystemPromptBuilder.build(DefaultAgents.emma);
      expect(prompt, contains('beginner'));
      expect(prompt, contains(CorrectionMode.immediate.instruction));
      expect(prompt, contains(TeachingStyle.encouraging.instruction));
    });

    test('builds prompt with topics', () {
      final prompt = SystemPromptBuilder.build(DefaultAgents.emma);
      for (final topic in DefaultAgents.emma.topics) {
        expect(prompt, contains(topic));
      }
    });

    test('includes base prompt rules', () {
      final prompt = SystemPromptBuilder.build(DefaultAgents.jake);
      expect(prompt, contains('language learning companion'));
      expect(prompt, contains('Chinese native speaker'));
      expect(prompt, contains('English'));
    });

    test('includes correction format instructions', () {
      final prompt = SystemPromptBuilder.build(DefaultAgents.oliver);
      expect(prompt, contains('correction'));
      expect(prompt, contains('original'));
      expect(prompt, contains('corrected'));
      expect(prompt, contains('details'));
    });

    test('includes personality description', () {
      final prompt = SystemPromptBuilder.build(DefaultAgents.linda);
      expect(prompt, contains(DefaultAgents.linda.personality));
    });

    test('builds different prompts for different agents', () {
      final emmaPrompt = SystemPromptBuilder.build(DefaultAgents.emma);
      final jakePrompt = SystemPromptBuilder.build(DefaultAgents.jake);

      expect(emmaPrompt, isNot(equals(jakePrompt)));
      expect(emmaPrompt, contains('Emma Wilson'));
      expect(jakePrompt, contains('Jake Miller'));
    });

    test('builds valid prompt for all default agents', () {
      for (final agent in DefaultAgents.all) {
        final prompt = SystemPromptBuilder.build(agent);
        expect(prompt, isNotEmpty, reason: '${agent.name} prompt is empty');
        expect(prompt.length, greaterThan(100),
            reason: '${agent.name} prompt is too short');
      }
    });

    test('builds prompt for custom agent', () {
      final customAgent = Agent(
        id: 'custom_1',
        name: 'Custom Agent',
        nameZh: '自定义助手',
        avatarUrl: 'custom',
        role: AgentRole.friend,
        style: TeachingStyle.casual,
        correctionMode: CorrectionMode.onRequest,
        personality: 'Very unique personality',
        greeting: 'Hey there!',
        targetLevel: 'advanced',
        topics: ['technology', 'science'],
        isCustom: true,
        createdAt: DateTime.now(),
      );

      final prompt = SystemPromptBuilder.build(customAgent);
      expect(prompt, contains('Custom Agent'));
      expect(prompt, contains('自定义助手'));
      expect(prompt, contains('Very unique personality'));
      expect(prompt, contains('technology'));
      expect(prompt, contains('science'));
    });
  });
}
