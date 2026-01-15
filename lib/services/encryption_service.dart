import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:math';

class EncryptionService {
  static const _storage = FlutterSecureStorage();
  static const _keyStorageKey = 'vault_master_key';

  encrypt.Key? _masterKey;

  // Initialize the service: Load key or generate if not exists
  Future<void> init() async {
    String? base64Key = await _storage.read(key: _keyStorageKey);

    if (base64Key == null) {
      // Generate new 32-byte (256-bit) key
      final key = encrypt.Key.fromSecureRandom(32);
      base64Key = base64.encode(key.bytes);
      await _storage.write(key: _keyStorageKey, value: base64Key);
      _masterKey = key;
    } else {
      _masterKey = encrypt.Key(base64.decode(base64Key));
    }
  }

  // Encrypt plain text
  String encryptData(String plainText) {
    if (_masterKey == null) throw Exception('EncryptionService not initialized');

    final iv = encrypt.IV.fromSecureRandom(16);
    final encrypter = encrypt.Encrypter(encrypt.AES(_masterKey!, mode: encrypt.AESMode.cbc));

    final encrypted = encrypter.encrypt(plainText, iv: iv);

    // Combine IV and Ciphertext for storage: IV + Ciphertext
    // We encode the IV and the Encrypted bytes together
    final combined = iv.bytes + encrypted.bytes;
    return base64.encode(combined);
  }

  // Decrypt cipher text
  String decryptData(String encryptedBase64) {
    if (_masterKey == null) throw Exception('EncryptionService not initialized');

    final combined = base64.decode(encryptedBase64);

    // Extract IV (first 16 bytes)
    final ivBytes = combined.sublist(0, 16);
    final iv = encrypt.IV(ivBytes);

    // Extract Ciphertext (remaining bytes)
    final cipherBytes = combined.sublist(16);
    final encrypted = encrypt.Encrypted(cipherBytes);

    final encrypter = encrypt.Encrypter(encrypt.AES(_masterKey!, mode: encrypt.AESMode.cbc));
    return encrypter.decrypt(encrypted, iv: iv);
  }
}
