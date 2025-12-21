import 'package:cloud_firestore/cloud_firestore.dart';

/// User model for QorEng app.
///
/// Stores user profile information and pro status.
class QorEngUser {
  const QorEngUser({
    required this.uid,
    required this.email,
    this.displayName,
    this.company,
    this.photoUrl,
    this.isProUser = false,
    this.createdAt,
    this.lastLoginAt,
  });

  /// Create from Firebase Auth + Firestore data.
  factory QorEngUser.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? {};
    return QorEngUser(
      uid: doc.id,
      email: data['email'] as String? ?? '',
      displayName: data['displayName'] as String?,
      company: data['company'] as String?,
      photoUrl: data['photoUrl'] as String?,
      isProUser: data['isProUser'] as bool? ?? false,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      lastLoginAt: (data['lastLoginAt'] as Timestamp?)?.toDate(),
    );
  }

  final String uid;
  final String email;
  final String? displayName;
  final String? company;
  final String? photoUrl;
  final bool isProUser;
  final DateTime? createdAt;
  final DateTime? lastLoginAt;

  /// Convert to Firestore document.
  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'displayName': displayName,
      'company': company,
      'photoUrl': photoUrl,
      'isProUser': isProUser,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : null,
      'lastLoginAt':
          lastLoginAt != null ? Timestamp.fromDate(lastLoginAt!) : null,
    };
  }

  /// Create a copy with updated fields.
  QorEngUser copyWith({
    String? uid,
    String? email,
    String? displayName,
    String? company,
    String? photoUrl,
    bool? isProUser,
    DateTime? createdAt,
    DateTime? lastLoginAt,
  }) {
    return QorEngUser(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      company: company ?? this.company,
      photoUrl: photoUrl ?? this.photoUrl,
      isProUser: isProUser ?? this.isProUser,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
    );
  }

  /// Guest user placeholder.
  static const QorEngUser guest = QorEngUser(
    uid: 'guest',
    email: '',
    displayName: 'Guest Engineer',
    isProUser: false,
  );

  /// Check if user is a guest.
  bool get isGuest => uid == 'guest';
}
