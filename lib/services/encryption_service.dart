import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:math';

class EncryptionService {
  static const _storage = FlutterSecureStorage();
  static const _keyStorageKey = 'vault_master_key';
  static const _ivLength = 16;
  static const _keyLength = 32;

  encrypt.Key? _masterKey;
  bool _isInitialized = false;

  // Initialize the service: Load key or generate if not exists
  Future<void> init() async {
    if (_isInitialized) return;
    
    try {
      String? base64Key = await _storage.read(key: _keyStorageKey);

      if (base64Key == null || base64Key.isEmpty) {
        // Generate new 32-byte (256-bit) key
        final key = encrypt.Key.fromSecureRandom(_keyLength);
        base64Key = base64.encode(key.bytes);
        await _storage.write(key: _keyStorageKey, value: base64Key);
        _masterKey = key;
      } else {
        final keyBytes = base64.decode(base64Key);
        if (keyBytes.length != _keyLength) {
          throw Exception('Invalid key length: expected $_keyLength bytes');
        }
        _masterKey = encrypt.Key(keyBytes);
      }
      _isInitialized = true;
    } catch (e) {
      _isInitialized = false;
      throw Exception('Failed to initialize encryption service: $e');
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
      // We encode the IV and the Encrypted bytes together
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
      await _storage.delete(key: _keyStorageKey);
      _masterKey = null;
      _isInitialized = false;
    } catch (e) {
      throw Exception('Failed to reset encryption service: $e');
    }
  }

  bool get isInitialized => _isInitialized;
}
