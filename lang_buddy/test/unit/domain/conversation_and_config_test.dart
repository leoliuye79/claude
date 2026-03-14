import 'package:flutter_test/flutter_test.dart';
import 'package:lang_buddy/domain/entities/conversation.dart';
import 'package:lang_buddy/domain/entities/ai_model_config.dart';

void main() {
  group('Conversation', () {
    late Conversation conversation;
    final now = DateTime.now();

    setUp(() {
      conversation = Conversation(
        id: 'conv_1',
        agentId: 'agent_1',
        createdAt: now,
      );
    });

    test('creates with required fields and defaults', () {
      expect(conversation.id, 'conv_1');
      expect(conversation.agentId, 'agent_1');
      expect(conversation.lastMessagePreview, isNull);
      expect(conversation.lastMessageAt, isNull);
      expect(conversation.unreadCount, 0);
      expect(conversation.isPinned, false);
    });

    test('creates with all fields', () {
      final full = Conversation(
        id: 'conv_2',
        agentId: 'agent_2',
        lastMessagePreview: 'Hello!',
        lastMessageAt: now,
        unreadCount: 3,
        isPinned: true,
        createdAt: now,
      );

      expect(full.lastMessagePreview, 'Hello!');
      expect(full.lastMessageAt, now);
      expect(full.unreadCount, 3);
      expect(full.isPinned, true);
    });

    test('copyWith updates specified fields', () {
      final updated = conversation.copyWith(
        lastMessagePreview: 'New message',
        lastMessageAt: now,
        unreadCount: 1,
      );

      expect(updated.lastMessagePreview, 'New message');
      expect(updated.lastMessageAt, now);
      expect(updated.unreadCount, 1);
      expect(updated.id, 'conv_1');
      expect(updated.agentId, 'agent_1');
      expect(updated.isPinned, false);
    });

    test('copyWith can pin conversation', () {
      final pinned = conversation.copyWith(isPinned: true);
      expect(pinned.isPinned, true);
    });

    test('copyWith preserves all fields when no args', () {
      final copy = conversation.copyWith();
      expect(copy.id, conversation.id);
      expect(copy.agentId, conversation.agentId);
      expect(copy.lastMessagePreview, conversation.lastMessagePreview);
      expect(copy.lastMessageAt, conversation.lastMessageAt);
      expect(copy.unreadCount, conversation.unreadCount);
      expect(copy.isPinned, conversation.isPinned);
      expect(copy.createdAt, conversation.createdAt);
    });
  });

  group('AIProvider', () {
    test('has correct labels', () {
      expect(AIProvider.claude.label, 'Claude (Anthropic)');
      expect(AIProvider.openai.label, 'OpenAI');
      expect(AIProvider.custom.label, '自定义');
    });

    test('has all 3 values', () {
      expect(AIProvider.values.length, 3);
    });
  });

  group('AIModelConfig', () {
    late AIModelConfig config;

    setUp(() {
      config = AIModelConfig(
        provider: AIProvider.claude,
        modelId: 'claude-sonnet-4-20250514',
        displayName: 'Claude Sonnet',
        apiKey: 'sk-test-key',
      );
    });

    test('creates with required fields and defaults', () {
      expect(config.provider, AIProvider.claude);
      expect(config.modelId, 'claude-sonnet-4-20250514');
      expect(config.displayName, 'Claude Sonnet');
      expect(config.apiKey, 'sk-test-key');
      expect(config.baseUrl, isNull);
      expect(config.temperature, 0.7);
      expect(config.maxTokens, 1024);
    });

    test('creates with custom endpoint', () {
      final custom = AIModelConfig(
        provider: AIProvider.custom,
        modelId: 'my-model',
        displayName: 'Custom Model',
        apiKey: 'custom-key',
        baseUrl: 'https://my-api.com/v1',
        temperature: 0.5,
        maxTokens: 2048,
      );

      expect(custom.provider, AIProvider.custom);
      expect(custom.baseUrl, 'https://my-api.com/v1');
      expect(custom.temperature, 0.5);
      expect(custom.maxTokens, 2048);
    });

    test('copyWith updates specified fields', () {
      final updated = config.copyWith(
        provider: AIProvider.openai,
        modelId: 'gpt-4o',
        temperature: 0.9,
      );

      expect(updated.provider, AIProvider.openai);
      expect(updated.modelId, 'gpt-4o');
      expect(updated.temperature, 0.9);
      expect(updated.apiKey, 'sk-test-key');
      expect(updated.maxTokens, 1024);
    });

    test('copyWith preserves all fields when no args', () {
      final copy = config.copyWith();
      expect(copy.provider, config.provider);
      expect(copy.modelId, config.modelId);
      expect(copy.displayName, config.displayName);
      expect(copy.apiKey, config.apiKey);
      expect(copy.baseUrl, config.baseUrl);
      expect(copy.temperature, config.temperature);
      expect(copy.maxTokens, config.maxTokens);
    });
  });
}
