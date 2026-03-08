import 'package:flutter/material.dart';

class AppColors {
  static const primaryColor = Color(0xFFD6C3A1);
  static const accentColor = Color(0xFFE7DBCA);
  static const backgroundDark = Color(0xFF0F0F10);
  static const backgroundElevated = Color(0xFF151517);
  static const surfaceDark = Color(0xFF17181B);
  static const surfaceHighlight = Color(0xFF202227);
  static const borderColor = Color(0xFF2A2C31);
  static const softBorderColor = Color(0xFF22242A);
  static const labelColor = Color(0xFF8D8A84);
  static const inputBorderColor = Color(0xFF2E3138);
  static const textPrimary = Color(0xFFF5F1E8);
  static const textSecondary = Color(0xFFABA59B);
  static const textMuted = Color(0xFF78736A);
  static const successColor = Color(0xFF9BAA8C);
  static const dangerColor = Color(0xFFCF8F87);
  static const warningColor = Color(0xFFB89A6A);
}

class AppConstants {
  static const String appName = 'Sault';
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
