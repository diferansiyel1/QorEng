import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:engicore/core/router/app_router.dart';
import 'package:engicore/core/theme/app_theme.dart';

/// EngiCore - Mission-critical engineering calculations super-app.
///
/// An offline-first mobile application designed for field engineers
/// (Maintenance, Process, Chemical, Bioprocess) working in factories.
void main() {
  runApp(const ProviderScope(child: EngiCoreApp()));
}

/// Root application widget.
///
/// Configures Material 3 theming with dark mode as default
/// (optimized for OLED screens in low-light factory environments).
class EngiCoreApp extends StatelessWidget {
  const EngiCoreApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'EngiCore',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.dark,
      routerConfig: appRouter,
    );
  }
}
