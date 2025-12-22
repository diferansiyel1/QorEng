import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:engicore/core/constants/app_colors.dart';
import 'package:engicore/core/constants/dimens.dart';
import 'package:engicore/core/localization/localization_service.dart';
import 'package:engicore/core/router/app_router.dart';
import 'package:engicore/core/services/notification_service.dart';
import 'package:engicore/features/history/domain/repositories/history_repository.dart';
import 'package:engicore/features/home/presentation/widgets/tool_search_delegate.dart';

/// Dashboard (Cockpit) home screen.
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  String _getGreeting(AppStrings strings) {
    final hour = DateTime.now().hour;
    if (hour < 6) return strings.nightShift;
    if (hour < 12) return strings.goodMorning;
    if (hour < 17) return strings.goodAfternoon;
    if (hour < 22) return strings.goodEvening;
    return strings.nightShift;
  }

  String _getFormattedDate(AppLocale locale) {
    final now = DateTime.now();
    if (locale == AppLocale.tr) {
      const days = ['Paz', 'Pzt', 'Sal', 'Çar', 'Per', 'Cum', 'Cmt'];
      const months = [
        'Oca', 'Şub', 'Mar', 'Nis', 'May', 'Haz',
        'Tem', 'Ağu', 'Eyl', 'Eki', 'Kas', 'Ara',
      ];
      return '${now.day} ${months[now.month - 1]}, ${days[now.weekday % 7]}';
    } else {
      const days = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
      const months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
      ];
      return '${days[now.weekday % 7]}, ${months[now.month - 1]} ${now.day}';
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final recentRecords = ref.watch(historyRecordsProvider);
    final strings = ref.strings;
    final locale = ref.watch(localeProvider);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(Dimens.spacingLg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with logo
              _DashboardHeader(
                greeting: _getGreeting(strings),
                date: _getFormattedDate(locale),
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
                strings.modules,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: Dimens.spacingMd),
              const _ModulesGrid(),

              const SizedBox(height: Dimens.spacingMd),

              // Pikolab Connect Card
              _PikolabConnectCard(
                onTap: () => context.push(AppRoutes.connect),
              ),

              const SizedBox(height: Dimens.spacingXl),

              // Quick Access Section
              Text(
                strings.quickAccess,
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
                    strings.recentActivity,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () => context.push('/history'),
                    icon: const Icon(Icons.arrow_forward, size: 16),
                    label: Text(strings.viewAll),
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
class _EmptyRecentActivity extends ConsumerWidget {
  const _EmptyRecentActivity({
    required this.isDark,
    required this.theme,
  });

  final bool isDark;
  final ThemeData theme;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = ref.strings;

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
              strings.noRecentActivity,
              style: theme.textTheme.titleMedium?.copyWith(
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
              ),
            ),
            const SizedBox(height: Dimens.spacingXs),
            Text(
              strings.recentActivityHint,
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

/// Dashboard header with logo, greeting, date, and notification bell.
class _DashboardHeader extends ConsumerWidget {
  const _DashboardHeader({
    required this.greeting,
    required this.date,
  });

  final String greeting;
  final String date;

  void _showNotifications(BuildContext context, WidgetRef ref) {
    final notificationService = ref.read(notificationServiceProvider);
    final notifications = notificationService.getStoredNotifications();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _NotificationsSheet(notifications: notifications),
    ).then((_) {
      notificationService.markAllAsRead();
      ref.read(unreadNotificationCountProvider.notifier).reset();
    });
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final unreadCount = ref.watch(unreadNotificationCountProvider);
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 400;
    final strings = ref.strings;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Main header row
        Row(
          children: [
            // Logo - smaller on compact screens
            SizedBox(
              width: isSmallScreen ? 48 : 56,
              height: isSmallScreen ? 48 : 56,
              child: Image.asset(
                'assets/images/qoreng_logo.png',
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => Container(
                  decoration: BoxDecoration(
                    color: AppColors.accent.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(Dimens.radiusMd),
                  ),
                  child: Icon(
                    Icons.engineering,
                    color: AppColors.accent,
                    size: isSmallScreen ? 28 : 32,
                  ),
                ),
              ),
            ),
            const SizedBox(width: Dimens.spacingSm),

            // Greeting - flexible width with horizontal layout
            Expanded(
              child: Wrap(
                spacing: 4,
                children: [
                  Text(
                    greeting,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimaryLight,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    strings.engineer,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: AppColors.accent,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            // Notification Bell
            Stack(
              children: [
                IconButton(
                  onPressed: () => _showNotifications(context, ref),
                  icon: Icon(
                    Icons.notifications_outlined,
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight,
                    size: 24,
                  ),
                  tooltip: 'Notifications',
                  padding: const EdgeInsets.all(8),
                  constraints: const BoxConstraints(),
                ),
                if (unreadCount > 0)
                  Positioned(
                    right: 4,
                    top: 4,
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: const BoxDecoration(
                        color: AppColors.error,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 4),

            // Language Toggle
            IconButton(
              onPressed: () => ref.read(localeProvider.notifier).toggleLocale(),
              icon: Text(
                ref.watch(localeProvider).flag,
                style: const TextStyle(fontSize: 20),
              ),
              tooltip: ref.watch(localeProvider) == AppLocale.tr
                  ? 'Switch to English'
                  : 'Türkçe\'ye geç',
              padding: const EdgeInsets.all(8),
              constraints: const BoxConstraints(),
            ),
          ],
        ),

        // Date badge - below header on separate row
        const SizedBox(height: Dimens.spacingSm),
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
              Consumer(
                builder: (context, ref, _) => Text(
                  ref.strings.searchTools,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight,
                  ),
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
class _ModulesGrid extends ConsumerWidget {
  const _ModulesGrid();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = ref.strings;

    final modules = [
      (
        title: strings.electrical,
        icon: Icons.bolt_rounded,
        color: AppColors.electricalAccent,
        route: '/electrical',
      ),
      (
        title: strings.mechanical,
        icon: Icons.settings_rounded,
        color: AppColors.mechanicalAccent,
        route: '/mechanical',
      ),
      (
        title: strings.chemical,
        icon: Icons.science_rounded,
        color: AppColors.chemicalAccent,
        route: '/chemical',
      ),
      (
        title: strings.bioprocess,
        icon: Icons.biotech_rounded,
        color: AppColors.bioprocessAccent,
        route: '/bioprocess',
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: Dimens.spacingMd,
        crossAxisSpacing: Dimens.spacingMd,
        childAspectRatio: 0.85,
      ),
      itemCount: modules.length,
      itemBuilder: (context, index) {
        final module = modules[index];
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

/// Pikolab Connect promotional card on Dashboard.
class _PikolabConnectCard extends ConsumerWidget {
  const _PikolabConnectCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final strings = ref.strings;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(Dimens.radiusLg),
        child: Container(
          padding: const EdgeInsets.all(Dimens.spacingMd),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.accent.withValues(alpha: 0.15),
                AppColors.accent.withValues(alpha: 0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(Dimens.radiusLg),
            border: Border.all(
              color: AppColors.accent.withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(Dimens.spacingSm),
                decoration: BoxDecoration(
                  color: AppColors.accent.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(Dimens.radiusMd),
                ),
                child: const Icon(
                  Icons.handshake_rounded,
                  color: AppColors.accent,
                  size: Dimens.iconMd,
                ),
              ),
              const SizedBox(width: Dimens.spacingMd),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      strings.pikolabConnect,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isDark
                            ? AppColors.textPrimaryDark
                            : AppColors.textPrimaryLight,
                      ),
                    ),
                    Text(
                      strings.pikolabConnectDesc,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondaryLight,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: AppColors.accent.withValues(alpha: 0.7),
              ),
            ],
          ),
        ),
      ),
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
                padding: const EdgeInsets.all(Dimens.spacingSm),
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
class _QuickAccessList extends ConsumerWidget {
  const _QuickAccessList();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = ref.strings;
    
    final quickTools = [
      (
        title: strings.fieldLogger,
        subtitle: strings.fieldLoggerDesc,
        icon: Icons.edit_note_rounded,
        color: AppColors.bioprocessAccent,
        route: '/field-logger',
      ),
      (
        title: strings.voltageDrop,
        subtitle: strings.cableSizing,
        icon: Icons.bolt_rounded,
        color: const Color(0xFFFFC107),
        route: '/electrical/voltage-drop',
      ),
      (
        title: strings.signalScaler,
        subtitle: strings.conversionLabel,
        icon: Icons.straighten_rounded,
        color: const Color(0xFF00E5FF),
        route: '/electrical/signal-scaler',
      ),
      (
        title: strings.viscosityLab,
        subtitle: strings.dynamicKinematic,
        icon: Icons.water_drop_rounded,
        color: const Color(0xFFFF6D00),
        route: '/mechanical/viscosity',
      ),
      (
        title: strings.beerLambert,
        subtitle: strings.spectroscopy,
        icon: Icons.lightbulb_rounded,
        color: const Color(0xFF7C4DFF),
        route: '/chemical/beer-lambert',
      ),
    ];

    return SizedBox(
      height: 100,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: quickTools.length,
        separatorBuilder: (context, index) =>
            const SizedBox(width: Dimens.spacingMd),
        itemBuilder: (context, index) {
          final tool = quickTools[index];
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

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 150,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : AppColors.cardLight,
          borderRadius: BorderRadius.circular(Dimens.radiusMd),
          border: Border.all(
            color: color.withValues(alpha: 0.3),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(Dimens.radiusSm),
              ),
              child: Icon(
                icon,
                color: color,
                size: 18,
              ),
            ),
            const SizedBox(width: 10),
            Flexible(
              child: Text(
                title,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimaryLight,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
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

/// Bottom sheet showing recent announcements/notifications.
class _NotificationsSheet extends StatelessWidget {
  const _NotificationsSheet({required this.notifications});

  final List<Map<dynamic, dynamic>> notifications;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.7,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(Dimens.radiusXl),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Padding(
            padding: const EdgeInsets.symmetric(vertical: Dimens.spacingMd),
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: Dimens.spacingLg),
            child: Row(
              children: [
                const Icon(
                  Icons.notifications_active,
                  color: AppColors.accent,
                  size: 24,
                ),
                const SizedBox(width: Dimens.spacingSm),
                Text(
                  'Announcements',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Close'),
                ),
              ],
            ),
          ),
          const Divider(),

          // Notifications list
          Flexible(
            child: notifications.isEmpty
                ? Padding(
                    padding: const EdgeInsets.all(Dimens.spacingXl),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.notifications_off_outlined,
                          size: 64,
                          color: isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondaryLight,
                        ),
                        const SizedBox(height: Dimens.spacingMd),
                        Text(
                          'No announcements yet',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: isDark
                                ? AppColors.textSecondaryDark
                                : AppColors.textSecondaryLight,
                          ),
                        ),
                        const SizedBox(height: Dimens.spacingSm),
                        Text(
                          'Product updates and technical tips will appear here.',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: isDark
                                ? AppColors.textSecondaryDark
                                : AppColors.textSecondaryLight,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    shrinkWrap: true,
                    padding: const EdgeInsets.all(Dimens.spacingMd),
                    itemCount: notifications.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: Dimens.spacingSm),
                    itemBuilder: (context, index) {
                      final notification = notifications[index];
                      final isRead = notification['read'] == true;

                      return Container(
                        padding: const EdgeInsets.all(Dimens.spacingMd),
                        decoration: BoxDecoration(
                          color: isRead
                              ? (isDark
                                  ? AppColors.cardDark
                                  : AppColors.cardLight)
                              : AppColors.accent.withValues(alpha: 0.1),
                          borderRadius:
                              BorderRadius.circular(Dimens.radiusMd),
                          border: isRead
                              ? null
                              : Border.all(
                                  color: AppColors.accent,
                                  width: 1,
                                ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                if (!isRead)
                                  Container(
                                    width: 8,
                                    height: 8,
                                    margin: const EdgeInsets.only(
                                        right: Dimens.spacingSm),
                                    decoration: const BoxDecoration(
                                      color: AppColors.accent,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                Expanded(
                                  child: Text(
                                    notification['title'] as String? ??
                                        'Announcement',
                                    style:
                                        theme.textTheme.titleSmall?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            if (notification['body'] != null) ...[
                              const SizedBox(height: Dimens.spacingXs),
                              Text(
                                notification['body'] as String,
                                style: theme.textTheme.bodyMedium,
                              ),
                            ],
                            const SizedBox(height: Dimens.spacingXs),
                            Text(
                              _formatTimestamp(
                                  notification['timestamp'] as String?),
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: isDark
                                    ? AppColors.textSecondaryDark
                                    : AppColors.textSecondaryLight,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  String _formatTimestamp(String? timestamp) {
    if (timestamp == null) return '';
    try {
      final date = DateTime.parse(timestamp);
      final now = DateTime.now();
      final diff = now.difference(date);

      if (diff.inMinutes < 60) {
        return '${diff.inMinutes}m ago';
      } else if (diff.inHours < 24) {
        return '${diff.inHours}h ago';
      } else {
        return '${diff.inDays}d ago';
      }
    } catch (_) {
      return '';
    }
  }
}
