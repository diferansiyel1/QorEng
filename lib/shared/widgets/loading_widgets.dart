import 'package:flutter/material.dart';

import 'package:engicore/core/constants/app_colors.dart';
import 'package:engicore/core/constants/dimens.dart';

/// Custom shimmer loading effect widget.
///
/// Uses Flutter's built-in animation without external dependencies.
class ShimmerLoading extends StatefulWidget {
  const ShimmerLoading({
    super.key,
    required this.child,
    this.enabled = true,
  });

  /// The child widget to apply shimmer effect to.
  final Widget child;

  /// Whether the shimmer effect is enabled.
  final bool enabled;

  @override
  State<ShimmerLoading> createState() => _ShimmerLoadingState();
}

class _ShimmerLoadingState extends State<ShimmerLoading>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
    _animation = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) return widget.child;

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: const [
                Colors.grey,
                Colors.white,
                Colors.grey,
              ],
              stops: [
                _animation.value - 0.3,
                _animation.value,
                _animation.value + 0.3,
              ],
            ).createShader(bounds);
          },
          blendMode: BlendMode.srcATop,
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

/// Shimmer placeholder for a single line of text.
class ShimmerTextLine extends StatelessWidget {
  const ShimmerTextLine({
    super.key,
    this.width = double.infinity,
    this.height = 16,
  });

  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: isDark ? Colors.grey.shade800 : Colors.grey.shade300,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}

/// Shimmer placeholder for recent activity cards.
class ShimmerActivityCard extends StatelessWidget {
  const ShimmerActivityCard({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark ? Colors.grey.shade800 : Colors.grey.shade300;

    return ShimmerLoading(
      child: Container(
        padding: const EdgeInsets.all(Dimens.spacingMd),
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : AppColors.cardLight,
          borderRadius: BorderRadius.circular(Dimens.radiusMd),
          border: Border.all(
            color: baseColor.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          children: [
            // Icon placeholder
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: baseColor,
                borderRadius: BorderRadius.circular(Dimens.radiusMd),
              ),
            ),
            const SizedBox(width: Dimens.spacingMd),
            // Content placeholder
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 120,
                    height: 14,
                    decoration: BoxDecoration(
                      color: baseColor,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: 80,
                    height: 12,
                    decoration: BoxDecoration(
                      color: baseColor.withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
            ),
            // Time placeholder
            Container(
              width: 40,
              height: 20,
              decoration: BoxDecoration(
                color: baseColor.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(Dimens.radiusSm),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Inline error card for displaying error states in the UI.
class InlineErrorCard extends StatelessWidget {
  const InlineErrorCard({
    super.key,
    required this.message,
    this.onRetry,
    this.icon = Icons.error_outline_rounded,
  });

  /// Error message to display.
  final String message;

  /// Optional retry callback.
  final VoidCallback? onRetry;

  /// Error icon.
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(Dimens.spacingMd),
      decoration: BoxDecoration(
        color: Colors.red.shade50.withValues(alpha: isDark ? 0.15 : 1.0),
        borderRadius: BorderRadius.circular(Dimens.radiusMd),
        border: Border.all(
          color: Colors.red.shade200.withValues(alpha: isDark ? 0.3 : 1.0),
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: Colors.red.shade400,
            size: 24,
          ),
          const SizedBox(width: Dimens.spacingSm),
          Expanded(
            child: Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isDark ? Colors.red.shade300 : Colors.red.shade700,
              ),
            ),
          ),
          if (onRetry != null)
            TextButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('Retry'),
              style: TextButton.styleFrom(
                foregroundColor: Colors.red.shade400,
                padding: const EdgeInsets.symmetric(
                  horizontal: Dimens.spacingSm,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
