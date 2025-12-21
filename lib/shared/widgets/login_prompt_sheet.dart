import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:engicore/core/constants/app_colors.dart';
import 'package:engicore/core/constants/dimens.dart';
import 'package:engicore/core/services/auth_service.dart';

/// LinkedIn-style blue color for professional sign-in.
const Color _linkedInBlue = Color(0xFF0077B5);

/// Bottom sheet prompting users to sign in for premium features.
///
/// Shows when guest users try to access:
/// - Export PDF
/// - Save to History
/// - Pikolab Connect
class LoginPromptSheet extends ConsumerStatefulWidget {
  const LoginPromptSheet({
    super.key,
    required this.featureName,
    this.onLoginSuccess,
  });

  /// Name of the feature being accessed (for context).
  final String featureName;

  /// Callback when login succeeds.
  final VoidCallback? onLoginSuccess;

  /// Show the login prompt sheet.
  static Future<bool> show(
    BuildContext context, {
    required String featureName,
    VoidCallback? onLoginSuccess,
  }) async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => LoginPromptSheet(
        featureName: featureName,
        onLoginSuccess: onLoginSuccess,
      ),
    );
    return result ?? false;
  }

  @override
  ConsumerState<LoginPromptSheet> createState() => _LoginPromptSheetState();
}

class _LoginPromptSheetState extends ConsumerState<LoginPromptSheet> {
  bool _isLoading = false;

  Future<void> _signInWithGoogle() async {
    setState(() => _isLoading = true);

    try {
      final authService = ref.read(authServiceProvider);
      final user = await authService.signInWithGoogle();

      if (user != null && mounted) {
        // Set user as pro after successful login
        await authService.setProUser(true);
        widget.onLoginSuccess?.call();
        Navigator.of(context).pop(true);
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Sign-in was cancelled or failed'),
            backgroundColor: AppColors.warning,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Sign-in error: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _continueAsGuest() {
    Navigator.of(context).pop(false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(Dimens.radiusXl),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(Dimens.spacingLg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondaryLight,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: Dimens.spacingLg),

              // Icon
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      _linkedInBlue.withValues(alpha: 0.2),
                      AppColors.accent.withValues(alpha: 0.2),
                    ],
                  ),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.lock_open_rounded,
                  size: 40,
                  color: _linkedInBlue,
                ),
              ),
              const SizedBox(height: Dimens.spacingLg),

              // Header
              Text(
                'Unlock Professional Features',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: Dimens.spacingMd),

              // Body
              Text(
                'Sign in to ${widget.featureName.toLowerCase()}, save your calculations, and generate branded engineering reports powered by Pikolab.',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondaryLight,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: Dimens.spacingXl),

              // Sign in with Google button (styled professionally)
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _signInWithGoogle,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _linkedInBlue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(Dimens.radiusMd),
                    ),
                    elevation: 2,
                  ),
                  icon: _isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.business, size: 24),
                  label: Text(
                    _isLoading ? 'Signing in...' : 'Sign in with Google',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: Dimens.spacingMd),

              // Continue as guest
              TextButton(
                onPressed: _continueAsGuest,
                child: Text(
                  'Continue as Guest',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight,
                  ),
                ),
              ),
              const SizedBox(height: Dimens.spacingMd),
            ],
          ),
        ),
      ),
    );
  }
}
