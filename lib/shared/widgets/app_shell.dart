import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:engicore/core/constants/app_colors.dart';
import 'package:engicore/core/constants/dimens.dart';

/// App shell widget containing the BottomNavigationBar.
///
/// This shell persists across all main feature screens and provides
/// consistent navigation between Dashboard, 4 engineering modules, and history.
class AppShell extends StatelessWidget {
  const AppShell({
    required this.navigationShell,
    super.key,
  });

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
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
          items: const [
            // Home (Dashboard) - Index 0
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_outlined),
              activeIcon: _ActiveNavIcon(
                icon: Icons.dashboard,
                color: AppColors.accent,
              ),
              label: 'Home',
            ),
            // Electrical - Index 1
            BottomNavigationBarItem(
              icon: Icon(Icons.bolt_outlined),
              activeIcon: _ActiveNavIcon(
                icon: Icons.bolt,
                color: AppColors.electricalAccent,
              ),
              label: 'Electrical',
            ),
            // Mechanical - Index 2
            BottomNavigationBarItem(
              icon: Icon(Icons.settings_outlined),
              activeIcon: _ActiveNavIcon(
                icon: Icons.settings,
                color: AppColors.mechanicalAccent,
              ),
              label: 'Mechanical',
            ),
            // Chemical - Index 3
            BottomNavigationBarItem(
              icon: Icon(Icons.science_outlined),
              activeIcon: _ActiveNavIcon(
                icon: Icons.science,
                color: AppColors.chemicalAccent,
              ),
              label: 'Chemical',
            ),
            // Bioprocess - Index 4
            BottomNavigationBarItem(
              icon: Icon(Icons.biotech_outlined),
              activeIcon: _ActiveNavIcon(
                icon: Icons.biotech,
                color: AppColors.bioprocessAccent,
              ),
              label: 'Bioprocess',
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
