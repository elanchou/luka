import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../models/secret_model.dart';
import 'encryption_service.dart';

class VaultService {
  final EncryptionService _encryptionService = EncryptionService();
  static const String _fileName = 'vault.enc';

  Future<void> init() async {
    await _encryptionService.init();
  }

  Future<File> get _file async {
    final directory = await getApplicationDocumentsDirectory();
    return File('${directory.path}/$_fileName');
  }

  Future<void> saveSecrets(List<Secret> secrets) async {
    final file = await _file;
    final jsonList = secrets.map((s) => s.toJson()).toList();
    final jsonString = json.encode({'secrets': jsonList});

    final encryptedString = _encryptionService.encryptData(jsonString);
    await file.writeAsString(encryptedString);
  }

  Future<List<Secret>> loadSecrets() async {
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
      print('Error loading secrets: $e');
      return [];
    }
  }

  // Create a temporary file with decrypted JSON data for export
  Future<File?> exportDecryptedData() async {
    try {
      final secrets = await loadSecrets();
      if (secrets.isEmpty) return null;

      final jsonList = secrets.map((s) => s.toJson()).toList();
      // Pretty print for readability
      final jsonString = const JsonEncoder.withIndent('  ').convert({'secrets': jsonList});

      final directory = await getTemporaryDirectory();
      final exportFile = File('${directory.path}/vault_export_decrypted.json');
      await exportFile.writeAsString(jsonString);

      return exportFile;
    } catch (e) {
      print('Error exporting data: $e');
      return null;
    }
  }

  Future<void> clearVault() async {
    final file = await _file;
    if (await file.exists()) {
      await file.delete();
    }
  }
}
