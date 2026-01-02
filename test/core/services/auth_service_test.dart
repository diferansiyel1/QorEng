import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:engicore/core/models/auth_result.dart';
import 'package:engicore/core/services/auth_service.dart';

// Note: Google Sign-In uses a singleton pattern which makes mocking
// more complex. These tests focus on Firebase Auth behavior and edge cases.
// Full Google Sign-In integration testing should be done with integration tests.

// Mock classes for testing
class MockFirebaseAuth implements FirebaseAuth {
  User? _currentUser;
  bool shouldThrowError = false;
  String? errorCode;

  @override
  User? get currentUser => _currentUser;

  void setCurrentUser(User? user) {
    _currentUser = user;
  }

  @override
  Future<UserCredential> signInWithCredential(AuthCredential credential) async {
    if (shouldThrowError) {
      throw FirebaseAuthException(code: errorCode ?? 'unknown');
    }
    return MockUserCredential();
  }

  @override
  Future<UserCredential> signInAnonymously() async {
    return MockUserCredential();
  }

  @override
  Stream<User?> authStateChanges() {
    return Stream.value(_currentUser);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class MockUserCredential implements UserCredential {
  @override
  User? get user => MockUser();

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class MockUser implements User {
  @override
  String get uid => 'test-uid';

  @override
  String? get email => 'test@example.com';

  @override
  String? get displayName => 'Test User';

  @override
  String? get photoURL => null;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  group('AuthService', () {
    group('signInWithGoogle', () {
      test('returns AuthFailure when Firebase is not configured', () async {
        final authService = AuthService();

        final result = await authService.signInWithGoogle();

        expect(result, isA<AuthFailure>());
        final failure = result as AuthFailure;
        expect(failure.reason, AuthFailureReason.firebaseNotConfigured);
        expect(failure.message, 'Firebase not configured');
      });
    });

    group('signInWithGoogleOrGuest', () {
      test('returns guest user when Firebase is not configured', () async {
        final authService = AuthService();

        final user = await authService.signInWithGoogleOrGuest();

        expect(user.isGuest, true);
      });
    });

    group('signInAnonymously', () {
      test('returns guest when Firebase is not configured', () async {
        final authService = AuthService();

        final user = await authService.signInAnonymously();

        expect(user?.isGuest, true);
      });

      test('returns user when Firebase is available', () async {
        final mockFirebaseAuth = MockFirebaseAuth();
        final authService = AuthService(auth: mockFirebaseAuth);

        final user = await authService.signInAnonymously();

        // Anonymous sign-in returns a guest engineer with empty email but valid uid
        expect(user, isNotNull);
        expect(user!.uid, 'test-uid');
        expect(user.displayName, 'Guest Engineer');
      });
    });

    group('isAuthenticated', () {
      test('returns false when Firebase is not configured', () {
        final authService = AuthService();

        expect(authService.isAuthenticated, false);
      });

      test('returns false when no user is signed in', () {
        final mockFirebaseAuth = MockFirebaseAuth();
        final authService = AuthService(auth: mockFirebaseAuth);

        expect(authService.isAuthenticated, false);
      });

      test('returns true when user is signed in', () {
        final mockFirebaseAuth = MockFirebaseAuth();
        mockFirebaseAuth.setCurrentUser(MockUser());
        final authService = AuthService(auth: mockFirebaseAuth);

        expect(authService.isAuthenticated, true);
      });
    });

    group('currentUser', () {
      test('returns guest when Firebase is not configured', () {
        final authService = AuthService();

        final user = authService.currentUser;

        expect(user?.isGuest, true);
      });

      test('returns guest when no user is signed in', () {
        final mockFirebaseAuth = MockFirebaseAuth();
        final authService = AuthService(auth: mockFirebaseAuth);

        final user = authService.currentUser;

        expect(user?.isGuest, true);
      });
    });

    group('requiresAuth', () {
      test('returns true for protected features when not authenticated', () {
        final authService = AuthService();

        expect(authService.requiresAuth(ProtectedFeature.saveHistory), true);
        expect(authService.requiresAuth(ProtectedFeature.exportPdf), true);
        expect(authService.requiresAuth(ProtectedFeature.cloudSync), true);
      });

      test('returns false for protected features when authenticated', () {
        final mockFirebaseAuth = MockFirebaseAuth();
        mockFirebaseAuth.setCurrentUser(MockUser());
        final authService = AuthService(auth: mockFirebaseAuth);

        expect(authService.requiresAuth(ProtectedFeature.saveHistory), false);
        expect(authService.requiresAuth(ProtectedFeature.exportPdf), false);
        expect(authService.requiresAuth(ProtectedFeature.cloudSync), false);
      });
    });
  });

  group('AuthResult', () {
    test('AuthFailure holds error data', () {
      const result = AuthFailure('test', AuthFailureReason.cancelled);

      expect(result.message, 'test');
      expect(result.reason, AuthFailureReason.cancelled);
    });

    test('AuthFailureReason enum has all expected values', () {
      expect(AuthFailureReason.values, contains(AuthFailureReason.cancelled));
      expect(
        AuthFailureReason.values,
        contains(AuthFailureReason.networkError),
      );
      expect(
        AuthFailureReason.values,
        contains(AuthFailureReason.invalidCredentials),
      );
      expect(
        AuthFailureReason.values,
        contains(AuthFailureReason.firebaseNotConfigured),
      );
      expect(AuthFailureReason.values, contains(AuthFailureReason.unknown));
    });
  });
}
