import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:engicore/core/router/app_router.dart';
import 'package:engicore/core/theme/app_theme.dart';
import 'package:engicore/features/history/domain/repositories/history_repository.dart';

/// EngiCore - Mission-critical engineering calculations super-app.
///
/// An offline-first mobile application designed for field engineers
/// (Maintenance, Process, Chemical, Bioprocess) working in factories.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive for local persistence
  await Hive.initFlutter();

  // Open the history box for calculation records
  final historyBox = await Hive.openBox<String>(HistoryRepository.boxName);

  runApp(
    ProviderScope(
      overrides: [
        // Override the historyBox provider with the actual box
        historyBoxProvider.overrideWithValue(historyBox),
      ],
      child: const QorEngApp(),
    ),
  );
}

/// Root application widget.
///
/// Configures Material 3 theming with dark mode as default
/// (optimized for OLED screens in low-light factory environments).
class QorEngApp extends StatelessWidget {
  const QorEngApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'QorEng',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.dark,
      routerConfig: appRouter,
    );
  }
}
