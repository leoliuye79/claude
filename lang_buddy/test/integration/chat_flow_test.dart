import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:lang_buddy/config/agents/default_agents.dart';
import 'package:lang_buddy/config/prompts/system_prompts.dart';
import 'package:lang_buddy/data/datasources/remote/ai_client.dart';
import 'package:lang_buddy/data/datasources/remote/claude_client.dart';
import 'package:lang_buddy/data/datasources/remote/openai_client.dart';
import 'package:lang_buddy/domain/entities/message.dart';

void main() {
  group('Chat Flow Integration', () {
    test('complete chat flow: build prompt → send message → parse response',
        () async {
      // Step 1: Build system prompt for Emma
      final agent = DefaultAgents.emma;
      final systemPrompt = SystemPromptBuilder.build(agent);

      expect(systemPrompt, contains('Emma Wilson'));
      expect(systemPrompt, contains('language learning companion'));
      expect(systemPrompt, isNotEmpty);

      // Step 2: Create AI client and send message
      final mockClient = MockClient((request) async {
        final body = jsonDecode(request.body);
        // Verify system prompt was sent
        expect(body['system'], systemPrompt);
        expect(body['messages'].last['content'], 'I goes to school everyday');

        return http.Response(
          jsonEncode({
            'content': [
              {
                'type': 'text',
                'text': 'Great effort! Let me help you with a small correction.\n\n'
                    '```correction\n'
                    '{\n'
                    '  "original": "I goes to school everyday",\n'
                    '  "corrected": "I go to school every day",\n'
                    '  "details": [\n'
                    '    {\n'
                    '      "incorrect": "goes",\n'
                    '      "correct": "go",\n'
                    '      "explanation_zh": "第一人称I后面用动词原形",\n'
                    '      "explanation_en": "Use base form after first person I",\n'
                    '      "example": "I go to the gym every morning."\n'
                    '    },\n'
                    '    {\n'
                    '      "incorrect": "everyday",\n'
                    '      "correct": "every day",\n'
                    '      "explanation_zh": "every day是副词短语表示每天，everyday是形容词表示日常的",\n'
                    '      "explanation_en": "every day (two words) is an adverb phrase meaning each day",\n'
                    '      "example": "I practice English every day."\n'
                    '    }\n'
                    '  ]\n'
                    '}\n'
                    '```'
              }
            ],
            'usage': {'input_tokens': 200, 'output_tokens': 150}
          }),
          200,
          headers: {'content-type': 'application/json; charset=utf-8'},
        );
      });

      final aiClient = ClaudeClient(
        httpClient: mockClient,
        apiKey: 'test-key',
      );

      // Step 3: Send and get response
      final response = await aiClient.sendMessage(
        systemPrompt: systemPrompt,
        history: [],
        userMessage: 'I goes to school everyday',
      );

      expect(response.content, isNotEmpty);
      expect(response.content, contains('correction'));
      expect(response.inputTokens, 200);
      expect(response.outputTokens, 150);

      // Step 4: Parse correction from response
      final correction = await aiClient.requestCorrection(
        userText: 'I goes to school everyday',
        correctionPrompt: systemPrompt,
      );

      expect(correction, isNotNull);
      expect(correction!.originalText, 'I goes to school everyday');
      expect(correction.correctedText, 'I go to school every day');
      expect(correction.details.length, 2);

      // Verify first correction detail
      expect(correction.details[0].incorrect, 'goes');
      expect(correction.details[0].correct, 'go');
      expect(correction.details[0].explanationZh, contains('第一人称'));

      // Verify second correction detail
      expect(correction.details[1].incorrect, 'everyday');
      expect(correction.details[1].correct, 'every day');
    });

    test('chat flow with conversation history', () async {
      final agent = DefaultAgents.jake;
      final systemPrompt = SystemPromptBuilder.build(agent);

      final history = <ChatMessage>[
        const ChatMessage(role: 'user', content: 'Hi Jake!'),
        const ChatMessage(
            role: 'assistant', content: "Hey! What's up? How's it going?"),
      ];

      final mockClient = MockClient((request) async {
        final body = jsonDecode(request.body);
        final messages = body['messages'] as List;

        // Should have history + new message
        expect(messages.length, 3);
        expect(messages[0]['content'], 'Hi Jake!');
        expect(messages[1]['content'], "Hey! What's up? How's it going?");
        expect(messages[2]['content'], 'I want to learn some slang');

        return http.Response(
          jsonEncode({
            'content': [
              {
                'type': 'text',
                'text':
                    "Sure thing! Here's a cool one: \"chill\" means to relax."
              }
            ],
          }),
          200,
        );
      });

      final aiClient = ClaudeClient(
        httpClient: mockClient,
        apiKey: 'test-key',
      );

      final response = await aiClient.sendMessage(
        systemPrompt: systemPrompt,
        history: history,
        userMessage: 'I want to learn some slang',
      );

      expect(response.content, contains('chill'));
    });

    test('chat flow works with OpenAI backend', () async {
      final agent = DefaultAgents.linda;
      final systemPrompt = SystemPromptBuilder.build(agent);

      final mockClient = MockClient((request) async {
        final body = jsonDecode(request.body);

        // OpenAI puts system prompt as first message
        expect(body['messages'][0]['role'], 'system');
        expect(body['messages'][0]['content'], systemPrompt);
        expect(body['messages'][1]['role'], 'user');

        return http.Response(
          jsonEncode({
            'choices': [
              {
                'message': {
                  'content':
                      'Good morning! Let\'s review your presentation draft.'
                }
              }
            ],
          }),
          200,
        );
      });

      final aiClient = OpenAIClient(
        httpClient: mockClient,
        apiKey: 'test-key',
      );

      final response = await aiClient.sendMessage(
        systemPrompt: systemPrompt,
        history: [],
        userMessage: 'Good morning Linda, can you help me with my presentation?',
      );

      expect(response.content, contains('presentation'));
    });

    test('message entity creation for user and agent', () {
      final now = DateTime.now();

      // Create user message
      final userMsg = Message(
        id: 'msg_1',
        conversationId: 'conv_1',
        sender: MessageSender.user,
        type: MessageType.text,
        content: 'I goes to school',
        status: MessageStatus.sent,
        createdAt: now,
      );

      expect(userMsg.sender, MessageSender.user);
      expect(userMsg.type, MessageType.text);

      // Create agent response with correction
      final agentMsg = Message(
        id: 'msg_2',
        conversationId: 'conv_1',
        sender: MessageSender.agent,
        type: MessageType.text,
        content: 'Let me help you with that!',
        status: MessageStatus.sent,
        createdAt: now.add(const Duration(seconds: 2)),
      );

      expect(agentMsg.sender, MessageSender.agent);
      expect(agentMsg.createdAt.isAfter(userMsg.createdAt), isTrue);
    });

    test('all default agents produce valid system prompts', () {
      for (final agent in DefaultAgents.all) {
        final prompt = SystemPromptBuilder.build(agent);

        // Every prompt should contain:
        expect(prompt, contains(agent.name),
            reason: '${agent.name} prompt missing name');
        expect(prompt, contains(agent.nameZh),
            reason: '${agent.name} prompt missing Chinese name');
        expect(prompt, contains(agent.personality),
            reason: '${agent.name} prompt missing personality');
        expect(prompt, contains('correction'),
            reason: '${agent.name} prompt missing correction format');
        expect(prompt, contains('language learning'),
            reason: '${agent.name} prompt missing base instructions');
      }
    });
  });
}
