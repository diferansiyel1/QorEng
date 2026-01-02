import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:math';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive_flutter/hive_flutter.dart';

/// Factory for creating AES-encrypted Hive boxes.
///
/// Uses flutter_secure_storage to securely store the encryption key.
class EncryptedBoxFactory {
  EncryptedBoxFactory._();

  static const String _encryptionKeyName = 'hive_encryption_key';
  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  );

  static List<int>? _encryptionKey;

  /// Initialize the factory by loading or generating the encryption key.
  ///
  /// Must be called before opening any encrypted boxes.
  static Future<void> initialize() async {
    try {
      final existingKey = await _secureStorage.read(key: _encryptionKeyName);

      if (existingKey != null) {
        _encryptionKey = base64Decode(existingKey);
        developer.log('Encryption key loaded from secure storage');
      } else {
        // Generate a new 32-byte key
        final random = Random.secure();
        _encryptionKey = List<int>.generate(32, (_) => random.nextInt(256));
        await _secureStorage.write(
          key: _encryptionKeyName,
          value: base64Encode(_encryptionKey!),
        );
        developer.log('New encryption key generated and stored');
      }
    } catch (e, s) {
      developer.log(
        'Failed to initialize encryption key, using fallback',
        error: e,
        stackTrace: s,
      );
      // Fallback: generate a session-only key (data won't persist across app restarts)
      final random = Random.secure();
      _encryptionKey = List<int>.generate(32, (_) => random.nextInt(256));
    }
  }

  /// Open an encrypted Hive box.
  ///
  /// The box will be encrypted using AES with a key stored in secure storage.
  /// Returns null if initialization hasn't been completed.
  static Future<Box<T>> openEncryptedBox<T>(String boxName) async {
    if (_encryptionKey == null) {
      await initialize();
    }

    final cipher = HiveAesCipher(_encryptionKey!);
    return Hive.openBox<T>(boxName, encryptionCipher: cipher);
  }

  /// Check if the factory has been initialized.
  static bool get isInitialized => _encryptionKey != null;
}
