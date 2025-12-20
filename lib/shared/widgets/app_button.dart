import 'package:flutter/material.dart';

import 'package:engicore/core/constants/app_colors.dart';
import 'package:engicore/core/constants/dimens.dart';

/// Button variants for the app.
enum AppButtonVariant {
  /// Primary action button (e.g., Calculate).
  primary,

  /// Secondary action button (e.g., Clear).
  secondary,

  /// Outlined button variant.
  outlined,
}

/// A styled button for engineering calculations.
///
/// Provides consistent styling across the app with
/// industrial-sized touch targets.
class AppButton extends StatelessWidget {
  const AppButton({
    required this.label,
    required this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.icon,
    this.isLoading = false,
    this.isExpanded = true,
    super.key,
  });

  /// Button label text.
  final String label;

  /// Callback when button is pressed.
  final VoidCallback? onPressed;

  /// Button variant (primary, secondary, outlined).
  final AppButtonVariant variant;

  /// Optional leading icon.
  final IconData? icon;

  /// Whether to show loading indicator.
  final bool isLoading;

  /// Whether button should expand to full width.
  final bool isExpanded;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final buttonStyle = switch (variant) {
      AppButtonVariant.primary => ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          minimumSize: Size(
            isExpanded ? double.infinity : 0,
            Dimens.touchTargetMin,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: Dimens.spacingLg,
            vertical: Dimens.spacingMd,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(Dimens.radiusMd),
          ),
          elevation: Dimens.elevationMd,
        ),
      AppButtonVariant.secondary => ElevatedButton.styleFrom(
          backgroundColor: theme.brightness == Brightness.dark
              ? AppColors.cardDark
              : AppColors.cardLight,
          foregroundColor: theme.brightness == Brightness.dark
              ? AppColors.textPrimaryDark
              : AppColors.textPrimaryLight,
          minimumSize: Size(
            isExpanded ? double.infinity : 0,
            Dimens.touchTargetMin,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: Dimens.spacingLg,
            vertical: Dimens.spacingMd,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(Dimens.radiusMd),
          ),
          elevation: 0,
        ),
      AppButtonVariant.outlined => OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          minimumSize: Size(
            isExpanded ? double.infinity : 0,
            Dimens.touchTargetMin,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: Dimens.spacingLg,
            vertical: Dimens.spacingMd,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(Dimens.radiusMd),
          ),
          side: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
    };

    final child = isLoading
        ? const SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Colors.white,
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, size: Dimens.iconMd),
                const SizedBox(width: Dimens.spacingSm),
              ],
              Text(
                label,
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          );

    return switch (variant) {
      AppButtonVariant.outlined => OutlinedButton(
          onPressed: isLoading ? null : onPressed,
          style: buttonStyle,
          child: child,
        ),
      _ => ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: buttonStyle,
          child: child,
        ),
    };
  }
}
