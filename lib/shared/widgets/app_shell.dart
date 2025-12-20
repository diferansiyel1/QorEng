import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:engicore/core/constants/app_colors.dart';
import 'package:engicore/core/constants/dimens.dart';

/// App shell widget containing the BottomNavigationBar.
///
/// This shell persists across all main feature screens and provides
/// consistent navigation between the 4 engineering modules.
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
          currentIndex: navigationShell.currentIndex,
          onTap: (index) => _onTap(context, index),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.bolt),
              activeIcon: _ActiveNavIcon(
                icon: Icons.bolt,
                color: AppColors.electricalAccent,
              ),
              label: 'Electrical',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings),
              activeIcon: _ActiveNavIcon(
                icon: Icons.settings,
                color: AppColors.mechanicalAccent,
              ),
              label: 'Mechanical',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.science),
              activeIcon: _ActiveNavIcon(
                icon: Icons.science,
                color: AppColors.chemicalAccent,
              ),
              label: 'Chemical',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.biotech),
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
