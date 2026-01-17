import 'package:flutter/foundation.dart';
import 'dart:io';
import '../models/secret_model.dart';
import '../models/activity_log_model.dart';
import '../services/vault_service.dart';
import '../services/activity_log_service.dart';

class VaultProvider extends ChangeNotifier {
  final VaultService _vaultService = VaultService();
  final ActivityLogService _logService = ActivityLogService();
  List<Secret> _secrets = [];
  List<ActivityLog> _logs = [];
  bool _isLoading = true;
  bool _isInitialized = false;
  String _searchQuery = '';
  String? _error;
  String? _masterPassword;

  List<Secret> get secrets {
    if (_searchQuery.isEmpty) return _secrets;
    return _secrets.where((s) {
      final query = _searchQuery.toLowerCase();
      return s.name.toLowerCase().contains(query) ||
             s.network.toLowerCase().contains(query) ||
             s.typeLabel.toLowerCase().contains(query);
    }).toList();
  }

  bool get isLoading => _isLoading;
  bool get isInitialized => _isInitialized;
  String? get error => _error;
  int get secretCount => _secrets.length;
  bool get hasPassword => _masterPassword != null;
  List<ActivityLog> get logs => _logs;

  Future<void> init({String? masterPassword}) async {
    if (_isInitialized) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _masterPassword = masterPassword;
      await _vaultService.init(masterPassword: masterPassword);
      await _logService.init(masterPassword: masterPassword);

      _secrets = await _vaultService.loadSecrets();
      _logs = await _logService.loadLogs();

      _isInitialized = true;
      _error = null;

      if (masterPassword != null) {
        await _logAction('Vault Accessed', 'Security check passed', ActivityCategory.access);
      }
    } catch (e) {
      _error = 'Failed to initialize vault: \$e';
      _secrets = [];
      _isInitialized = false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> reinitialize(String masterPassword) async {
    _isInitialized = false;
    _masterPassword = masterPassword;
    await init(masterPassword: masterPassword);
  }

  void setSearchQuery(String query) {
    if (_searchQuery == query) return;
    _searchQuery = query;
    notifyListeners();
  }

  void clearSearch() {
    if (_searchQuery.isEmpty) return;
    _searchQuery = '';
    notifyListeners();
  }

  Future<bool> addSecret(Secret secret) async {
    try {
      _secrets.insert(0, secret);
      notifyListeners();
      await _vaultService.saveSecrets(_secrets);
      await _logAction('Secret Added', secret.name, ActivityCategory.system);
      return true;
    } catch (e) {
      _error = 'Failed to add secret: $e';
      _secrets.removeWhere((s) => s.id == secret.id);
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteSecret(String id) async {
    try {
      final index = _secrets.indexWhere((s) => s.id == id);
      if (index == -1) return false;

      final secret = _secrets[index];
      _secrets.removeAt(index);
      notifyListeners();

      await _vaultService.saveSecrets(_secrets);
      await _logAction('Secret Deleted', secret.name, ActivityCategory.system);
      return true;
    } catch (e) {
      _error = 'Failed to delete secret: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateSecret(Secret updatedSecret) async {
    try {
      final index = _secrets.indexWhere((s) => s.id == updatedSecret.id);
      if (index == -1) return false;

      _secrets[index] = updatedSecret;
      notifyListeners();

      await _vaultService.saveSecrets(_secrets);
      await _logAction('Secret Updated', updatedSecret.name, ActivityCategory.system);
      return true;
    } catch (e) {
      _error = 'Failed to update secret: $e';
      notifyListeners();
      return false;
    }
  }

  Future<File?> exportDecryptedData() async {
    try {
      final result = await _vaultService.exportDecryptedData();
      await _logAction('Vault Exported', 'Decrypted JSON export', ActivityCategory.security);
      return result;
    } catch (e) {
      _error = 'Failed to export data: $e';
      notifyListeners();
      return null;
    }
  }

  Future<void> clearVault() async {
    try {
      await _vaultService.clearVault();
      await _logService.clearLogs();
      _secrets.clear();
      _logs.clear();
      _searchQuery = '';
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to clear vault: $e';
      notifyListeners();
    }
  }

  Future<void> _logAction(String title, String description, ActivityCategory category) async {
    final entry = ActivityLog.create(
      title: title,
      description: description,
      category: category,
    );
    _logs.insert(0, entry);
    notifyListeners();
    await _logService.log(entry);
  }

  Future<void> clearLogs() async {
    await _logService.clearLogs();
    _logs.clear();
    notifyListeners();
  }

  Future<File?> getEncryptedVaultFile() async {
    return await _vaultService.getEncryptedVaultFile();
  }

  Future<void> importVault(File file) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _vaultService.importEncryptedVault(file);
      // We don't call init here because we might need to re-authenticate with the imported vault's password
      _isInitialized = false;
      _secrets.clear();
    } catch (e) {
      _error = 'Failed to import vault: $e';
      throw e;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Secret? getSecretById(String id) {
    try {
      return _secrets.firstWhere((s) => s.id == id);
    } catch (e) {
      return null;
    }
  }

  List<Secret> getSecretsByType(SecretType type) {
    return _secrets.where((s) => s.type == type).toList();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
