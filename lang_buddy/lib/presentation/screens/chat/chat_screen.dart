import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../domain/entities/agent.dart';
import '../../../domain/entities/message.dart';
import '../../providers/chat_provider.dart';
import '../../widgets/chat/chat_bubble.dart';
import '../../widgets/chat/chat_input_bar.dart';
import '../../widgets/chat/correction_bubble.dart';
import '../../widgets/chat/typing_indicator.dart';
import '../../widgets/chat/voice_bubble.dart';
import '../../widgets/common/avatar_widget.dart';

class ChatScreen extends ConsumerStatefulWidget {
  final String conversationId;
  final Agent agent;

  const ChatScreen({
    super.key,
    required this.conversationId,
    required this.agent,
  });

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final messagesAsync = ref.watch(chatMessagesProvider(widget.conversationId));
    final streamingMessage = ref.watch(streamingMessageProvider);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.appBarDark,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AvatarWidget(
              name: widget.agent.name,
              size: 32,
            ),
            const SizedBox(width: 8),
            Text(widget.agent.nameZh),
          ],
        ),
      ),
      backgroundColor: AppColors.chatBackground,
      body: Column(
        children: [
          Expanded(
            child: messagesAsync.when(
              data: (messages) {
                _scrollToBottom();
                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: messages.length +
                      (streamingMessage != null ? 1 : 0),
                  itemBuilder: (context, index) {
                    // Streaming message at the end
                    if (index == messages.length && streamingMessage != null) {
                      return _buildStreamingBubble(streamingMessage);
                    }

                    final message = messages[index];
                    if (message.type == MessageType.correction &&
                        message.correction != null) {
                      return CorrectionBubble(correction: message.correction!);
                    }
                    if (message.type == MessageType.systemNotice) {
                      return _buildSystemNotice(message);
                    }
                    if (message.type == MessageType.voice) {
                      return VoiceBubble(message: message);
                    }
                    return ChatBubble(message: message);
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('加载失败: $e')),
            ),
          ),
          ChatInputBar(
            onSend: (text) {
              ref.read(chatActionsProvider).sendMessage(
                    conversationId: widget.conversationId,
                    content: text,
                    agent: widget.agent,
                  );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStreamingBubble(String text) {
    if (text.isEmpty) return const TypingIndicator();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.7,
              ),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.agentBubble,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                text,
                style: const TextStyle(
                  fontSize: 16,
                  color: AppColors.textPrimary,
                  height: 1.4,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSystemNotice(Message message) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 8),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.textSecondary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            message.content,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
