import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:engicore/core/constants/app_colors.dart';
import 'package:engicore/core/constants/dimens.dart';

/// A custom numeric keypad optimized for one-handed usage.
///
/// Features large buttons for easy thumb access and supports decimal input.
class NumericKeypad extends StatelessWidget {
  const NumericKeypad({
    super.key,
    required this.onDigit,
    required this.onDecimal,
    required this.onBackspace,
    required this.onClear,
    this.showClear = true,
    this.buttonHeight = 64.0,
  });

  /// Called when a digit (0-9) is pressed.
  final ValueChanged<String> onDigit;

  /// Called when the decimal point is pressed.
  final VoidCallback onDecimal;

  /// Called when the backspace button is pressed.
  final VoidCallback onBackspace;

  /// Called when the clear button is pressed.
  final VoidCallback onClear;

  /// Whether to show the clear button.
  final bool showClear;

  /// Height of each button.
  final double buttonHeight;

  void _handleTap(String value) {
    HapticFeedback.lightImpact();
    if (value == '.') {
      onDecimal();
    } else if (value == '⌫') {
      onBackspace();
    } else if (value == 'C') {
      onClear();
    } else {
      onDigit(value);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(Dimens.spacingMd),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(Dimens.radiusLg),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Row 1: 1 2 3
            _buildRow(['1', '2', '3'], isDark),
            const SizedBox(height: Dimens.spacingSm),
            // Row 2: 4 5 6
            _buildRow(['4', '5', '6'], isDark),
            const SizedBox(height: Dimens.spacingSm),
            // Row 3: 7 8 9
            _buildRow(['7', '8', '9'], isDark),
            const SizedBox(height: Dimens.spacingSm),
            // Row 4: . 0 ⌫ (or C)
            Row(
              children: [
                Expanded(
                  child: _KeypadButton(
                    label: '.',
                    onTap: () => _handleTap('.'),
                    height: buttonHeight,
                    isDark: isDark,
                  ),
                ),
                const SizedBox(width: Dimens.spacingSm),
                Expanded(
                  child: _KeypadButton(
                    label: '0',
                    onTap: () => _handleTap('0'),
                    height: buttonHeight,
                    isDark: isDark,
                  ),
                ),
                const SizedBox(width: Dimens.spacingSm),
                Expanded(
                  child: _KeypadButton(
                    label: '⌫',
                    onTap: () => _handleTap('⌫'),
                    height: buttonHeight,
                    isDark: isDark,
                    isAction: true,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRow(List<String> values, bool isDark) {
    return Row(
      children: values.asMap().entries.map((entry) {
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              left: entry.key == 0 ? 0 : Dimens.spacingSm / 2,
              right:
                  entry.key == values.length - 1 ? 0 : Dimens.spacingSm / 2,
            ),
            child: _KeypadButton(
              label: entry.value,
              onTap: () => _handleTap(entry.value),
              height: buttonHeight,
              isDark: isDark,
            ),
          ),
        );
      }).toList(),
    );
  }
}

/// A single keypad button.
class _KeypadButton extends StatelessWidget {
  const _KeypadButton({
    required this.label,
    required this.onTap,
    required this.height,
    required this.isDark,
    this.isAction = false,
  });

  final String label;
  final VoidCallback onTap;
  final double height;
  final bool isDark;
  final bool isAction;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isAction
          ? (isDark ? AppColors.cardDark : AppColors.cardLight)
          : (isDark
              ? AppColors.cardDark.withValues(alpha: 0.8)
              : AppColors.cardLight),
      borderRadius: BorderRadius.circular(Dimens.radiusMd),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(Dimens.radiusMd),
        child: Container(
          height: height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(Dimens.radiusMd),
            border: Border.all(
              color: isDark
                  ? AppColors.textSecondaryDark.withValues(alpha: 0.2)
                  : AppColors.textSecondaryLight.withValues(alpha: 0.2),
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: label == '⌫' ? 24 : 28,
                fontWeight: FontWeight.w600,
                color: isAction
                    ? AppColors.accent
                    : (isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimaryLight),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
