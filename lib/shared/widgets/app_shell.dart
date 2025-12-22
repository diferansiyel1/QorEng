import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:engicore/core/constants/app_colors.dart';
import 'package:engicore/core/constants/dimens.dart';
import 'package:engicore/core/localization/localization_service.dart';

/// App shell widget containing the BottomNavigationBar.
///
/// This shell persists across all main feature screens and provides
/// consistent navigation between Dashboard, 4 engineering modules, and history.
class AppShell extends ConsumerWidget {
  const AppShell({
    required this.navigationShell,
    super.key,
  });

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = ref.strings;

    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: navigationShell.currentIndex,
          onTap: (index) => _onTap(context, index),
          items: [
            // Home (Dashboard) - Index 0
            BottomNavigationBarItem(
              icon: const Icon(Icons.dashboard_outlined),
              activeIcon: const _ActiveNavIcon(
                icon: Icons.dashboard,
                color: AppColors.accent,
              ),
              label: strings.home,
            ),
            // Electrical - Index 1
            BottomNavigationBarItem(
              icon: const Icon(Icons.bolt_outlined),
              activeIcon: const _ActiveNavIcon(
                icon: Icons.bolt,
                color: AppColors.electricalAccent,
              ),
              label: strings.electrical,
            ),
            // Mechanical - Index 2
            BottomNavigationBarItem(
              icon: const Icon(Icons.settings_outlined),
              activeIcon: const _ActiveNavIcon(
                icon: Icons.settings,
                color: AppColors.mechanicalAccent,
              ),
              label: strings.mechanical,
            ),
            // Chemical - Index 3
            BottomNavigationBarItem(
              icon: const Icon(Icons.science_outlined),
              activeIcon: const _ActiveNavIcon(
                icon: Icons.science,
                color: AppColors.chemicalAccent,
              ),
              label: strings.chemical,
            ),
            // Bioprocess - Index 4
            BottomNavigationBarItem(
              icon: const Icon(Icons.biotech_outlined),
              activeIcon: const _ActiveNavIcon(
                icon: Icons.biotech,
                color: AppColors.bioprocessAccent,
              ),
              label: strings.bioprocess,
            ),
          ],
        ),
      ),
    );
  }

  void _onTap(BuildContext context, int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }
}

/// Custom active navigation icon with accent color background.
class _ActiveNavIcon extends StatelessWidget {
  const _ActiveNavIcon({
    required this.icon,
    required this.color,
  });

  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(Dimens.spacingXs),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(Dimens.radiusMd),
      ),
      child: Icon(
        icon,
        color: color,
      ),
    );
  }
}
