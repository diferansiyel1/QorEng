/// Authentication result types for error handling.
///
/// Provides structured error responses that can be displayed to users.
import 'package:engicore/core/models/user_model.dart';

/// Reason for authentication failure.
enum AuthFailureReason {
  /// User cancelled the sign-in flow.
  cancelled,

  /// Network or connectivity error.
  networkError,

  /// Invalid credentials provided.
  invalidCredentials,

  /// Firebase not configured.
  firebaseNotConfigured,

  /// Unknown error occurred.
  unknown,
}

/// Result of an authentication operation.
sealed class AuthResult {
  const AuthResult();
}

/// Successful authentication.
class AuthSuccess extends AuthResult {
  const AuthSuccess(this.user);

  /// The authenticated user.
  final QorEngUser user;
}

/// Failed authentication.
class AuthFailure extends AuthResult {
  const AuthFailure(this.message, this.reason);

  /// Human-readable error message.
  final String message;

  /// Categorized failure reason.
  final AuthFailureReason reason;
}
