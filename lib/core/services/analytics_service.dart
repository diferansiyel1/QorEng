import 'dart:developer' as developer;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:engicore/core/services/auth_service.dart';

/// Analytics events for marketing and usage tracking.
enum AnalyticsEvent {
  calculationPerformed,
  featureUsed,
  promoClicked,
  pdfExported,
  historyViewed,
  searchPerformed,
}

/// Analytics service for tracking user behavior.
///
/// Logs events to Firestore for later analysis and targeted marketing.
class AnalyticsService {
  AnalyticsService({
    FirebaseFirestore? firestore,
    required this.authService,
  }) : _firestore = firestore;

  final FirebaseFirestore? _firestore;
  final AuthService authService;

  /// Log a calculation event.
  Future<void> logCalculation({
    required String calculatorType,
    required Map<String, dynamic> parameters,
    required String result,
    String? moduleType,
  }) async {
    await _logEvent(
      event: AnalyticsEvent.calculationPerformed,
      data: {
        'calculator': calculatorType,
        'parameters': parameters,
        'result': result,
        'module': moduleType ?? 'unknown',
      },
    );
  }

  /// Log feature usage.
  Future<void> logFeatureUsage({
    required String feature,
    Map<String, dynamic>? metadata,
  }) async {
    await _logEvent(
      event: AnalyticsEvent.featureUsed,
      data: {
        'feature': feature,
        ...?metadata,
      },
    );
  }

  /// Log promo click for marketing tracking.
  Future<void> logPromoClick({
    required String promoType,
    required String context,
    String? moduleType,
  }) async {
    await _logEvent(
      event: AnalyticsEvent.promoClicked,
      data: {
        'promo_type': promoType,
        'context': context,
        'module': moduleType ?? 'unknown',
      },
    );
  }

  /// Log PDF export.
  Future<void> logPdfExport({
    required String calculatorType,
  }) async {
    await _logEvent(
      event: AnalyticsEvent.pdfExported,
      data: {
        'calculator': calculatorType,
      },
    );
  }

  /// Log search query.
  Future<void> logSearch({
    required String query,
    required int resultCount,
  }) async {
    await _logEvent(
      event: AnalyticsEvent.searchPerformed,
      data: {
        'query': query,
        'result_count': resultCount,
      },
    );
  }

  Future<void> _logEvent({
    required AnalyticsEvent event,
    required Map<String, dynamic> data,
  }) async {
    final userId = authService.currentUser?.uid ?? 'anonymous';
    final isGuest = authService.currentUser?.isGuest ?? true;

    final eventData = {
      'event': event.name,
      'userId': userId,
      'isGuest': isGuest,
      'timestamp': FieldValue.serverTimestamp(),
      'data': data,
    };

    // Log locally for debugging
    developer.log(
      'Analytics: ${event.name}',
      name: 'analytics',
    );

    // Skip Firestore if not available
    if (_firestore == null) return;

    try {
      await _firestore.collection('analytics').add(eventData);
    } catch (e) {
      developer.log(
        'Failed to log analytics event',
        error: e,
        name: 'analytics',
      );
    }
  }
}

/// Provider for AnalyticsService.
final analyticsServiceProvider = Provider<AnalyticsService>((ref) {
  final authService = ref.watch(authServiceProvider);

  try {
    return AnalyticsService(
      firestore: FirebaseFirestore.instance,
      authService: authService,
    );
  } catch (e) {
    developer.log('Firestore not available for analytics');
    return AnalyticsService(
      authService: authService,
    );
  }
});
