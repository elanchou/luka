import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'master_key_service.dart';

class EncryptionService {
  static const _storage = FlutterSecureStorage();
  static const _legacyKeyStorageKey = 'vault_master_key';
  static const _ivLength = 16;
  static const _keyLength = 32;

  final MasterKeyService _masterKeyService = MasterKeyService();
  encrypt.Key? _masterKey;
  bool _isInitialized = false;
  bool _usesPassword = false;

  // Initialize the service: Load key or generate if not exists
  Future<void> init({String? masterPassword}) async {
    if (_isInitialized) return;
    
    try {
      final hasPassword = await _masterKeyService.hasPassword();
      
      if (hasPassword) {
        // New password-based system
        if (masterPassword == null || masterPassword.isEmpty) {
          throw Exception('Master password required');
        }
        
        _masterKey = await _masterKeyService.deriveMasterKey(masterPassword);
        _usesPassword = true;
      } else {
        // Legacy system or new vault without password
        // Check for legacy key first
        String? base64Key = await _storage.read(key: _legacyKeyStorageKey);
        
        if (base64Key == null || base64Key.isEmpty) {
          // For new vaults, require password setup
          throw Exception('Master password not set. Please set up master password first.');
        } else {
          // Use legacy key
          final keyBytes = base64.decode(base64Key);
          if (keyBytes.length != _keyLength) {
            throw Exception('Invalid key length: expected $_keyLength bytes');
          }
          _masterKey = encrypt.Key(keyBytes);
          _usesPassword = false;
        }
      }
      
      _isInitialized = true;
    } catch (e) {
      _isInitialized = false;
      throw Exception('Failed to initialize encryption service: $e');
    }
  }

  // Migrate from legacy random key to password-based key
  Future<void> migrateToPasswordBased(
    String masterPassword,
    SecurityLevel securityLevel,
  ) async {
    if (_usesPassword) {
      throw Exception('Already using password-based encryption');
    }

    if (!_isInitialized || _masterKey == null) {
      throw Exception('EncryptionService not initialized');
    }

    try {
      // Set up password-based key derivation
      await _masterKeyService.setMasterPassword(masterPassword, securityLevel);
      
      // Derive new key from password
      final newKey = await _masterKeyService.deriveMasterKey(masterPassword);
      
      // Update internal state
      _masterKey = newKey;
      _usesPassword = true;
      
      // Remove legacy key
      await _storage.delete(key: _legacyKeyStorageKey);
    } catch (e) {
      throw Exception('Failed to migrate to password-based encryption: $e');
    }
  }

  // Re-encrypt all data with new password (for password changes)
  Future<void> updatePassword(
    String oldPassword,
    String newPassword,
    SecurityLevel securityLevel,
  ) async {
    if (!_usesPassword) {
      throw Exception('Not using password-based encryption');
    }

    try {
      // Verify old password and get old key
      final oldKey = await _masterKeyService.deriveMasterKey(oldPassword);
      
      // Change password
      await _masterKeyService.changeMasterPassword(
        oldPassword,
        newPassword,
        securityLevel,
      );
      
      // Get new key
      final newKey = await _masterKeyService.deriveMasterKey(newPassword);
      
      // Update internal state
      _masterKey = newKey;
    } catch (e) {
      throw Exception('Failed to update password: $e');
    }
  }

  // Encrypt plain text
  String encryptData(String plainText) {
    if (!_isInitialized || _masterKey == null) {
      throw Exception('EncryptionService not initialized');
    }

    if (plainText.isEmpty) {
      throw ArgumentError('Plain text cannot be empty');
    }

    try {
      final iv = encrypt.IV.fromSecureRandom(_ivLength);
      final encrypter = encrypt.Encrypter(
        encrypt.AES(_masterKey!, mode: encrypt.AESMode.cbc),
      );

      final encrypted = encrypter.encrypt(plainText, iv: iv);

      // Combine IV and Ciphertext for storage: IV + Ciphertext
      final combined = iv.bytes + encrypted.bytes;
      return base64.encode(combined);
    } catch (e) {
      throw Exception('Encryption failed: $e');
    }
  }

  // Decrypt cipher text
  String decryptData(String encryptedBase64) {
    if (!_isInitialized || _masterKey == null) {
      throw Exception('EncryptionService not initialized');
    }

    if (encryptedBase64.isEmpty) {
      throw ArgumentError('Encrypted data cannot be empty');
    }

    try {
      final combined = base64.decode(encryptedBase64);

      if (combined.length <= _ivLength) {
        throw Exception('Invalid encrypted data: too short');
      }

      // Extract IV (first 16 bytes)
      final ivBytes = combined.sublist(0, _ivLength);
      final iv = encrypt.IV(ivBytes);

      // Extract Ciphertext (remaining bytes)
      final cipherBytes = combined.sublist(_ivLength);
      final encrypted = encrypt.Encrypted(cipherBytes);

      final encrypter = encrypt.Encrypter(
        encrypt.AES(_masterKey!, mode: encrypt.AESMode.cbc),
      );
      return encrypter.decrypt(encrypted, iv: iv);
    } catch (e) {
      throw Exception('Decryption failed: $e');
    }
  }

  // Reset encryption service (useful for testing or re-initialization)
  Future<void> reset() async {
    try {
      await _storage.delete(key: _legacyKeyStorageKey);
      await _masterKeyService.reset();
      _masterKey = null;
      _isInitialized = false;
      _usesPassword = false;
    } catch (e) {
      throw Exception('Failed to reset encryption service: $e');
    }
  }

  bool get isInitialized => _isInitialized;
  bool get usesPassword => _usesPassword;
  
  Future<SecurityLevel> getSecurityLevel() async {
    if (_usesPassword) {
      return await _masterKeyService.getSecurityLevel();
    }
    return SecurityLevel.standard;
  }
}
