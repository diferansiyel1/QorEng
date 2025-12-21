import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:engicore/core/constants/app_colors.dart';
import 'package:engicore/core/constants/dimens.dart';
import 'package:engicore/features/history/domain/repositories/history_repository.dart';
import 'package:engicore/features/home/presentation/widgets/tool_search_delegate.dart';

/// Dashboard (Cockpit) home screen.
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 6) return 'Night Shift';
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    if (hour < 22) return 'Good Evening';
    return 'Night Shift';
  }

  String _getFormattedDate() {
    final now = DateTime.now();
    const days = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${days[now.weekday % 7]}, ${months[now.month - 1]} ${now.day}';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final recentRecords = ref.watch(historyRecordsProvider);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(Dimens.spacingMd),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              _DashboardHeader(
                greeting: _getGreeting(),
                date: _getFormattedDate(),
              ),

              const SizedBox(height: Dimens.spacingLg),

              // Search Bar (tap to open search)
              _SearchButton(
                onTap: () {
                  showSearch(
                    context: context,
                    delegate: ToolSearchDelegate(),
                  );
                },
              ),

              const SizedBox(height: Dimens.spacingXl),

              // Quick Access Section
              Text(
                'Quick Access',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: Dimens.spacingMd),
              const _QuickAccessGrid(),

              const SizedBox(height: Dimens.spacingXl),

              // Recent Activity Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Recent Activity',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed: () => context.go('/history'),
                    child: const Text(
                      'See All',
                      style: TextStyle(
                        color: AppColors.accent,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: Dimens.spacingSm),

              if (recentRecords.isEmpty)
                Container(
                  padding: const EdgeInsets.all(Dimens.spacingLg),
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.cardDark
                        : AppColors.cardLight,
                    borderRadius: BorderRadius.circular(Dimens.radiusMd),
                  ),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(
                          Icons.history,
                          size: 40,
                          color: isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondaryLight,
                        ),
                        const SizedBox(height: Dimens.spacingSm),
                        Text(
                          'No calculations yet',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: isDark
                                ? AppColors.textSecondaryDark
                                : AppColors.textSecondaryLight,
                          ),
                        ),
                        Text(
                          'Your recent calculations will appear here',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: isDark
                                ? AppColors.textSecondaryDark
                                : AppColors.textSecondaryLight,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                ...recentRecords.take(3).map((record) {
                  return _RecentActivityCard(
                    title: record.title,
                    result: record.resultValue,
                    moduleType: record.moduleType.name,
                    timestamp: record.timestamp,
                  );
                }),
            ],
          ),
        ),
      ),
    );
  }
}

/// Dashboard header with greeting and date.
class _DashboardHeader extends StatelessWidget {
  const _DashboardHeader({
    required this.greeting,
    required this.date,
  });

  final String greeting;
  final String date;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              greeting,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Engineer 🔧',
              style: theme.textTheme.titleLarge?.copyWith(
                color: AppColors.accent,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: Dimens.spacingMd,
            vertical: Dimens.spacingSm,
          ),
          decoration: BoxDecoration(
            color: isDark ? AppColors.cardDark : AppColors.cardLight,
            borderRadius: BorderRadius.circular(Dimens.radiusMd),
          ),
          child: Text(
            date,
            style: theme.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}

/// Fake search input that opens the search delegate.
class _SearchButton extends StatelessWidget {
  const _SearchButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: Dimens.inputHeightLg,
        padding: const EdgeInsets.symmetric(horizontal: Dimens.spacingMd),
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : AppColors.cardLight,
          borderRadius: BorderRadius.circular(Dimens.radiusMd),
          border: Border.all(
            color: isDark
                ? AppColors.textSecondaryDark.withValues(alpha: 0.3)
                : AppColors.textSecondaryLight.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.search,
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
            ),
            const SizedBox(width: Dimens.spacingMd),
            Text(
              'Search tools...',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Quick access grid with popular tools.
class _QuickAccessGrid extends StatelessWidget {
  const _QuickAccessGrid();

  static const _quickTools = [
    (
      title: 'Voltage Drop',
      icon: Icons.bolt,
      color: Color(0xFFFFC107),
      route: '/electrical/voltage-drop',
    ),
    (
      title: 'Hydraulic Force',
      icon: Icons.compress,
      color: Color(0xFFFF6D00),
      route: '/mechanical/hydraulic-force',
    ),
    (
      title: 'Signal Scaler',
      icon: Icons.straighten,
      color: Color(0xFF00E5FF),
      route: '/electrical/signal-scaler',
    ),
    (
      title: 'Dilution',
      icon: Icons.science,
      color: Color(0xFF7C4DFF),
      route: '/chemical/dilution',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: Dimens.spacingMd,
        crossAxisSpacing: Dimens.spacingMd,
        childAspectRatio: 1.5,
      ),
      itemCount: _quickTools.length,
      itemBuilder: (context, index) {
        final tool = _quickTools[index];
        return _QuickAccessCard(
          title: tool.title,
          icon: tool.icon,
          color: tool.color,
          onTap: () => context.push(tool.route),
        );
      },
    );
  }
}

/// Quick access card widget.
class _QuickAccessCard extends StatelessWidget {
  const _QuickAccessCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: Dimens.elevationMd,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(Dimens.radiusMd),
        child: Container(
          padding: const EdgeInsets.all(Dimens.spacingMd),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(Dimens.radiusMd),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                color.withValues(alpha: 0.15),
                color.withValues(alpha: 0.05),
              ],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(Dimens.spacingSm),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(Dimens.radiusSm),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: Dimens.iconMd,
                ),
              ),
              Text(
                title,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Recent activity card.
class _RecentActivityCard extends StatelessWidget {
  const _RecentActivityCard({
    required this.title,
    required this.result,
    required this.moduleType,
    required this.timestamp,
  });

  final String title;
  final String result;
  final String moduleType;
  final DateTime timestamp;

  IconData get _moduleIcon {
    return switch (moduleType) {
      'electrical' => Icons.bolt,
      'mechanical' => Icons.construction,
      'chemical' => Icons.science,
      'bioprocess' => Icons.biotech,
      _ => Icons.calculate,
    };
  }

  Color get _moduleColor {
    return switch (moduleType) {
      'electrical' => AppColors.electricalAccent,
      'mechanical' => AppColors.mechanicalAccent,
      'chemical' => AppColors.chemicalAccent,
      'bioprocess' => AppColors.bioprocessAccent,
      _ => AppColors.accent,
    };
  }

  String _formatTime(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);

    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: Dimens.spacingSm),
      padding: const EdgeInsets.all(Dimens.spacingMd),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.cardLight,
        borderRadius: BorderRadius.circular(Dimens.radiusMd),
      ),
      child: Row(
        children: [
          // Module icon
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _moduleColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(Dimens.radiusSm),
            ),
            child: Icon(
              _moduleIcon,
              color: _moduleColor,
              size: Dimens.iconMd,
            ),
          ),
          const SizedBox(width: Dimens.spacingMd),

          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  result,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight,
                  ),
                ),
              ],
            ),
          ),

          // Time
          Text(
            _formatTime(timestamp),
            style: theme.textTheme.labelSmall?.copyWith(
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
            ),
          ),
        ],
      ),
    );
  }
}
