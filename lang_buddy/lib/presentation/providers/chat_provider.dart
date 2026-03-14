import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../config/prompts/system_prompts.dart';
import '../../data/datasources/remote/ai_client.dart';
import '../../data/datasources/remote/ai_client_factory.dart';
import '../../domain/entities/agent.dart';
import '../../domain/entities/correction.dart';
import '../../domain/entities/message.dart';
import 'database_provider.dart';
import 'conversation_provider.dart';

final chatMessagesProvider =
    StreamProvider.family<List<Message>, String>((ref, conversationId) {
  final repo = ref.watch(messageRepositoryProvider);
  return repo.watchMessages(conversationId);
});

final streamingMessageProvider = StateProvider<String?>((ref) => null);

final chatActionsProvider = Provider<ChatActions>((ref) => ChatActions(ref));

class ChatActions {
  final Ref _ref;

  ChatActions(this._ref);

  Future<void> sendMessage({
    required String conversationId,
    required String content,
    required Agent agent,
  }) async {
    final messageRepo = _ref.read(messageRepositoryProvider);
    final conversationActions = _ref.read(conversationActionsProvider);

    // Save user message
    final userMessage = Message(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      conversationId: conversationId,
      sender: MessageSender.user,
      type: MessageType.text,
      content: content,
      status: MessageStatus.sent,
      createdAt: DateTime.now(),
    );
    await messageRepo.insertMessage(userMessage);
    await conversationActions.updateLastMessage(conversationId, content);

    // Get AI response
    try {
      final config = await _ref.read(settingsRepositoryProvider).getActiveModelConfig();
      if (config == null || config.apiKey.isEmpty) {
        // Save a placeholder response if no API key configured
        final noKeyMessage = Message(
          id: (DateTime.now().millisecondsSinceEpoch + 1).toString(),
          conversationId: conversationId,
          sender: MessageSender.agent,
          type: MessageType.systemNotice,
          content: '请先在设置中配置 API Key 才能开始对话。',
          status: MessageStatus.sent,
          createdAt: DateTime.now(),
        );
        await messageRepo.insertMessage(noKeyMessage);
        await conversationActions.updateLastMessage(
            conversationId, noKeyMessage.content);
        return;
      }

      final aiClient = AIClientFactory.create(config);
      final systemPrompt = SystemPromptBuilder.build(agent);

      // Get history messages for context
      final messages = await messageRepo.getMessages(conversationId);
      final history = messages
          .where((m) => m.type == MessageType.text || m.type == MessageType.voice)
          .map((m) => ChatMessage(
                role: m.sender == MessageSender.user ? 'user' : 'assistant',
                content: m.content,
              ))
          .toList();
      // Remove the last message (current user message) since we send it separately
      if (history.isNotEmpty) history.removeLast();

      // Stream response
      final buffer = StringBuffer();
      _ref.read(streamingMessageProvider.notifier).state = '';

      await for (final token in aiClient.streamMessage(
        systemPrompt: systemPrompt,
        history: history,
        userMessage: content,
      )) {
        buffer.write(token);
        _ref.read(streamingMessageProvider.notifier).state = buffer.toString();
      }

      _ref.read(streamingMessageProvider.notifier).state = null;

      final responseText = buffer.toString();
      final correction = _parseCorrection(responseText);
      final cleanContent = _removeCorrection(responseText);

      // Save agent response
      final agentMessage = Message(
        id: (DateTime.now().millisecondsSinceEpoch + 1).toString(),
        conversationId: conversationId,
        sender: MessageSender.agent,
        type: MessageType.text,
        content: cleanContent,
        correction: correction,
        status: MessageStatus.sent,
        createdAt: DateTime.now(),
      );
      await messageRepo.insertMessage(agentMessage);

      // Save correction as separate message if exists
      if (correction != null) {
        final correctionMessage = Message(
          id: (DateTime.now().millisecondsSinceEpoch + 2).toString(),
          conversationId: conversationId,
          sender: MessageSender.agent,
          type: MessageType.correction,
          content: correction.correctedText,
          correction: correction,
          status: MessageStatus.sent,
          createdAt: DateTime.now(),
        );
        await messageRepo.insertMessage(correctionMessage);
      }

      await conversationActions.updateLastMessage(conversationId, cleanContent);
    } catch (e) {
      _ref.read(streamingMessageProvider.notifier).state = null;

      final errorMessage = Message(
        id: (DateTime.now().millisecondsSinceEpoch + 1).toString(),
        conversationId: conversationId,
        sender: MessageSender.agent,
        type: MessageType.systemNotice,
        content: '发送失败: ${e.toString().length > 100 ? '${e.toString().substring(0, 100)}...' : e}',
        status: MessageStatus.failed,
        createdAt: DateTime.now(),
      );
      await messageRepo.insertMessage(errorMessage);
    }
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

  String _removeCorrection(String text) {
    return text.replaceAll(RegExp(r'```correction\s*[\s\S]*?```'), '').trim();
  }
}
