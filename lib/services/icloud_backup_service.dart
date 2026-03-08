import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:icloud_storage/icloud_storage.dart';
import 'package:path_provider/path_provider.dart';
import 'master_key_service.dart';
import 'preferences_service.dart';

enum ICloudBackupStatus {
  idle,
  backingUp,
  restoring,
  success,
  error,
  unavailable,
}

class ICloudBackupService extends ChangeNotifier {
  static final ICloudBackupService _instance = ICloudBackupService._internal();
  factory ICloudBackupService() => _instance;
  ICloudBackupService._internal();

  static const String _containerId = 'iCloud.me.elanchou.sault';
  static const String _vaultFileName = 'vault.enc';
  static const String _activityFileName = 'activity.enc';
  static const String _metaFileName = 'vault_meta.json';

  final MasterKeyService _masterKeyService = MasterKeyService();

  ICloudBackupStatus _status = ICloudBackupStatus.idle;
  DateTime? _lastBackupTime;
  String? _lastError;
  bool _isAvailable = false;
  Timer? _debounceTimer;
  bool _isBackingUp = false;

  ICloudBackupStatus get status => _status;
  DateTime? get lastBackupTime => _lastBackupTime;
  String? get lastError => _lastError;
  bool get isAvailable => _isAvailable;

  Future<bool> checkAvailability() async {
    try {
      await ICloudStorage.gather(containerId: _containerId);
      _isAvailable = true;
    } catch (e) {
      _isAvailable = false;
    }
    notifyListeners();
    return _isAvailable;
  }

  void loadLastBackupTime(PreferencesService prefs) {
    _lastBackupTime = prefs.getLastBackupTime();
  }

  Future<bool> backupToICloud({PreferencesService? prefs}) async {
    if (!_isAvailable || _isBackingUp) return false;

    _isBackingUp = true;
    _status = ICloudBackupStatus.backingUp;
    _lastError = null;
    notifyListeners();

    try {
      final documentsDir = await getApplicationDocumentsDirectory();

      // Upload vault.enc
      final vaultFile = File('${documentsDir.path}/$_vaultFileName');
      if (await vaultFile.exists()) {
        await ICloudStorage.upload(
          containerId: _containerId,
          filePath: vaultFile.path,
          destinationRelativePath: _vaultFileName,
        );
      }

      // Upload activity.enc
      final activityFile = File('${documentsDir.path}/$_activityFileName');
      if (await activityFile.exists()) {
        await ICloudStorage.upload(
          containerId: _containerId,
          filePath: activityFile.path,
          destinationRelativePath: _activityFileName,
        );
      }

      // Create and upload vault_meta.json
      await _uploadMetadata();

      _lastBackupTime = DateTime.now();
      _status = ICloudBackupStatus.success;

      if (prefs != null) {
        await prefs.setLastBackupTime(_lastBackupTime!);
      }

      notifyListeners();
      return true;
    } catch (e) {
      _lastError = e.toString();
      _status = ICloudBackupStatus.error;
      notifyListeners();
      return false;
    } finally {
      _isBackingUp = false;
    }
  }

  Future<void> _uploadMetadata() async {
    final metadata = await _masterKeyService.getKeyMetadata();
    if (metadata == null) return;

    metadata['version'] = 1;
    metadata['lastBackup'] = DateTime.now().toIso8601String();

    final tempDir = await getTemporaryDirectory();
    final metaFile = File('${tempDir.path}/$_metaFileName');
    await metaFile.writeAsString(json.encode(metadata));

    await ICloudStorage.upload(
      containerId: _containerId,
      filePath: metaFile.path,
      destinationRelativePath: _metaFileName,
    );

    await metaFile.delete();
  }

  void scheduleBackup({PreferencesService? prefs}) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(seconds: 5), () {
      backupToICloud(prefs: prefs);
    });
  }

  Future<bool> hasICloudBackup() async {
    try {
      final files = await ICloudStorage.gather(containerId: _containerId);
      return files.any((f) => f.relativePath == _vaultFileName);
    } catch (e) {
      return false;
    }
  }

  Future<bool> restoreFromICloud() async {
    _status = ICloudBackupStatus.restoring;
    _lastError = null;
    notifyListeners();

    try {
      final documentsDir = await getApplicationDocumentsDirectory();
      final tempDir = await getTemporaryDirectory();

      // Download vault_meta.json first (need salt/iterations)
      final metaTempPath = '${tempDir.path}/$_metaFileName';
      await ICloudStorage.download(
        containerId: _containerId,
        relativePath: _metaFileName,
        destinationFilePath: metaTempPath,
      );

      final metaFile = File(metaTempPath);
      final metaJson = json.decode(await metaFile.readAsString()) as Map<String, dynamic>;

      // Restore salt and iterations to Keychain
      await _masterKeyService.restoreKeyMetadata(
        metaJson['salt'] as String,
        metaJson['iterations'] as int,
        verifier: metaJson['verifier'] as String?,
      );

      // Download vault.enc
      await ICloudStorage.download(
        containerId: _containerId,
        relativePath: _vaultFileName,
        destinationFilePath: '${documentsDir.path}/$_vaultFileName',
      );

      // Download activity.enc (non-fatal if missing)
      try {
        await ICloudStorage.download(
          containerId: _containerId,
          relativePath: _activityFileName,
          destinationFilePath: '${documentsDir.path}/$_activityFileName',
        );
      } catch (_) {}

      // Clean up temp meta file
      if (await metaFile.exists()) {
        await metaFile.delete();
      }

      _status = ICloudBackupStatus.success;
      notifyListeners();
      return true;
    } catch (e) {
      _lastError = e.toString();
      _status = ICloudBackupStatus.error;
      notifyListeners();
      return false;
    }
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }
}
