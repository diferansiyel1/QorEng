import 'package:flutter/material.dart';

import 'package:engicore/core/constants/app_colors.dart';
import 'package:engicore/core/constants/dimens.dart';

/// A card widget to display when calculation input is invalid.
///
/// Used when:
/// - Division by zero would occur
/// - Negative values are entered for physically non-negative quantities
/// - Required inputs are missing or malformed
class InvalidInputCard extends StatelessWidget {
  const InvalidInputCard({
    this.message = 'Check your input parameters',
    this.icon = Icons.warning_amber_rounded,
    super.key,
  });

  /// Message to display to the user.
  final String message;

  /// Icon to display (defaults to warning icon).
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(Dimens.spacingLg),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(Dimens.radiusLg),
        border: Border.all(
          color: AppColors.warning,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.warning.withValues(alpha: 0.15),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(Dimens.spacingSm),
            decoration: BoxDecoration(
              color: AppColors.warning.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: AppColors.warning,
              size: Dimens.iconMd,
            ),
          ),
          const SizedBox(width: Dimens.spacingMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Invalid Input',
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: AppColors.warning,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: Dimens.spacingXxs),
                Text(
                  message,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
