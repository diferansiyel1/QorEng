import 'dart:developer' as developer;

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:engicore/core/localization/localization_service.dart';
import 'package:engicore/core/router/app_router.dart';
import 'package:engicore/core/services/encrypted_box_factory.dart';
import 'package:engicore/core/services/notification_service.dart';
import 'package:engicore/core/theme/app_theme.dart';
import 'package:engicore/core/theme/theme_provider.dart';
import 'package:engicore/features/history/domain/repositories/history_repository.dart';
import 'package:engicore/features/field_logger/domain/repositories/field_logger_repository.dart';

/// EngiCore - Mission-critical engineering calculations super-app.
///
/// An offline-first mobile application designed for field engineers
/// (Maintenance, Process, Chemical, Bioprocess) working in factories.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive for local persistence
  await Hive.initFlutter();

  // Initialize encryption key for secure storage
  await EncryptedBoxFactory.initialize();

  // Initialize localization service
  await LocalizationService.initialize();

  // Open encrypted Hive boxes for secure data storage
  final historyBox = await EncryptedBoxFactory.openEncryptedBox<String>(
    HistoryRepository.boxName,
  );
  final fieldLoggerBox = await EncryptedBoxFactory.openEncryptedBox<String>(
    FieldLoggerRepository.boxName,
  );

  // Initialize Firebase (optional - app works without it)
  try {
    await Firebase.initializeApp();
    developer.log('Firebase initialized');

    // Initialize notifications after Firebase
    final notificationService = NotificationService();
    await notificationService.initialize();
    await InterestTracker.initialize();
  } catch (e) {
    developer.log('Firebase not configured, running in offline mode: $e');
  }

  runApp(
    ProviderScope(
      overrides: [
        // Override the historyBox provider with the actual encrypted box
        historyBoxProvider.overrideWithValue(historyBox),
        // Override the fieldLoggerBox provider with the actual encrypted box
        fieldLoggerBoxProvider.overrideWithValue(fieldLoggerBox),
      ],
      child: const QorEngApp(),
    ),
  );
}

/// Root application widget.
///
/// Configures Material 3 theming with user-selectable theme mode
/// (Dark, Light, or System/Auto).
class QorEngApp extends ConsumerWidget {
  const QorEngApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the theme mode from provider
    final themeModeAsync = ref.watch(themeModeProvider);
    final themeMode = themeModeAsync.value ?? ThemeMode.dark;

    return MaterialApp.router(
      title: 'QorEng',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      // Turkish is the default locale
      locale: const Locale('tr', 'TR'),
      supportedLocales: const [
        Locale('tr', 'TR'),
        Locale('en', 'US'),
      ],
      // Add localization delegates for Material and Cupertino widgets
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      routerConfig: appRouter,
    );
  }
}
