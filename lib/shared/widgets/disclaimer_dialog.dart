import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:engicore/core/constants/app_colors.dart';
import 'package:engicore/core/constants/dimens.dart';
import 'package:engicore/core/localization/localization_service.dart';

/// A glassmorphism-styled disclaimer dialog for first-run legal acknowledgment.
class DisclaimerDialog extends ConsumerStatefulWidget {
  const DisclaimerDialog({super.key});

  @override
  ConsumerState<DisclaimerDialog> createState() => _DisclaimerDialogState();
}

class _DisclaimerDialogState extends ConsumerState<DisclaimerDialog> {
  bool _isAgreed = false;

  static const String _linkedInUrl =
      'https://www.linkedin.com/company/pikolab-engineering';

  Future<void> _openLinkedIn() async {
    final uri = Uri.parse(_linkedInUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final strings = ref.strings;
    final screenSize = MediaQuery.of(context).size;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(
        horizontal: Dimens.spacingLg,
        vertical: Dimens.spacingXl,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            constraints: BoxConstraints(
              maxWidth: 400,
              maxHeight: screenSize.height * 0.75,
            ),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.black.withValues(alpha: 0.85)
                  : Colors.white.withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.1)
                    : Colors.black.withValues(alpha: 0.05),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header with icon and title
                _HeaderSection(strings: strings, isDark: isDark, theme: theme),

                // Scrollable disclaimer text
                Flexible(
                  child: _DisclaimerTextSection(
                    strings: strings,
                    isDark: isDark,
                    theme: theme,
                  ),
                ),

                // Actions section
                _ActionsSection(
                  strings: strings,
                  isDark: isDark,
                  theme: theme,
                  isAgreed: _isAgreed,
                  onAgreedChanged: (value) => setState(() => _isAgreed = value),
                  onLinkedInTap: _openLinkedIn,
                  onStartTap: () => Navigator.of(context).pop(true),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Header section with warning icon and title.
class _HeaderSection extends StatelessWidget {
  const _HeaderSection({
    required this.strings,
    required this.isDark,
    required this.theme,
  });

  final AppStrings strings;
  final bool isDark;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(Dimens.spacingLg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.warning.withValues(alpha: 0.15),
            AppColors.warning.withValues(alpha: 0.05),
          ],
        ),
        border: Border(
          bottom: BorderSide(
            color: isDark
                ? Colors.white.withValues(alpha: 0.1)
                : Colors.black.withValues(alpha: 0.05),
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(Dimens.spacingMd),
            decoration: BoxDecoration(
              color: AppColors.warning.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(Dimens.radiusMd),
              boxShadow: [
                BoxShadow(
                  color: AppColors.warning.withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(
              Icons.shield_outlined,
              color: AppColors.warning,
              size: 28,
            ),
          ),
          const SizedBox(width: Dimens.spacingMd),
          Expanded(
            child: Text(
              strings.disclaimerTitle,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: isDark
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimaryLight,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Scrollable disclaimer text section.
class _DisclaimerTextSection extends StatelessWidget {
  const _DisclaimerTextSection({
    required this.strings,
    required this.isDark,
    required this.theme,
  });

  final AppStrings strings;
  final bool isDark;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(Dimens.spacingLg),
      child: Text(
        strings.disclaimerText,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: isDark
              ? AppColors.textSecondaryDark
              : AppColors.textSecondaryLight,
          height: 1.6,
        ),
      ),
    );
  }
}

/// Actions section with LinkedIn button, checkbox, and start button.
class _ActionsSection extends StatelessWidget {
  const _ActionsSection({
    required this.strings,
    required this.isDark,
    required this.theme,
    required this.isAgreed,
    required this.onAgreedChanged,
    required this.onLinkedInTap,
    required this.onStartTap,
  });

  final AppStrings strings;
  final bool isDark;
  final ThemeData theme;
  final bool isAgreed;
  final ValueChanged<bool> onAgreedChanged;
  final VoidCallback onLinkedInTap;
  final VoidCallback onStartTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(Dimens.spacingLg),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.03)
            : Colors.black.withValues(alpha: 0.02),
        border: Border(
          top: BorderSide(
            color: isDark
                ? Colors.white.withValues(alpha: 0.1)
                : Colors.black.withValues(alpha: 0.05),
          ),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // LinkedIn Follow Button
          _LinkedInButton(
            label: strings.followButton,
            onTap: onLinkedInTap,
          ),

          const SizedBox(height: Dimens.spacingMd),

          // Checkbox
          _AgreementCheckbox(
            label: strings.agreeButton,
            isChecked: isAgreed,
            onChanged: onAgreedChanged,
            isDark: isDark,
            theme: theme,
          ),

          const SizedBox(height: Dimens.spacingMd),

          // Start Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: isAgreed ? onStartTap : null,
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    isAgreed ? AppColors.accent : Colors.grey.shade400,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: Dimens.spacingMd),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(Dimens.radiusMd),
                ),
                elevation: isAgreed ? 4 : 0,
              ),
              child: Text(
                strings.startButton,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// LinkedIn follow button with brand styling.
class _LinkedInButton extends StatelessWidget {
  const _LinkedInButton({
    required this.label,
    required this.onTap,
  });

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    const linkedInBlue = Color(0xFF0A66C2);

    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          foregroundColor: linkedInBlue,
          side: const BorderSide(color: linkedInBlue, width: 1.5),
          padding: const EdgeInsets.symmetric(vertical: Dimens.spacingMd),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(Dimens.radiusMd),
          ),
        ),
        icon: const Icon(Icons.link, size: 20),
        label: Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}

/// Custom checkbox with label.
class _AgreementCheckbox extends StatelessWidget {
  const _AgreementCheckbox({
    required this.label,
    required this.isChecked,
    required this.onChanged,
    required this.isDark,
    required this.theme,
  });

  final String label;
  final bool isChecked;
  final ValueChanged<bool> onChanged;
  final bool isDark;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onChanged(!isChecked),
      borderRadius: BorderRadius.circular(Dimens.radiusMd),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: Dimens.spacingSm,
          vertical: Dimens.spacingXs,
        ),
        child: Row(
          children: [
            SizedBox(
              width: 24,
              height: 24,
              child: Checkbox(
                value: isChecked,
                onChanged: (value) => onChanged(value ?? false),
                activeColor: AppColors.accent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            const SizedBox(width: Dimens.spacingSm),
            Expanded(
              child: Text(
                label,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimaryLight,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
