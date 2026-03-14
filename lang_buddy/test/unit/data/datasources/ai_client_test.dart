import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:lang_buddy/data/datasources/remote/ai_client.dart';
import 'package:lang_buddy/data/datasources/remote/claude_client.dart';
import 'package:lang_buddy/data/datasources/remote/openai_client.dart';
import 'package:lang_buddy/data/datasources/remote/ai_client_factory.dart';
import 'package:lang_buddy/domain/entities/ai_model_config.dart';

void main() {
  group('ChatMessage', () {
    test('creates with role and content', () {
      const msg = ChatMessage(role: 'user', content: 'Hello');
      expect(msg.role, 'user');
      expect(msg.content, 'Hello');
    });
  });

  group('AIResponse', () {
    test('creates with content and optional tokens', () {
      const resp = AIResponse(content: 'Hi there!');
      expect(resp.content, 'Hi there!');
      expect(resp.inputTokens, isNull);
      expect(resp.outputTokens, isNull);
    });

    test('creates with token counts', () {
      const resp = AIResponse(
        content: 'Response',
        inputTokens: 10,
        outputTokens: 20,
      );
      expect(resp.inputTokens, 10);
      expect(resp.outputTokens, 20);
    });
  });

  group('ClaudeClient', () {
    test('sendMessage constructs correct request and parses response', () async {
      final mockClient = MockClient((request) async {
        // Verify request structure
        expect(request.url.toString(),
            'https://api.anthropic.com/v1/messages');
        expect(request.headers['x-api-key'], 'test-key');
        expect(request.headers['anthropic-version'], '2023-06-01');
        expect(request.headers['Content-Type'], 'application/json');

        final body = jsonDecode(request.body);
        expect(body['model'], 'claude-sonnet-4-20250514');
        expect(body['system'], 'You are a teacher');
        expect(body['messages'], isA<List>());
        expect(body['messages'].last['role'], 'user');
        expect(body['messages'].last['content'], 'Hello');

        return http.Response(
          jsonEncode({
            'content': [
              {'type': 'text', 'text': 'Hi! How can I help?'}
            ],
            'usage': {'input_tokens': 15, 'output_tokens': 8}
          }),
          200,
        );
      });

      final client = ClaudeClient(
        httpClient: mockClient,
        apiKey: 'test-key',
      );

      final response = await client.sendMessage(
        systemPrompt: 'You are a teacher',
        history: [],
        userMessage: 'Hello',
      );

      expect(response.content, 'Hi! How can I help?');
      expect(response.inputTokens, 15);
      expect(response.outputTokens, 8);
    });

    test('sendMessage includes history messages', () async {
      final mockClient = MockClient((request) async {
        final body = jsonDecode(request.body);
        final messages = body['messages'] as List;
        expect(messages.length, 3); // 2 history + 1 new
        expect(messages[0]['role'], 'user');
        expect(messages[0]['content'], 'Hi');
        expect(messages[1]['role'], 'assistant');
        expect(messages[1]['content'], 'Hello!');
        expect(messages[2]['role'], 'user');
        expect(messages[2]['content'], 'How are you?');

        return http.Response(
          jsonEncode({
            'content': [
              {'type': 'text', 'text': 'I am fine!'}
            ],
          }),
          200,
        );
      });

      final client = ClaudeClient(
        httpClient: mockClient,
        apiKey: 'test-key',
      );

      await client.sendMessage(
        systemPrompt: 'System',
        history: [
          const ChatMessage(role: 'user', content: 'Hi'),
          const ChatMessage(role: 'assistant', content: 'Hello!'),
        ],
        userMessage: 'How are you?',
      );
    });

    test('sendMessage throws on API error', () async {
      final mockClient = MockClient((request) async {
        return http.Response('{"error": "unauthorized"}', 401);
      });

      final client = ClaudeClient(
        httpClient: mockClient,
        apiKey: 'bad-key',
      );

      expect(
        () => client.sendMessage(
          systemPrompt: 'System',
          history: [],
          userMessage: 'Hello',
        ),
        throwsA(isA<Exception>()),
      );
    });

    test('requestCorrection parses correction JSON block', () async {
      final correctionResponse = '''
I noticed an error in your sentence.

```correction
{
  "original": "I goes to school",
  "corrected": "I go to school",
  "details": [
    {
      "incorrect": "goes",
      "correct": "go",
      "explanation_zh": "第一人称用动词原形",
      "explanation_en": "Use base form with first person",
      "example": "I go to school every day."
    }
  ]
}
```
''';

      final mockClient = MockClient((request) async {
        return http.Response(
          jsonEncode({
            'content': [
              {'type': 'text', 'text': correctionResponse}
            ],
          }),
          200,
          headers: {'content-type': 'application/json; charset=utf-8'},
        );
      });

      final client = ClaudeClient(
        httpClient: mockClient,
        apiKey: 'test-key',
      );

      final correction = await client.requestCorrection(
        userText: 'I goes to school',
        correctionPrompt: 'Correct this',
      );

      expect(correction, isNotNull);
      expect(correction!.originalText, 'I goes to school');
      expect(correction.correctedText, 'I go to school');
      expect(correction.details.length, 1);
      expect(correction.details[0].incorrect, 'goes');
      expect(correction.details[0].correct, 'go');
      expect(correction.details[0].explanationZh, '第一人称用动词原形');
    });

    test('requestCorrection returns null when no correction block', () async {
      final mockClient = MockClient((request) async {
        return http.Response(
          jsonEncode({
            'content': [
              {'type': 'text', 'text': 'Your sentence is correct!'}
            ],
          }),
          200,
        );
      });

      final client = ClaudeClient(
        httpClient: mockClient,
        apiKey: 'test-key',
      );

      final correction = await client.requestCorrection(
        userText: 'I go to school',
        correctionPrompt: 'Correct this',
      );

      expect(correction, isNull);
    });
  });

  group('OpenAIClient', () {
    test('sendMessage constructs correct request and parses response', () async {
      final mockClient = MockClient((request) async {
        expect(request.url.toString(),
            'https://api.openai.com/v1/chat/completions');
        expect(request.headers['Authorization'], 'Bearer test-key');

        final body = jsonDecode(request.body);
        expect(body['model'], 'gpt-4o');
        expect(body['messages'][0]['role'], 'system');
        expect(body['messages'][0]['content'], 'You are a teacher');
        expect(body['messages'][1]['role'], 'user');
        expect(body['messages'][1]['content'], 'Hello');

        return http.Response(
          jsonEncode({
            'choices': [
              {
                'message': {'content': 'Hi from GPT!'}
              }
            ],
            'usage': {'prompt_tokens': 12, 'completion_tokens': 5}
          }),
          200,
        );
      });

      final client = OpenAIClient(
        httpClient: mockClient,
        apiKey: 'test-key',
      );

      final response = await client.sendMessage(
        systemPrompt: 'You are a teacher',
        history: [],
        userMessage: 'Hello',
      );

      expect(response.content, 'Hi from GPT!');
      expect(response.inputTokens, 12);
      expect(response.outputTokens, 5);
    });

    test('sendMessage uses custom base URL', () async {
      final mockClient = MockClient((request) async {
        expect(request.url.toString(),
            'https://custom-api.com/v1/chat/completions');

        return http.Response(
          jsonEncode({
            'choices': [
              {
                'message': {'content': 'Custom response'}
              }
            ],
          }),
          200,
        );
      });

      final client = OpenAIClient(
        httpClient: mockClient,
        apiKey: 'test-key',
        baseUrl: 'https://custom-api.com/v1',
      );

      final response = await client.sendMessage(
        systemPrompt: 'System',
        history: [],
        userMessage: 'Hello',
      );

      expect(response.content, 'Custom response');
    });

    test('sendMessage throws on API error', () async {
      final mockClient = MockClient((request) async {
        return http.Response('{"error": "rate limited"}', 429);
      });

      final client = OpenAIClient(
        httpClient: mockClient,
        apiKey: 'test-key',
      );

      expect(
        () => client.sendMessage(
          systemPrompt: 'System',
          history: [],
          userMessage: 'Hello',
        ),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('AIClientFactory', () {
    test('creates ClaudeClient for claude provider', () {
      final config = AIModelConfig(
        provider: AIProvider.claude,
        modelId: 'claude-sonnet-4-20250514',
        displayName: 'Claude',
        apiKey: 'key',
      );

      final client = AIClientFactory.create(config);
      expect(client, isA<ClaudeClient>());
    });

    test('creates OpenAIClient for openai provider', () {
      final config = AIModelConfig(
        provider: AIProvider.openai,
        modelId: 'gpt-4o',
        displayName: 'GPT-4o',
        apiKey: 'key',
      );

      final client = AIClientFactory.create(config);
      expect(client, isA<OpenAIClient>());
    });

    test('creates OpenAIClient for custom provider', () {
      final config = AIModelConfig(
        provider: AIProvider.custom,
        modelId: 'custom-model',
        displayName: 'Custom',
        apiKey: 'key',
        baseUrl: 'https://custom.com/v1',
      );

      final client = AIClientFactory.create(config);
      expect(client, isA<OpenAIClient>());
    });
  });
}
