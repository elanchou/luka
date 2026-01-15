import 'package:flutter/foundation.dart';
import 'dart:io';
import '../models/secret_model.dart';
import '../services/vault_service.dart';

class VaultProvider extends ChangeNotifier {
  final VaultService _vaultService = VaultService();
  List<Secret> _secrets = [];
  bool _isLoading = true;
  String _searchQuery = '';

  List<Secret> get secrets {
    if (_searchQuery.isEmpty) return _secrets;
    return _secrets.where((s) {
      return s.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
             s.network.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }

  bool get isLoading => _isLoading;

  Future<void> init() async {
    _isLoading = true;
    notifyListeners();

    await _vaultService.init();
    _secrets = await _vaultService.loadSecrets();

    _isLoading = false;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  Future<void> addSecret(Secret secret) async {
    _secrets.insert(0, secret); // Add to top
    notifyListeners();
    await _vaultService.saveSecrets(_secrets);
  }

  Future<void> deleteSecret(String id) async {
    _secrets.removeWhere((s) => s.id == id);
    notifyListeners();
    await _vaultService.saveSecrets(_secrets);
  }

  Future<void> updateSecret(Secret updatedSecret) async {
    final index = _secrets.indexWhere((s) => s.id == updatedSecret.id);
    if (index != -1) {
      _secrets[index] = updatedSecret;
      notifyListeners();
      await _vaultService.saveSecrets(_secrets);
    }
  }

  Future<File?> exportDecryptedData() async {
    return await _vaultService.exportDecryptedData();
  }
}
