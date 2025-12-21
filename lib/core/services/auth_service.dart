import 'dart:developer' as developer;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:engicore/core/models/user_model.dart';

/// Features that require authentication.
enum ProtectedFeature {
  saveHistory,
  exportPdf,
  cloudSync,
}

/// Authentication service for QorEng.
///
/// Supports guest mode for calculations and auth for premium features.
class AuthService {
  AuthService({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
  })  : _auth = auth,
        _firestore = firestore;

  final FirebaseAuth? _auth;
  final FirebaseFirestore? _firestore;

  /// Current user stream.
  Stream<QorEngUser?> get userStream {
    if (_auth == null) {
      return Stream.value(QorEngUser.guest);
    }
    return _auth.authStateChanges().asyncMap((user) async {
      if (user == null) return null;
      return await _getUserFromFirestore(user.uid) ?? _createUserFromAuth(user);
    });
  }

  /// Get current user synchronously.
  QorEngUser? get currentUser {
    final user = _auth?.currentUser;
    if (user == null) return QorEngUser.guest;
    return _createUserFromAuth(user);
  }

  /// Check if user is authenticated (not guest).
  bool get isAuthenticated {
    return _auth?.currentUser != null;
  }

  /// Check if a feature requires authentication.
  bool requiresAuth(ProtectedFeature feature) {
    return !isAuthenticated &&
        (feature == ProtectedFeature.saveHistory ||
            feature == ProtectedFeature.exportPdf ||
            feature == ProtectedFeature.cloudSync);
  }

  /// Sign in with Google.
  Future<QorEngUser?> signInWithGoogle() async {
    if (_auth == null) {
      developer.log('Firebase not configured, skipping Google sign-in');
      return null;
    }

    try {
      final GoogleAuthProvider googleProvider = GoogleAuthProvider();
      googleProvider.addScope('email');
      googleProvider.addScope('profile');

      final UserCredential credential =
          await _auth.signInWithPopup(googleProvider);

      if (credential.user != null) {
        final user = _createUserFromAuth(credential.user!);
        await _saveUserToFirestore(user);
        developer.log('Google sign-in successful: ${user.email}');
        return user;
      }
    } catch (e, s) {
      developer.log(
        'Google sign-in failed',
        error: e,
        stackTrace: s,
      );
    }
    return null;
  }

  /// Sign in anonymously (guest mode with Firebase tracking).
  Future<QorEngUser?> signInAnonymously() async {
    if (_auth == null) {
      return QorEngUser.guest;
    }

    try {
      final credential = await _auth.signInAnonymously();
      if (credential.user != null) {
        return QorEngUser(
          uid: credential.user!.uid,
          email: '',
          displayName: 'Guest Engineer',
          isProUser: false,
        );
      }
    } catch (e, s) {
      developer.log(
        'Anonymous sign-in failed',
        error: e,
        stackTrace: s,
      );
    }
    return QorEngUser.guest;
  }

  /// Sign out.
  Future<void> signOut() async {
    try {
      await _auth?.signOut();
      developer.log('User signed out');
    } catch (e, s) {
      developer.log(
        'Sign out failed',
        error: e,
        stackTrace: s,
      );
    }
  }

  /// Update user profile.
  Future<void> updateProfile({
    String? displayName,
    String? company,
  }) async {
    final user = _auth?.currentUser;
    if (user == null) return;

    final updatedUser = QorEngUser(
      uid: user.uid,
      email: user.email ?? '',
      displayName: displayName ?? user.displayName,
      company: company,
      photoUrl: user.photoURL,
      lastLoginAt: DateTime.now(),
    );

    await _saveUserToFirestore(updatedUser);
  }

  /// Set pro user status (after LinkedIn follow).
  Future<void> setProUser(bool isPro) async {
    final user = _auth?.currentUser;
    if (user == null) return;

    try {
      await _firestore?.collection('users').doc(user.uid).update({
        'isProUser': isPro,
      });
      developer.log('Pro user status updated: $isPro');
    } catch (e) {
      developer.log('Failed to update pro status: $e');
    }
  }

  QorEngUser _createUserFromAuth(User user) {
    return QorEngUser(
      uid: user.uid,
      email: user.email ?? '',
      displayName: user.displayName,
      photoUrl: user.photoURL,
      lastLoginAt: DateTime.now(),
    );
  }

  Future<QorEngUser?> _getUserFromFirestore(String uid) async {
    if (_firestore == null) return null;

    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        return QorEngUser.fromFirestore(doc);
      }
    } catch (e) {
      developer.log('Failed to get user from Firestore: $e');
    }
    return null;
  }

  Future<void> _saveUserToFirestore(QorEngUser user) async {
    if (_firestore == null) return;

    try {
      await _firestore.collection('users').doc(user.uid).set(
            user.toFirestore(),
            SetOptions(merge: true),
          );
    } catch (e) {
      developer.log('Failed to save user to Firestore: $e');
    }
  }
}

/// Provider for AuthService.
final authServiceProvider = Provider<AuthService>((ref) {
  // Firebase may not be initialized - handle gracefully
  try {
    return AuthService(
      auth: FirebaseAuth.instance,
      firestore: FirebaseFirestore.instance,
    );
  } catch (e) {
    developer.log('Firebase not available, using guest-only mode');
    return AuthService();
  }
});

/// Provider for current user.
final currentUserProvider = StreamProvider<QorEngUser?>((ref) {
  final authService = ref.watch(authServiceProvider);
  return authService.userStream;
});

/// Provider for auth state.
final isAuthenticatedProvider = Provider<bool>((ref) {
  final authService = ref.watch(authServiceProvider);
  return authService.isAuthenticated;
});

/// Provider for pro user status.
/// Returns true if user is authenticated and has pro features.
final isProUserProvider = Provider<bool>((ref) {
  final userAsync = ref.watch(currentUserProvider);
  return userAsync.when(
    data: (user) {
      if (user == null || user.isGuest) return false;
      return user.isProUser;
    },
    loading: () => false,
    error: (_, __) => false,
  );
});

