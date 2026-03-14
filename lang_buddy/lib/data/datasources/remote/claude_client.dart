import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import '../../../domain/entities/correction.dart';
import 'ai_client.dart';

class ClaudeClient implements AIClient {
  final http.Client _httpClient;
  final String apiKey;
  final String model;

  ClaudeClient({
    http.Client? httpClient,
    required this.apiKey,
    this.model = 'claude-sonnet-4-20250514',
  }) : _httpClient = httpClient ?? http.Client();

  static const _baseUrl = 'https://api.anthropic.com/v1/messages';
  static const _apiVersion = '2023-06-01';

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'x-api-key': apiKey,
        'anthropic-version': _apiVersion,
      };

  @override
  Future<AIResponse> sendMessage({
    required String systemPrompt,
    required List<ChatMessage> history,
    required String userMessage,
  }) async {
    final messages = [
      ...history.map((m) => {'role': m.role, 'content': m.content}),
      {'role': 'user', 'content': userMessage},
    ];

    final body = jsonEncode({
      'model': model,
      'max_tokens': 1024,
      'system': systemPrompt,
      'messages': messages,
    });

    final response = await _httpClient.post(
      Uri.parse(_baseUrl),
      headers: _headers,
      body: body,
    );

    if (response.statusCode != 200) {
      throw Exception('Claude API error: ${response.statusCode} ${response.body}');
    }

    final data = jsonDecode(response.body);
    final content = data['content'][0]['text'] as String;

    return AIResponse(
      content: content,
      inputTokens: data['usage']?['input_tokens'] as int?,
      outputTokens: data['usage']?['output_tokens'] as int?,
    );
  }

  @override
  Stream<String> streamMessage({
    required String systemPrompt,
    required List<ChatMessage> history,
    required String userMessage,
  }) async* {
    final messages = [
      ...history.map((m) => {'role': m.role, 'content': m.content}),
      {'role': 'user', 'content': userMessage},
    ];

    final body = jsonEncode({
      'model': model,
      'max_tokens': 1024,
      'system': systemPrompt,
      'messages': messages,
      'stream': true,
    });

    final request = http.Request('POST', Uri.parse(_baseUrl));
    request.headers.addAll(_headers);
    request.body = body;

    final streamedResponse = await _httpClient.send(request);

    if (streamedResponse.statusCode != 200) {
      throw Exception('Claude API stream error: ${streamedResponse.statusCode}');
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
        if (json['type'] == 'content_block_delta') {
          final text = json['delta']?['text'] as String?;
          if (text != null) yield text;
        }
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
