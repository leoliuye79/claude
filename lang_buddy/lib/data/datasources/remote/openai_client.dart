import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import '../../../domain/entities/correction.dart';
import 'ai_client.dart';

class OpenAIClient implements AIClient {
  final http.Client _httpClient;
  final String apiKey;
  final String model;
  final String baseUrl;

  OpenAIClient({
    http.Client? httpClient,
    required this.apiKey,
    this.model = 'gpt-4o',
    this.baseUrl = 'https://api.openai.com/v1',
  }) : _httpClient = httpClient ?? http.Client();

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiKey',
      };

  @override
  Future<AIResponse> sendMessage({
    required String systemPrompt,
    required List<ChatMessage> history,
    required String userMessage,
  }) async {
    final messages = [
      {'role': 'system', 'content': systemPrompt},
      ...history.map((m) => {'role': m.role, 'content': m.content}),
      {'role': 'user', 'content': userMessage},
    ];

    final body = jsonEncode({
      'model': model,
      'max_tokens': 1024,
      'messages': messages,
    });

    final response = await _httpClient.post(
      Uri.parse('$baseUrl/chat/completions'),
      headers: _headers,
      body: body,
    );

    if (response.statusCode != 200) {
      throw Exception('OpenAI API error: ${response.statusCode} ${response.body}');
    }

    final data = jsonDecode(response.body);
    final content = data['choices'][0]['message']['content'] as String;

    return AIResponse(
      content: content,
      inputTokens: data['usage']?['prompt_tokens'] as int?,
      outputTokens: data['usage']?['completion_tokens'] as int?,
    );
  }

  @override
  Stream<String> streamMessage({
    required String systemPrompt,
    required List<ChatMessage> history,
    required String userMessage,
  }) async* {
    final messages = [
      {'role': 'system', 'content': systemPrompt},
      ...history.map((m) => {'role': m.role, 'content': m.content}),
      {'role': 'user', 'content': userMessage},
    ];

    final body = jsonEncode({
      'model': model,
      'max_tokens': 1024,
      'messages': messages,
      'stream': true,
    });

    final request = http.Request('POST', Uri.parse('$baseUrl/chat/completions'));
    request.headers.addAll(_headers);
    request.body = body;

    final streamedResponse = await _httpClient.send(request);

    if (streamedResponse.statusCode != 200) {
      throw Exception('OpenAI API stream error: ${streamedResponse.statusCode}');
    }

    final lineStream = streamedResponse.stream
        .transform(utf8.decoder)
        .transform(const LineSplitter());

    await for (final line in lineStream) {
      if (!line.startsWith('data: ')) continue;
      final data = line.substring(6);
      if (data == '[DONE]') break;

      try {
        final json = jsonDecode(data);
        final delta = json['choices']?[0]?['delta']?['content'] as String?;
        if (delta != null) yield delta;
      } catch (_) {
        // Skip malformed SSE events
      }
    }
  }

  @override
  Future<Correction?> requestCorrection({
    required String userText,
    required String correctionPrompt,
  }) async {
    final response = await sendMessage(
      systemPrompt: correctionPrompt,
      history: [],
      userMessage: userText,
    );
    return _parseCorrection(response.content);
  }

  Correction? _parseCorrection(String text) {
    try {
      final regex = RegExp(r'```correction\s*([\s\S]*?)```');
      final match = regex.firstMatch(text);
      if (match == null) return null;

      final json = jsonDecode(match.group(1)!);
      return Correction(
        originalText: json['original'] as String,
        correctedText: json['corrected'] as String,
        details: (json['details'] as List).map((d) {
          return CorrectionDetail(
            incorrect: d['incorrect'] as String,
            correct: d['correct'] as String,
            explanationZh: d['explanation_zh'] as String,
            explanationEn: d['explanation_en'] as String,
            example: d['example'] as String?,
          );
        }).toList(),
      );
    } catch (_) {
      return null;
    }
  }
}
