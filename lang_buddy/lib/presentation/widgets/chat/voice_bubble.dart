import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../domain/entities/message.dart';

class VoiceBubble extends StatefulWidget {
  final Message message;

  const VoiceBubble({super.key, required this.message});

  @override
  State<VoiceBubble> createState() => _VoiceBubbleState();
}

class _VoiceBubbleState extends State<VoiceBubble>
    with SingleTickerProviderStateMixin {
  bool _isPlaying = false;
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _togglePlay() {
    setState(() {
      _isPlaying = !_isPlaying;
      if (_isPlaying) {
        _animController.repeat();
      } else {
        _animController.stop();
        _animController.reset();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isUser = widget.message.sender == MessageSender.user;
    final durationSec = (widget.message.audioDurationMs ?? 0) ~/ 1000;
    // Width scales with duration (min 80, max 200)
    final width = (80 + durationSec * 12).clamp(80, 200).toDouble();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: _togglePlay,
            child: Container(
              width: width,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: isUser ? AppColors.userBubble : AppColors.agentBubble,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: isUser
                    ? [
                        Text('$durationSec"',
                            style: const TextStyle(
                                fontSize: 14, color: AppColors.textPrimary)),
                        const Spacer(),
                        _buildWaveform(),
                      ]
                    : [
                        _buildWaveform(),
                        const Spacer(),
                        Text('$durationSec"',
                            style: const TextStyle(
                                fontSize: 14, color: AppColors.textPrimary)),
                      ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWaveform() {
    return AnimatedBuilder(
      animation: _animController,
      builder: (context, _) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (i) {
            final double opacity;
            if (_isPlaying) {
              final phase = (_animController.value + i * 0.3) % 1.0;
              opacity = 0.4 + 0.6 * (phase < 0.5 ? phase * 2 : 2 - phase * 2);
            } else {
              opacity = 1.0;
            }
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 1),
              width: 3,
              height: 10 + i * 4.0,
              decoration: BoxDecoration(
                color: AppColors.textPrimary.withValues(alpha: opacity),
                borderRadius: BorderRadius.circular(1.5),
              ),
            );
          }),
        );
      },
    );
  }
}
