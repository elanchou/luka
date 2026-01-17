import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../models/activity_log_model.dart';
import 'encryption_service.dart';

class ActivityLogService {
  final EncryptionService _encryptionService = EncryptionService();
  static const String _fileName = 'activity.enc';
  bool _isInitialized = false;

  Future<void> init({String? masterPassword}) async {
    if (_isInitialized) return;
    await _encryptionService.init(masterPassword: masterPassword);
    _isInitialized = true;
  }

  Future<File> get _file async {
    final directory = await getApplicationDocumentsDirectory();
    return File('${directory.path}/$_fileName');
  }

  Future<void> log(ActivityLog entry) async {
    final logs = await loadLogs();
    logs.insert(0, entry);
    // Keep only last 100 logs
    if (logs.length > 100) {
      logs.removeRange(100, logs.length);
    }
    await saveLogs(logs);
  }

  Future<void> saveLogs(List<ActivityLog> logs) async {
    final file = await _file;
    final jsonList = logs.map((l) => l.toJson()).toList();
    final jsonString = json.encode({'logs': jsonList});
    final encryptedString = _encryptionService.encryptData(jsonString);
    await file.writeAsString(encryptedString);
  }

  Future<List<ActivityLog>> loadLogs() async {
    try {
      final file = await _file;
      if (!await file.exists()) return [];

      final encryptedString = await file.readAsString();
      if (encryptedString.isEmpty) return [];

      final decryptedString = _encryptionService.decryptData(encryptedString);
      final Map<String, dynamic> jsonMap = json.decode(decryptedString);
      final List<dynamic> jsonList = jsonMap['logs'] ?? [];
      return jsonList.map((j) => ActivityLog.fromJson(j)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> clearLogs() async {
    final file = await _file;
    if (await file.exists()) {
      await file.delete();
    }
  }
}
