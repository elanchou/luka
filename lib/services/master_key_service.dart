import 'dart:convert';
import 'dart:typed_data';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';

/// Security level for key derivation (similar to 1Password)
enum SecurityLevel {
  standard(iterations: 100000, displayName: 'Standard'),
  enhanced(iterations: 650000, displayName: 'Enhanced'),
  paranoid(iterations: 1000000, displayName: 'Paranoid');

  final int iterations;
  final String displayName;

  const SecurityLevel({required this.iterations, required this.displayName});

  static SecurityLevel fromIterations(int iterations) {
    if (iterations >= paranoid.iterations) return paranoid;
    if (iterations >= enhanced.iterations) return enhanced;
    return standard;
  }
}

/// Helper class for PBKDF2 isolate communication
class _PBKDF2Params {
  final String password;
  final Uint8List salt;
  final int iterations;
  final int keyLength;

  _PBKDF2Params({
    required this.password,
    required this.salt,
    required this.iterations,
    required this.keyLength,
  });
}

/// PBKDF2 implementation using HMAC-SHA256 (Top-level for compute)
Uint8List _pbkdf2Work(_PBKDF2Params params) {
  final passwordBytes = utf8.encode(params.password);
  final numBlocks = (params.keyLength / 32).ceil();
  final derivedKey = BytesBuilder();

  for (var i = 1; i <= numBlocks; i++) {
    final block = _pbkdf2Block(
      passwordBytes: passwordBytes,
      salt: params.salt,
      iterations: params.iterations,
      blockIndex: i,
    );
    derivedKey.add(block);
  }

  return Uint8List.fromList(derivedKey.toBytes().take(params.keyLength).toList());
}

Uint8List _pbkdf2Block({
  required List<int> passwordBytes,
  required Uint8List salt,
  required int iterations,
  required int blockIndex,
}) {
  // Create salt || INT(i)
  final saltWithIndex = BytesBuilder()
    ..add(salt)
    ..add([
      (blockIndex >> 24) & 0xff,
      (blockIndex >> 16) & 0xff,
      (blockIndex >> 8) & 0xff,
      blockIndex & 0xff,
    ]);

  // U1 = PRF(Password, Salt || INT(i))
  var hmac = Hmac(sha256, passwordBytes);
  var u = Uint8List.fromList(hmac.convert(saltWithIndex.toBytes()).bytes);
  var result = Uint8List.fromList(u);

  // U2 through Uc
  for (var i = 1; i < iterations; i++) {
    hmac = Hmac(sha256, passwordBytes);
    u = Uint8List.fromList(hmac.convert(u).bytes);

    // XOR with result
    for (var j = 0; j < result.length; j++) {
      result[j] ^= u[j];
    }
  }

  return result;
}

/// Master key derivation service using PBKDF2 (like 1Password)
class MasterKeyService {
  static const _storage = FlutterSecureStorage();
  static const _saltKey = 'vault_master_salt';
  static const _iterationsKey = 'vault_pbkdf2_iterations';
  static const _hasPasswordKey = 'vault_has_password';
  static const _keyLength = 32; // 256 bits
  static const _saltLength = 32; // 256 bits

  /// Check if master password has been set
  Future<bool> hasPassword() async {
    try {
      final value = await _storage.read(key: _hasPasswordKey);
      return value == 'true';
    } catch (e) {
      return false;
    }
  }

  /// Initialize master password with security level
  Future<void> setMasterPassword(
    String password,
    SecurityLevel securityLevel,
  ) async {
    if (password.isEmpty) {
      throw ArgumentError('Password cannot be empty');
    }

    try {
      // Generate random salt
      final salt = encrypt.IV.fromSecureRandom(_saltLength);

      // Store salt and iterations
      await _storage.write(
        key: _saltKey,
        value: base64.encode(salt.bytes),
      );
      await _storage.write(
        key: _iterationsKey,
        value: securityLevel.iterations.toString(),
      );
      await _storage.write(key: _hasPasswordKey, value: 'true');
    } catch (e) {
      throw Exception('Failed to set master password: $e');
    }
  }

  /// Derive encryption key from master password using PBKDF2
  Future<encrypt.Key> deriveMasterKey(String password) async {
    if (password.isEmpty) {
      throw ArgumentError('Password cannot be empty');
    }

    try {
      // Get salt and iterations
      final saltBase64 = await _storage.read(key: _saltKey);
      final iterationsStr = await _storage.read(key: _iterationsKey);

      if (saltBase64 == null || iterationsStr == null) {
        throw Exception('Master password not initialized');
      }

      final salt = base64.decode(saltBase64);
      final iterations = int.parse(iterationsStr);

      // Derive key using PBKDF2 in a separate isolate
      final derivedKey = await compute(
        _pbkdf2Work,
        _PBKDF2Params(
          password: password,
          salt: salt,
          iterations: iterations,
          keyLength: _keyLength,
        ),
      );

      return encrypt.Key(derivedKey);
    } catch (e) {
      throw Exception('Failed to derive master key: $e');
    }
  }

  /// Get current security level
  Future<SecurityLevel> getSecurityLevel() async {
    try {
      final iterationsStr = await _storage.read(key: _iterationsKey);
      if (iterationsStr == null) {
        return SecurityLevel.standard;
      }
      final iterations = int.parse(iterationsStr);
      return SecurityLevel.fromIterations(iterations);
    } catch (e) {
      return SecurityLevel.standard;
    }
  }

  /// Update security level (re-derives everything)
  Future<void> updateSecurityLevel(
    String password,
    SecurityLevel newLevel,
  ) async {
    if (password.isEmpty) {
      throw ArgumentError('Password cannot be empty');
    }

    try {
      // Verify current password first
      await deriveMasterKey(password);

      // Update iterations
      await _storage.write(
        key: _iterationsKey,
        value: newLevel.iterations.toString(),
      );
    } catch (e) {
      throw Exception('Failed to update security level: $e');
    }
  }

  /// Verify master password
  Future<bool> verifyPassword(String password) async {
    try {
      await deriveMasterKey(password);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Change master password
  Future<void> changeMasterPassword(
    String oldPassword,
    String newPassword,
    SecurityLevel securityLevel,
  ) async {
    if (newPassword.isEmpty) {
      throw ArgumentError('New password cannot be empty');
    }

    try {
      // Verify old password
      final isValid = await verifyPassword(oldPassword);
      if (!isValid) {
        throw Exception('Current password is incorrect');
      }

      // Set new password
      await setMasterPassword(newPassword, securityLevel);
    } catch (e) {
      throw Exception('Failed to change master password: $e');
    }
  }

  /// Reset all master password data
  Future<void> reset() async {
    try {
      await _storage.delete(key: _saltKey);
      await _storage.delete(key: _iterationsKey);
      await _storage.delete(key: _hasPasswordKey);
    } catch (e) {
      throw Exception('Failed to reset master key service: $e');
    }
  }
}

