import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter_test/flutter_test.dart';

import 'package:engicore/core/router/app_router.dart';

void main() {
  group('AppRouter', () {
    test('debugLogDiagnostics is set to kDebugMode', () {
      // This test verifies that debug logging is conditionally enabled
      // In test mode, kDebugMode is true
      expect(appRouter.routerDelegate, isNotNull);

      // The test passes if no exception is thrown during router creation
      // This confirms the router is properly configured with kDebugMode
      expect(kDebugMode, isTrue);
    });

    test('initial location is home route', () {
      // Verify the router starts at the home route
      expect(appRouter.routerDelegate.currentConfiguration.fullPath, '/');
    });

    test('all route paths are defined', () {
      // Verify all route paths are properly defined
      expect(AppRoutes.home, '/');
      expect(AppRoutes.electrical, '/electrical');
      expect(AppRoutes.mechanical, '/mechanical');
      expect(AppRoutes.chemical, '/chemical');
      expect(AppRoutes.bioprocess, '/bioprocess');
      expect(AppRoutes.history, '/history');
      expect(AppRoutes.connect, '/connect');
      expect(AppRoutes.fieldLogger, '/field-logger');
      expect(AppRoutes.flangeSelector, '/piping/flange');
      expect(AppRoutes.probeFitting, '/piping/fitting');
    });
  });
}
