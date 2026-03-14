import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';

class ChatInputBar extends StatefulWidget {
  final Function(String) onSend;
  final VoidCallback? onVoiceStart;
  final VoidCallback? onVoiceEnd;

  const ChatInputBar({
    super.key,
    required this.onSend,
    this.onVoiceStart,
    this.onVoiceEnd,
  });

  @override
  State<ChatInputBar> createState() => _ChatInputBarState();
}

class _ChatInputBarState extends State<ChatInputBar> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  bool _hasText = false;
  bool _voiceMode = false;
  bool _recording = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      final hasText = _controller.text.trim().isNotEmpty;
      if (hasText != _hasText) {
        setState(() => _hasText = hasText);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _handleSend() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    widget.onSend(text);
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: AppDimensions.sm,
        right: AppDimensions.sm,
        top: AppDimensions.sm,
        bottom: MediaQuery.of(context).padding.bottom + AppDimensions.sm,
      ),
      decoration: const BoxDecoration(
        color: AppColors.inputBackground,
        border: Border(
          top: BorderSide(color: AppColors.divider, width: 0.5),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Voice/keyboard toggle button
          IconButton(
            icon: Icon(
              _voiceMode ? Icons.keyboard : Icons.mic_none,
              color: AppColors.textSecondary,
            ),
            onPressed: () {
              setState(() {
                _voiceMode = !_voiceMode;
                if (_voiceMode) {
                  _focusNode.unfocus();
                } else {
                  _focusNode.requestFocus();
                }
              });
            },
          ),
          // Text input or voice button
          Expanded(
            child: _voiceMode ? _buildVoiceButton() : _buildTextInput(),
          ),
          const SizedBox(width: AppDimensions.xs),
          // Send button
          if (_hasText && !_voiceMode)
            GestureDetector(
              onTap: _handleSend,
              child: Container(
                padding: const EdgeInsets.all(AppDimensions.sm),
                decoration: BoxDecoration(
                  color: AppColors.primaryGreen,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                ),
                child: const Icon(
                  Icons.send,
                  color: AppColors.white,
                  size: 20,
                ),
              ),
            )
          else if (!_voiceMode)
            IconButton(
              icon: const Icon(Icons.add_circle_outline,
                  color: AppColors.textSecondary),
              onPressed: () {},
            ),
        ],
      ),
    );
  }

  Widget _buildTextInput() {
    return Container(
      constraints: const BoxConstraints(maxHeight: 120),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
      ),
      child: TextField(
        controller: _controller,
        focusNode: _focusNode,
        maxLines: null,
        textInputAction: TextInputAction.newline,
        decoration: const InputDecoration(
          hintText: '输入消息...',
          hintStyle: TextStyle(color: AppColors.textHint),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            horizontal: AppDimensions.md,
            vertical: AppDimensions.sm,
          ),
        ),
        style: const TextStyle(
          fontSize: AppDimensions.fontLg,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }

  Widget _buildVoiceButton() {
    return GestureDetector(
      onLongPressStart: (_) {
        setState(() => _recording = true);
        widget.onVoiceStart?.call();
      },
      onLongPressEnd: (_) {
        setState(() => _recording = false);
        widget.onVoiceEnd?.call();
      },
      child: Container(
        height: 40,
        decoration: BoxDecoration(
          color: _recording ? AppColors.chatBackground : AppColors.white,
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          border: Border.all(
            color: _recording ? AppColors.primaryGreen : AppColors.divider,
            width: _recording ? 2 : 1,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          _recording ? '松开 发送' : '按住 说话',
          style: TextStyle(
            fontSize: AppDimensions.fontLg,
            color: _recording ? AppColors.primaryGreen : AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
