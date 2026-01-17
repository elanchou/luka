import 'package:flutter/foundation.dart';
import 'dart:io';
import '../models/secret_model.dart';
import '../services/vault_service.dart';

class VaultProvider extends ChangeNotifier {
  final VaultService _vaultService = VaultService();
  List<Secret> _secrets = [];
  bool _isLoading = true;
  bool _isInitialized = false;
  String _searchQuery = '';
  String? _error;

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

  Future<void> init() async {
    if (_isInitialized) return;
    
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _vaultService.init();
      _secrets = await _vaultService.loadSecrets();
      _isInitialized = true;
      _error = null;
    } catch (e) {
      _error = 'Failed to initialize vault: $e';
      _secrets = [];
      _isInitialized = false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
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
      _secrets.insert(0, secret); // Add to top
      notifyListeners();
      await _vaultService.saveSecrets(_secrets);
      return true;
    } catch (e) {
      _error = 'Failed to add secret: $e';
      // Rollback on failure
      _secrets.removeWhere((s) => s.id == secret.id);
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteSecret(String id) async {
    try {
      final index = _secrets.indexWhere((s) => s.id == id);
      if (index == -1) return false;
      
      final removedSecret = _secrets[index];
      _secrets.removeAt(index);
      notifyListeners();
      
      await _vaultService.saveSecrets(_secrets);
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

      final oldSecret = _secrets[index];
      _secrets[index] = updatedSecret;
      notifyListeners();
      
      await _vaultService.saveSecrets(_secrets);
      return true;
    } catch (e) {
      _error = 'Failed to update secret: $e';
      notifyListeners();
      return false;
    }
  }

  Future<File?> exportDecryptedData() async {
    try {
      return await _vaultService.exportDecryptedData();
    } catch (e) {
      _error = 'Failed to export data: $e';
      notifyListeners();
      return null;
    }
  }

  Future<void> clearVault() async {
    try {
      await _vaultService.clearVault();
      _secrets.clear();
      _searchQuery = '';
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to clear vault: $e';
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
