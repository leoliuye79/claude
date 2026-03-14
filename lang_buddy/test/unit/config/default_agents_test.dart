import 'package:flutter_test/flutter_test.dart';
import 'package:lang_buddy/config/agents/default_agents.dart';
import 'package:lang_buddy/domain/entities/agent.dart';

void main() {
  group('DefaultAgents', () {
    test('has exactly 6 agents', () {
      expect(DefaultAgents.all.length, 6);
    });

    test('all agents have unique IDs', () {
      final ids = DefaultAgents.all.map((a) => a.id).toSet();
      expect(ids.length, 6);
    });

    test('all agents have non-empty required fields', () {
      for (final agent in DefaultAgents.all) {
        expect(agent.id, isNotEmpty, reason: '${agent.name} missing id');
        expect(agent.name, isNotEmpty, reason: '${agent.id} missing name');
        expect(agent.nameZh, isNotEmpty, reason: '${agent.id} missing nameZh');
        expect(agent.avatarUrl, isNotEmpty,
            reason: '${agent.id} missing avatarUrl');
        expect(agent.personality, isNotEmpty,
            reason: '${agent.id} missing personality');
        expect(agent.greeting, isNotEmpty,
            reason: '${agent.id} missing greeting');
        expect(agent.targetLevel, isNotEmpty,
            reason: '${agent.id} missing targetLevel');
        expect(agent.topics, isNotEmpty,
            reason: '${agent.id} missing topics');
      }
    });

    test('all agents are not custom', () {
      for (final agent in DefaultAgents.all) {
        expect(agent.isCustom, false);
      }
    });

    test('all agents are active', () {
      for (final agent in DefaultAgents.all) {
        expect(agent.isActive, true);
      }
    });

    test('emma is a beginner teacher', () {
      final emma = DefaultAgents.emma;
      expect(emma.name, 'Emma Wilson');
      expect(emma.nameZh, '艾玛老师');
      expect(emma.role, AgentRole.teacher);
      expect(emma.style, TeachingStyle.encouraging);
      expect(emma.correctionMode, CorrectionMode.immediate);
      expect(emma.targetLevel, 'beginner');
    });

    test('jake is an intermediate friend', () {
      final jake = DefaultAgents.jake;
      expect(jake.name, 'Jake Miller');
      expect(jake.role, AgentRole.friend);
      expect(jake.style, TeachingStyle.casual);
      expect(jake.correctionMode, CorrectionMode.endOfTurn);
      expect(jake.targetLevel, 'intermediate');
    });

    test('linda is a strict business colleague', () {
      final linda = DefaultAgents.linda;
      expect(linda.name, 'Linda Park');
      expect(linda.role, AgentRole.colleague);
      expect(linda.style, TeachingStyle.strict);
      expect(linda.correctionMode, CorrectionMode.immediate);
    });

    test('sam is a casual travel buddy', () {
      final sam = DefaultAgents.sam;
      expect(sam.role, AgentRole.travelBuddy);
      expect(sam.correctionMode, CorrectionMode.onRequest);
      expect(sam.targetLevel, 'beginner');
    });

    test('rachel is an advanced interview coach', () {
      final rachel = DefaultAgents.rachel;
      expect(rachel.role, AgentRole.interviewCoach);
      expect(rachel.style, TeachingStyle.socratic);
      expect(rachel.targetLevel, 'advanced');
    });

    test('oliver covers all levels', () {
      final oliver = DefaultAgents.oliver;
      expect(oliver.role, AgentRole.tutor);
      expect(oliver.style, TeachingStyle.socratic);
      expect(oliver.correctionMode, CorrectionMode.immediate);
      expect(oliver.targetLevel, 'all');
    });

    test('covers diverse correction modes', () {
      final modes = DefaultAgents.all.map((a) => a.correctionMode).toSet();
      expect(modes, containsAll(CorrectionMode.values));
    });

    test('covers diverse teaching styles', () {
      final styles = DefaultAgents.all.map((a) => a.style).toSet();
      expect(styles.length, greaterThanOrEqualTo(3));
    });

    test('covers diverse roles', () {
      final roles = DefaultAgents.all.map((a) => a.role).toSet();
      expect(roles.length, 6);
    });
  });
}
