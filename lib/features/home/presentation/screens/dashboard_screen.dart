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
          padding: const EdgeInsets.all(Dimens.spacingLg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with logo
              _DashboardHeader(
                greeting: _getGreeting(),
                date: _getFormattedDate(),
              ),

              const SizedBox(height: Dimens.spacingXl),

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

              // Modules Section
              Text(
                'Modules',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: Dimens.spacingMd),
              const _ModulesGrid(),

              const SizedBox(height: Dimens.spacingXl),

              // Quick Access Section
              Text(
                'Quick Access',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: Dimens.spacingMd),
              const _QuickAccessList(),

              const SizedBox(height: Dimens.spacingXl),

              // Recent Activity Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Recent Activity',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () => context.push('/history'),
                    icon: const Icon(Icons.arrow_forward, size: 16),
                    label: const Text('See All'),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.accent,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: Dimens.spacingSm),

              if (recentRecords.isEmpty)
                _EmptyRecentActivity(isDark: isDark, theme: theme)
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

/// Empty recent activity placeholder.
class _EmptyRecentActivity extends StatelessWidget {
  const _EmptyRecentActivity({
    required this.isDark,
    required this.theme,
  });

  final bool isDark;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(Dimens.spacingXl),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.cardLight,
        borderRadius: BorderRadius.circular(Dimens.radiusLg),
        border: Border.all(
          color: isDark
              ? AppColors.textSecondaryDark.withValues(alpha: 0.2)
              : AppColors.textSecondaryLight.withValues(alpha: 0.2),
        ),
      ),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.history_rounded,
              size: 48,
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
            ),
            const SizedBox(height: Dimens.spacingMd),
            Text(
              'No calculations yet',
              style: theme.textTheme.titleMedium?.copyWith(
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
              ),
            ),
            const SizedBox(height: Dimens.spacingXs),
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
    );
  }
}

/// Dashboard header with logo, greeting, and date.
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
      children: [
        // Logo
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: AppColors.accent.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(Dimens.radiusMd),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(Dimens.radiusMd),
            child: Image.asset(
              'assets/images/qoreng_logo.png',
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) => const Icon(
                Icons.engineering,
                color: AppColors.accent,
                size: 32,
              ),
            ),
          ),
        ),
        const SizedBox(width: Dimens.spacingMd),

        // Greeting
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                greeting,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimaryLight,
                ),
              ),
              Text(
                'Engineer',
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: AppColors.accent,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),

        // Date badge
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: Dimens.spacingMd,
            vertical: Dimens.spacingSm,
          ),
          decoration: BoxDecoration(
            color: isDark ? AppColors.cardDark : AppColors.cardLight,
            borderRadius: BorderRadius.circular(Dimens.radiusFull),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.calendar_today_rounded,
                size: 14,
                color: AppColors.accent,
              ),
              const SizedBox(width: Dimens.spacingXs),
              Text(
                date,
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Search button that opens the search delegate.
class _SearchButton extends StatelessWidget {
  const _SearchButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(Dimens.radiusLg),
        child: Container(
          height: Dimens.inputHeightLg + 8,
          padding: const EdgeInsets.symmetric(horizontal: Dimens.spacingLg),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                (isDark ? AppColors.cardDark : AppColors.cardLight),
                (isDark ? AppColors.cardDark : AppColors.cardLight)
                    .withValues(alpha: 0.8),
              ],
            ),
            borderRadius: BorderRadius.circular(Dimens.radiusLg),
            border: Border.all(
              color: AppColors.accent.withValues(alpha: 0.2),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.accent.withValues(alpha: 0.1),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(Dimens.spacingSm),
                decoration: BoxDecoration(
                  color: AppColors.accent.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(Dimens.radiusMd),
                ),
                child: const Icon(
                  Icons.search_rounded,
                  color: AppColors.accent,
                  size: 20,
                ),
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
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: Dimens.spacingSm,
                  vertical: Dimens.spacingXs,
                ),
                decoration: BoxDecoration(
                  color: AppColors.accent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(Dimens.radiusSm),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.keyboard_command_key,
                        size: 12, color: AppColors.accent),
                    SizedBox(width: 2),
                    Text(
                      'K',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: AppColors.accent,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Modules grid - 4 main modules.
class _ModulesGrid extends StatelessWidget {
  const _ModulesGrid();

  static const _modules = [
    (
      title: 'Electrical',
      icon: Icons.bolt_rounded,
      color: AppColors.electricalAccent,
      route: '/electrical',
    ),
    (
      title: 'Mechanical',
      icon: Icons.settings_rounded,
      color: AppColors.mechanicalAccent,
      route: '/mechanical',
    ),
    (
      title: 'Chemical',
      icon: Icons.science_rounded,
      color: AppColors.chemicalAccent,
      route: '/chemical',
    ),
    (
      title: 'Bioprocess',
      icon: Icons.biotech_rounded,
      color: AppColors.bioprocessAccent,
      route: '/bioprocess',
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
        childAspectRatio: 1.4,
      ),
      itemCount: _modules.length,
      itemBuilder: (context, index) {
        final module = _modules[index];
        return _ModuleCard(
          title: module.title,
          icon: module.icon,
          color: module.color,
          onTap: () => context.go(module.route),
        );
      },
    );
  }
}

/// Module card with better readability.
class _ModuleCard extends StatelessWidget {
  const _ModuleCard({
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
    final isDark = theme.brightness == Brightness.dark;

    return Card(
      elevation: Dimens.elevationMd,
      shadowColor: color.withValues(alpha: 0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Dimens.radiusLg),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(Dimens.radiusLg),
        child: Container(
          padding: const EdgeInsets.all(Dimens.spacingMd),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(Dimens.radiusLg),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                color.withValues(alpha: 0.2),
                color.withValues(alpha: 0.08),
              ],
            ),
            border: Border.all(
              color: color.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Icon container
              Container(
                padding: const EdgeInsets.all(Dimens.spacingSm + 2),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(Dimens.radiusMd),
                  boxShadow: [
                    BoxShadow(
                      color: color.withValues(alpha: 0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: Dimens.iconLg,
                ),
              ),

              // Title with high contrast
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimaryLight,
                  letterSpacing: -0.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Quick access horizontal list.
class _QuickAccessList extends StatelessWidget {
  const _QuickAccessList();

  static const _quickTools = [
    (
      title: 'Voltage Drop',
      subtitle: 'Cable sizing',
      icon: Icons.bolt_rounded,
      color: Color(0xFFFFC107),
      route: '/electrical/voltage-drop',
    ),
    (
      title: 'Signal Scaler',
      subtitle: '4-20mA conversion',
      icon: Icons.straighten_rounded,
      color: Color(0xFF00E5FF),
      route: '/electrical/signal-scaler',
    ),
    (
      title: 'Viscosity Lab',
      subtitle: 'Dynamic/Kinematic',
      icon: Icons.water_drop_rounded,
      color: Color(0xFFFF6D00),
      route: '/mechanical/viscosity',
    ),
    (
      title: 'Beer-Lambert',
      subtitle: 'Spectroscopy',
      icon: Icons.lightbulb_rounded,
      color: Color(0xFF7C4DFF),
      route: '/chemical/beer-lambert',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _quickTools.length,
        separatorBuilder: (context, index) =>
            const SizedBox(width: Dimens.spacingMd),
        itemBuilder: (context, index) {
          final tool = _quickTools[index];
          return _QuickAccessCard(
            title: tool.title,
            subtitle: tool.subtitle,
            icon: tool.icon,
            color: tool.color,
            onTap: () => context.push(tool.route),
          );
        },
      ),
    );
  }
}

/// Quick access card widget.
class _QuickAccessCard extends StatelessWidget {
  const _QuickAccessCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Card(
      elevation: Dimens.elevationSm,
      shadowColor: color.withValues(alpha: 0.2),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Dimens.radiusMd),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(Dimens.radiusMd),
        child: Container(
          width: 160,
          padding: const EdgeInsets.all(Dimens.spacingMd),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(Dimens.radiusMd),
            border: Border.all(
              color: color.withValues(alpha: 0.2),
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(Dimens.spacingSm),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(Dimens.radiusSm),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: Dimens.iconMd,
                ),
              ),
              const SizedBox(width: Dimens.spacingSm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isDark
                            ? AppColors.textPrimaryDark
                            : AppColors.textPrimaryLight,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      subtitle,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondaryLight,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
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
      'electrical' => Icons.bolt_rounded,
      'mechanical' => Icons.settings_rounded,
      'chemical' => Icons.science_rounded,
      'bioprocess' => Icons.biotech_rounded,
      _ => Icons.calculate_rounded,
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
        border: Border.all(
          color: _moduleColor.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          // Module icon
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: _moduleColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(Dimens.radiusMd),
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
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimaryLight,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
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
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: Dimens.spacingSm,
              vertical: Dimens.spacingXs,
            ),
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.backgroundDark
                  : AppColors.backgroundLight,
              borderRadius: BorderRadius.circular(Dimens.radiusSm),
            ),
            child: Text(
              _formatTime(timestamp),
              style: theme.textTheme.labelSmall?.copyWith(
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
