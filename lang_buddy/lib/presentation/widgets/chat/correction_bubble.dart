import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../domain/entities/correction.dart';

class CorrectionBubble extends StatefulWidget {
  final Correction correction;

  const CorrectionBubble({super.key, required this.correction});

  @override
  State<CorrectionBubble> createState() => _CorrectionBubbleState();
}

class _CorrectionBubbleState extends State<CorrectionBubble> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.lg,
        vertical: AppDimensions.xs,
      ),
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.85,
        ),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF9E6),
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          border: Border.all(color: const Color(0xFFFFE4B5)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            InkWell(
              onTap: () => setState(() => _expanded = !_expanded),
              child: Padding(
                padding: const EdgeInsets.all(AppDimensions.md),
                child: Row(
                  children: [
                    const Icon(Icons.auto_fix_high,
                        size: 18, color: Color(0xFFFF8F1F)),
                    const SizedBox(width: AppDimensions.sm),
                    const Text(
                      '语法纠正',
                      style: TextStyle(
                        fontSize: AppDimensions.fontMd,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFFF8F1F),
                      ),
                    ),
                    const Spacer(),
                    Icon(
                      _expanded ? Icons.expand_less : Icons.expand_more,
                      color: AppColors.textSecondary,
                    ),
                  ],
                ),
              ),
            ),
            // Original vs Corrected
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppDimensions.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDiffRow('原文', widget.correction.originalText,
                      const Color(0xFFFA5151)),
                  const SizedBox(height: AppDimensions.sm),
                  _buildDiffRow('修改', widget.correction.correctedText,
                      AppColors.primaryGreen),
                ],
              ),
            ),
            // Expanded details
            if (_expanded) ...[
              const Divider(height: AppDimensions.lg),
              ...widget.correction.details.map(_buildDetailCard),
            ],
            const SizedBox(height: AppDimensions.md),
          ],
        ),
      ),
    );
  }

  Widget _buildDiffRow(String label, String text, Color color) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            label,
            style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w600),
          ),
        ),
        const SizedBox(width: AppDimensions.sm),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: AppDimensions.fontMd,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDetailCard(CorrectionDetail detail) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.md,
        vertical: AppDimensions.xs,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: TextSpan(
              style: const TextStyle(
                  fontSize: AppDimensions.fontMd, color: AppColors.textPrimary),
              children: [
                TextSpan(
                  text: detail.incorrect,
                  style: const TextStyle(
                    decoration: TextDecoration.lineThrough,
                    color: Color(0xFFFA5151),
                  ),
                ),
                const TextSpan(text: ' → '),
                TextSpan(
                  text: detail.correct,
                  style: const TextStyle(
                    color: AppColors.primaryGreen,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            detail.explanationZh,
            style: const TextStyle(
              fontSize: AppDimensions.fontSm,
              color: AppColors.textSecondary,
            ),
          ),
          if (detail.example != null) ...[
            const SizedBox(height: 2),
            Text(
              '例: ${detail.example}',
              style: const TextStyle(
                fontSize: AppDimensions.fontSm,
                color: AppColors.textSecondary,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
