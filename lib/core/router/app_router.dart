import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:engicore/features/bioprocess/presentation/screens/bioprocess_screen.dart';
import 'package:engicore/features/chemical/presentation/screens/chemical_screen.dart';
import 'package:engicore/features/electrical/presentation/screens/electrical_screen.dart';
import 'package:engicore/features/electrical/presentation/screens/ohms_law_screen.dart';
import 'package:engicore/features/electrical/presentation/screens/power_screen.dart';
import 'package:engicore/features/mechanical/presentation/screens/mechanical_screen.dart';
import 'package:engicore/shared/widgets/app_shell.dart';

/// Route paths for the application.
abstract final class AppRoutes {
  // Main tabs
  static const String electrical = '/electrical';
  static const String mechanical = '/mechanical';
  static const String chemical = '/chemical';
  static const String bioprocess = '/bioprocess';

  // Electrical calculators
  static const String ohmsLaw = '/electrical/ohms-law';
  static const String power = '/electrical/power';
}

/// Global navigation key for the router.
final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>(
  debugLabel: 'root',
);

/// GoRouter configuration with shell navigation.
///
/// Uses [StatefulShellRoute.indexedStack] to maintain state across
/// bottom navigation tabs while preserving the navigation stack
/// within each tab.
final GoRouter appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: AppRoutes.electrical,
  debugLogDiagnostics: true,
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return AppShell(navigationShell: navigationShell);
      },
      branches: [
        // Electrical branch
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.electrical,
              pageBuilder: (context, state) => const NoTransitionPage(
                child: ElectricalScreen(),
              ),
              routes: [
                GoRoute(
                  path: 'ohms-law',
                  builder: (context, state) => const OhmsLawScreen(),
                ),
                GoRoute(
                  path: 'power',
                  builder: (context, state) => const PowerScreen(),
                ),
              ],
            ),
          ],
        ),
        // Mechanical branch
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.mechanical,
              pageBuilder: (context, state) => const NoTransitionPage(
                child: MechanicalScreen(),
              ),
            ),
          ],
        ),
        // Chemical branch
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.chemical,
              pageBuilder: (context, state) => const NoTransitionPage(
                child: ChemicalScreen(),
              ),
            ),
          ],
        ),
        // Bioprocess branch
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.bioprocess,
              pageBuilder: (context, state) => const NoTransitionPage(
                child: BioprocessScreen(),
              ),
            ),
          ],
        ),
      ],
    ),
  ],
);
