import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:engicore/core/constants/app_colors.dart';
import 'package:engicore/core/constants/dimens.dart';

/// A card widget for displaying calculation results.
///
/// Features:
/// - Displays label, value, and unit
/// - Optional formula preview
/// - Copy-to-clipboard functionality
/// - Animated value changes
class ResultCard extends StatelessWidget {
  const ResultCard({
    required this.label,
    required this.value,
    this.unit,
    this.formula,
    this.precision = 4,
    this.accentColor,
    this.showCopyButton = true,
    super.key,
  });

  /// Label describing the result.
  final String label;

  /// Calculated value.
  final double? value;

  /// Unit of the result.
  final String? unit;

  /// Optional formula string (e.g., "V = I × R").
  final String? formula;

  /// Decimal precision for display.
  final int precision;

  /// Accent color for the value (defaults to primary).
  final Color? accentColor;

  /// Whether to show copy button.
  final bool showCopyButton;

  String get _formattedValue {
    if (value == null) return '—';
    if (value!.isNaN || value!.isInfinite) return 'Invalid';

    // Format with appropriate precision
    final formatted = value!.toStringAsFixed(precision);
    // Remove trailing zeros
    return formatted.replaceAll(RegExp(r'\.?0+$'), '');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final effectiveAccent = accentColor ?? AppColors.primary;

    return Container(
      padding: const EdgeInsets.all(Dimens.spacingMd),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.cardLight,
        borderRadius: BorderRadius.circular(Dimens.radiusLg),
        border: Border.all(
          color: effectiveAccent.withValues(alpha: 0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: effectiveAccent.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: theme.textTheme.labelLarge?.copyWith(
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondaryLight,
                ),
              ),
              if (showCopyButton && value != null)
                _CopyButton(value: '$_formattedValue ${unit ?? ''}'.trim()),
            ],
          ),
          const SizedBox(height: Dimens.spacingXs),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                _formattedValue,
                style: theme.textTheme.headlineMedium?.copyWith(
                  color: effectiveAccent,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (unit != null) ...[
                const SizedBox(width: Dimens.spacingXs),
                Text(
                  unit!,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight,
                  ),
                ),
              ],
            ],
          ),
          if (formula != null) ...[
            const SizedBox(height: Dimens.spacingSm),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: Dimens.spacingSm,
                vertical: Dimens.spacingXxs,
              ),
              decoration: BoxDecoration(
                color: effectiveAccent.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(Dimens.radiusSm),
              ),
              child: Text(
                formula!,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontFamily: 'monospace',
                  color: effectiveAccent,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Copy button for result values.
class _CopyButton extends StatefulWidget {
  const _CopyButton({required this.value});

  final String value;

  @override
  State<_CopyButton> createState() => _CopyButtonState();
}

class _CopyButtonState extends State<_CopyButton> {
  bool _copied = false;

  Future<void> _copyToClipboard() async {
    await Clipboard.setData(ClipboardData(text: widget.value));
    setState(() => _copied = true);
    await Future<void>.delayed(const Duration(seconds: 2));
    if (mounted) setState(() => _copied = false);
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: _copyToClipboard,
      icon: Icon(
        _copied ? Icons.check : Icons.copy,
        size: Dimens.iconSm,
        color: _copied ? AppColors.success : AppColors.textSecondaryDark,
      ),
      tooltip: 'Copy value',
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(
        minWidth: Dimens.touchTargetMin,
        minHeight: Dimens.touchTargetMin,
      ),
    );
  }
}
