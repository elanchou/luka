import 'package:flutter/material.dart';

class AppColors {
  static const primaryColor = Color(0xFF13b6ec);
  static const backgroundDark = Color(0xFF101d22);
  static const surfaceDark = Color(0xFF16262c);
  static const surfaceHighlight = Color(0xFF1f363d);
  static const labelColor = Color(0xFF5f747a);
  static const inputBorderColor = Color(0xFF283539);
  static const successColor = Color(0xFF00d68f);
  static const dangerColor = Color(0xFFff3b30);
  static const warningColor = Color(0xFFffaa00);
}

class AppConstants {
  static const String appName = 'Vault';
  static const String appVersion = '1.0.0';
  
  // Seed phrase valid word counts
  static const List<int> validSeedPhraseCounts = [12, 15, 18, 21, 24];
  
  // Export file settings
  static const String exportFilePrefix = 'vault_export_';
  static const String exportFileExtension = '.json';
  
  // Encryption settings
  static const int encryptionKeyLength = 32; // 256 bits
  static const int encryptionIVLength = 16; // 128 bits
  
  // Input limits
  static const int maxSecretNameLength = 50;
  static const int maxNetworkNameLength = 30;
  static const int maxContentLength = 10000;
  static const int minSecretNameLength = 2;
  
  // Private key settings
  static const int privateKeyHexLength = 64; // 32 bytes in hex
}

class AppStrings {
  static const String errorInitializingVault = 'Failed to initialize vault';
  static const String errorLoadingSecrets = 'Failed to load secrets';
  static const String errorSavingSecret = 'Failed to save secret';
  static const String errorDeletingSecret = 'Failed to delete secret';
  static const String errorExportingData = 'Failed to export data';
  
  static const String successSecretAdded = 'Secret added successfully';
  static const String successSecretDeleted = 'Secret deleted successfully';
  static const String successSecretUpdated = 'Secret updated successfully';
  
  static const String confirmDelete = 'Are you sure you want to delete this secret?';
  static const String confirmClearVault = 'Are you sure you want to clear all secrets?';
  
  static const String biometricReason = 'Scan your fingerprint (or face) to authenticate';
}
