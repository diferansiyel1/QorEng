import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:engicore/features/bioprocess/presentation/screens/bioprocess_screen.dart';
import 'package:engicore/features/bioprocess/presentation/screens/tip_speed_screen.dart';
import 'package:engicore/features/chemical/presentation/screens/chemical_screen.dart';
import 'package:engicore/features/chemical/presentation/screens/arrhenius_screen.dart';
import 'package:engicore/features/chemical/presentation/screens/beer_lambert_screen.dart';
import 'package:engicore/features/chemical/presentation/screens/dilution_screen.dart';
import 'package:engicore/features/chemical/presentation/screens/molarity_screen.dart';
import 'package:engicore/features/chemical/presentation/screens/od_cell_density_screen.dart';
import 'package:engicore/features/chemical/presentation/screens/ph_sensor_screen.dart';
import 'package:engicore/features/chemical/presentation/screens/transmittance_screen.dart';
import 'package:engicore/features/electrical/presentation/screens/electrical_screen.dart';
import 'package:engicore/features/electrical/presentation/screens/ohms_law_screen.dart';
import 'package:engicore/features/electrical/presentation/screens/power_screen.dart';
import 'package:engicore/features/electrical/presentation/screens/signal_scaler_screen.dart';
import 'package:engicore/features/electrical/presentation/screens/vfd_speed_screen.dart';
import 'package:engicore/features/electrical/presentation/screens/voltage_drop_screen.dart';
import 'package:engicore/features/history/presentation/screens/history_screen.dart';
import 'package:engicore/features/home/presentation/screens/dashboard_screen.dart';
import 'package:engicore/features/mechanical/presentation/screens/flow_velocity_screen.dart';
import 'package:engicore/features/mechanical/presentation/screens/hydraulic_force_screen.dart';
import 'package:engicore/features/mechanical/presentation/screens/mechanical_screen.dart';
import 'package:engicore/features/mechanical/presentation/screens/pressure_drop_screen.dart';
import 'package:engicore/features/mechanical/presentation/screens/reynolds_screen.dart';
import 'package:engicore/features/mechanical/presentation/screens/viscosity_screen.dart';
import 'package:engicore/features/connect/presentation/screens/pikolab_connect_screen.dart';
import 'package:engicore/features/field_logger/presentation/screens/create_session_screen.dart';
import 'package:engicore/features/field_logger/presentation/screens/active_logging_screen.dart';
import 'package:engicore/features/field_logger/presentation/screens/session_summary_screen.dart';
import 'package:engicore/features/piping/presentation/screens/flange_screen.dart';
import 'package:engicore/features/piping/presentation/screens/fitting_screen.dart';
import 'package:engicore/shared/widgets/app_shell.dart';

/// Route paths for the application.
abstract final class AppRoutes {
  // Main tabs
  static const String home = '/';
  static const String electrical = '/electrical';
  static const String mechanical = '/mechanical';
  static const String chemical = '/chemical';
  static const String bioprocess = '/bioprocess';
  static const String history = '/history';

  // Electrical calculators - Power & Cables
  static const String ohmsLaw = '/electrical/ohms-law';
  static const String power = '/electrical/power';
  static const String voltageDrop = '/electrical/voltage-drop';

  // Electrical calculators - Automation & Control
  static const String signalScaler = '/electrical/signal-scaler';
  static const String vfdSpeed = '/electrical/vfd-speed';

  // Mechanical calculators
  static const String hydraulicForce = '/mechanical/hydraulic-force';
  static const String reynolds = '/mechanical/reynolds';
  static const String pressureDrop = '/mechanical/pressure-drop';
  static const String flowVelocity = '/mechanical/flow-velocity';
  static const String viscosity = '/mechanical/viscosity';

  // Chemical calculators - General
  static const String dilution = '/chemical/dilution';
  static const String molarity = '/chemical/molarity';

  // Chemical calculators - Spectroscopy
  static const String beerLambert = '/chemical/beer-lambert';
  static const String transmittance = '/chemical/transmittance';
  static const String odCellDensity = '/chemical/od-cell-density';

  // Chemical calculators - Electrochem
  static const String phSensor = '/chemical/ph-sensor';
  static const String arrhenius = '/chemical/arrhenius';

  // Bioprocess calculators
  static const String tipSpeed = '/bioprocess/tip-speed';

  // Pikolab Connect
  static const String connect = '/connect';

  // Field Logger
  static const String fieldLogger = '/field-logger';
  static const String fieldLoggerActive = '/field-logger/active';
  static const String fieldLoggerSummary = '/field-logger/summary';

  // Piping Master
  static const String piping = '/piping';
  static const String flangeSelector = '/piping/flange';
  static const String probeFitting = '/piping/fitting';
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
  initialLocation: AppRoutes.home,
  debugLogDiagnostics: true,
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return AppShell(navigationShell: navigationShell);
      },
      branches: [
        // Home (Dashboard) branch - Index 0
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.home,
              pageBuilder: (context, state) => const NoTransitionPage(
                child: DashboardScreen(),
              ),
            ),
          ],
        ),
        // Electrical branch - Index 1
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
                GoRoute(
                  path: 'voltage-drop',
                  builder: (context, state) => const VoltageDropScreen(),
                ),
                GoRoute(
                  path: 'signal-scaler',
                  builder: (context, state) => const SignalScalerScreen(),
                ),
                GoRoute(
                  path: 'vfd-speed',
                  builder: (context, state) => const VfdSpeedScreen(),
                ),
              ],
            ),
          ],
        ),
        // Mechanical branch - Index 2
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.mechanical,
              pageBuilder: (context, state) => const NoTransitionPage(
                child: MechanicalScreen(),
              ),
              routes: [
                GoRoute(
                  path: 'hydraulic-force',
                  builder: (context, state) => const HydraulicForceScreen(),
                ),
                GoRoute(
                  path: 'reynolds',
                  builder: (context, state) => const ReynoldsScreen(),
                ),
                GoRoute(
                  path: 'pressure-drop',
                  builder: (context, state) => const PressureDropScreen(),
                ),
                GoRoute(
                  path: 'flow-velocity',
                  builder: (context, state) => const FlowVelocityScreen(),
                ),
                GoRoute(
                  path: 'viscosity',
                  builder: (context, state) => const ViscosityScreen(),
                ),
              ],
            ),
          ],
        ),
        // Chemical branch - Index 3
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.chemical,
              pageBuilder: (context, state) => const NoTransitionPage(
                child: ChemicalScreen(),
              ),
              routes: [
                // General
                GoRoute(
                  path: 'dilution',
                  builder: (context, state) => const DilutionScreen(),
                ),
                GoRoute(
                  path: 'molarity',
                  builder: (context, state) => const MolarityScreen(),
                ),
                // Spectroscopy
                GoRoute(
                  path: 'beer-lambert',
                  builder: (context, state) => const BeerLambertScreen(),
                ),
                GoRoute(
                  path: 'transmittance',
                  builder: (context, state) => const TransmittanceScreen(),
                ),
                GoRoute(
                  path: 'od-cell-density',
                  builder: (context, state) => const OdCellDensityScreen(),
                ),
                // Electrochem
                GoRoute(
                  path: 'ph-sensor',
                  builder: (context, state) => const PhSensorScreen(),
                ),
                GoRoute(
                  path: 'arrhenius',
                  builder: (context, state) => const ArrheniusScreen(),
                ),
              ],
            ),
          ],
        ),
        // Bioprocess branch - Index 4
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.bioprocess,
              pageBuilder: (context, state) => const NoTransitionPage(
                child: BioprocessScreen(),
              ),
              routes: [
                GoRoute(
                  path: 'tip-speed',
                  builder: (context, state) => const TipSpeedScreen(),
                ),
              ],
            ),
          ],
        ),
      ],
    ),
    // History route (outside bottom nav, accessed via Dashboard "See All")
    GoRoute(
      path: AppRoutes.history,
      builder: (context, state) => const HistoryScreen(),
    ),
    // Pikolab Connect route
    GoRoute(
      path: AppRoutes.connect,
      builder: (context, state) => const PikolabConnectScreen(),
    ),
    // Field Logger routes
    GoRoute(
      path: AppRoutes.fieldLogger,
      builder: (context, state) => const CreateSessionScreen(),
    ),
    GoRoute(
      path: AppRoutes.fieldLoggerActive,
      builder: (context, state) => const ActiveLoggingScreen(),
    ),
    GoRoute(
      path: AppRoutes.fieldLoggerSummary,
      builder: (context, state) => const SessionSummaryScreen(),
    ),
    // Piping Master routes
    GoRoute(
      path: AppRoutes.flangeSelector,
      builder: (context, state) => const FlangeScreen(),
    ),
    GoRoute(
      path: AppRoutes.probeFitting,
      builder: (context, state) => const FittingScreen(),
    ),
  ],
);
