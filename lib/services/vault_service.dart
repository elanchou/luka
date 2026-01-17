import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../models/secret_model.dart';
import 'encryption_service.dart';

class VaultService {
  final EncryptionService _encryptionService = EncryptionService();
  static const String _fileName = 'vault.enc';
  bool _isInitialized = false;

  Future<void> init() async {
    if (_isInitialized) return;
    
    try {
      await _encryptionService.init();
      _isInitialized = true;
    } catch (e) {
      _isInitialized = false;
      throw Exception('Failed to initialize vault service: $e');
    }
  }

  Future<File> get _file async {
    final directory = await getApplicationDocumentsDirectory();
    return File('${directory.path}/$_fileName');
  }

  Future<void> saveSecrets(List<Secret> secrets) async {
    if (!_isInitialized) {
      throw Exception('VaultService not initialized');
    }

    try {
      final file = await _file;
      final jsonList = secrets.map((s) => s.toJson()).toList();
      final jsonString = json.encode({'secrets': jsonList});

      final encryptedString = _encryptionService.encryptData(jsonString);
      await file.writeAsString(encryptedString);
    } catch (e) {
      throw Exception('Failed to save secrets: $e');
    }
  }

  Future<List<Secret>> loadSecrets() async {
    if (!_isInitialized) {
      throw Exception('VaultService not initialized');
    }

    try {
      final file = await _file;
      if (!await file.exists()) {
        return [];
      }

      final encryptedString = await file.readAsString();
      if (encryptedString.isEmpty) return [];

      final decryptedString = _encryptionService.decryptData(encryptedString);
      final Map<String, dynamic> jsonMap = json.decode(decryptedString);

      if (jsonMap['secrets'] != null) {
        final List<dynamic> jsonList = jsonMap['secrets'];
        return jsonList.map((j) => Secret.fromJson(j)).toList();
      }
      return [];
    } catch (e) {
      // Log error but don't crash - return empty list for corrupted data
      print('Error loading secrets: $e');
      return [];
    }
  }

  // Create a temporary file with decrypted JSON data for export
  Future<File?> exportDecryptedData() async {
    if (!_isInitialized) {
      throw Exception('VaultService not initialized');
    }

    try {
      final secrets = await loadSecrets();
      if (secrets.isEmpty) return null;

      final jsonList = secrets.map((s) => s.toJson()).toList();
      // Pretty print for readability
      final jsonString = const JsonEncoder.withIndent('  ').convert({
        'secrets': jsonList,
        'exported_at': DateTime.now().toIso8601String(),
        'version': '1.0.0',
      });

      final directory = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final exportFile = File('${directory.path}/vault_export_$timestamp.json');
      await exportFile.writeAsString(jsonString);

      return exportFile;
    } catch (e) {
      print('Error exporting data: $e');
      return null;
    }
  }

  Future<void> clearVault() async {
    try {
      final file = await _file;
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      throw Exception('Failed to clear vault: $e');
    }
  }

  Future<bool> vaultExists() async {
    try {
      final file = await _file;
      return await file.exists();
    } catch (e) {
      return false;
    }
  }

  bool get isInitialized => _isInitialized;
}
