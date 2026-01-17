# Vault App

A secure vault application for managing secrets, seed phrases, and private keys built with Flutter.

## Features

✨ **Secure Storage**
- AES-256 encryption for all sensitive data
- Flutter Secure Storage for encryption keys
- BIP39 seed phrase validation
- Private key validation and storage

🔐 **Biometric Authentication**
- Fingerprint and Face ID support
- Secure vault access
- Device-level security

📝 **Secret Management**
- Store seed phrases (12, 15, 18, 21, 24 words)
- Store private keys
- Store secure notes
- Search and filter functionality

📤 **Export & Backup**
- Export decrypted data to JSON
- Share functionality
- Activity logging

## Architecture

### Project Structure

```
lib/
├── main.dart                    # App entry point
├── models/
│   └── secret_model.dart        # Data model for secrets
├── providers/
│   └── vault_provider.dart      # State management
├── screens/
│   ├── app_splash_screen.dart
│   ├── vault_onboarding_screen.dart
│   ├── biometric_auth_screen.dart
│   ├── main_vault_dashboard.dart
│   ├── add_secret_step_1.dart
│   ├── add_secret_step_2.dart
│   ├── seed_phrase_detail_view.dart
│   ├── activity_log_screen.dart
│   ├── system_settings_screen.dart
│   └── export_progress_screen.dart
├── services/
│   ├── encryption_service.dart  # AES encryption
│   ├── vault_service.dart       # Data persistence
│   └── biometric_service.dart   # Biometric auth
├── utils/
│   ├── validators.dart         # Input validation
│   ├── constants.dart          # App constants
│   ├── formatting_utils.dart   # Formatting helpers
│   └── clipboard_utils.dart    # Clipboard operations
└── widgets/
    ├── vault_button.dart
    ├── vault_text_field.dart
    ├── custom_bottom_nav_bar.dart
    ├── gradient_background.dart
    ├── error_snackbar.dart
    └── loading_overlay.dart
```

### Key Optimizations

#### 1. **Enhanced Error Handling**
- Comprehensive try-catch blocks in all services
- User-friendly error messages
- Graceful degradation on failures
- Error state management in providers

#### 2. **Improved Security**
- Initialization guards to prevent double-init
- Input validation for all user data
- Key length validation
- BIP39 wordlist validation
- Encrypted data integrity checks

#### 3. **Better State Management**
- Optimized notifyListeners() calls
- Prevented unnecessary rebuilds
- Added search query optimization
- Rollback mechanisms on failures
- Getter methods for computed properties

#### 4. **Code Quality**
- Separated constants into dedicated files
- Created reusable utility classes
- Added validators for all input types
- Improved code organization
- Added documentation

#### 5. **Performance**
- Lazy initialization
- Caching mechanisms
- Efficient search filtering
- Optimized file I/O operations

## Installation

1. Clone the repository:
```bash
git clone <repository-url>
cd vault_app
```

2. Install dependencies:
```bash
flutter pub get
```

3. Run the app:
```bash
flutter run
```

## Dependencies

- `flutter_secure_storage`: Secure key storage
- `encrypt`: AES encryption
- `provider`: State management
- `local_auth`: Biometric authentication
- `bip39`: Seed phrase generation and validation
- `google_fonts`: Typography
- `share_plus`: Share functionality
- `intl`: Date formatting

## Security Considerations

⚠️ **Important Security Notes:**

1. **Encryption**: All secrets are encrypted using AES-256-CBC with randomly generated IVs
2. **Key Storage**: Encryption keys are stored in device keychain using FlutterSecureStorage
3. **No Cloud Sync**: All data is stored locally on the device
4. **Biometric Auth**: Optional biometric authentication for vault access
5. **Export Warning**: Exported JSON files are unencrypted - handle with care

## Usage

### Adding a Secret

1. Tap the "+" button on the dashboard
2. Enter secret name and network (optional)
3. Choose secret type and enter content
4. Tap "Save" to encrypt and store

### Viewing Secrets

1. Tap any secret card from the dashboard
2. View details, copy, or delete
3. Use biometric auth if enabled

### Exporting Data

1. Go to Settings tab
2. Tap "Export Vault Data"
3. Choose sharing method
4. **Warning**: Exported data is unencrypted

## Testing

Run tests:
```bash
flutter test
```

## Building

### iOS
```bash
flutter build ios --release
```

### Android
```bash
flutter build apk --release
```

## License

This project is for educational and personal use only.

## Contributing

Contributions are welcome! Please follow these guidelines:

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## Future Enhancements

- [ ] Cloud backup with encryption
- [ ] Multi-vault support
- [ ] Password strength meter
- [ ] Auto-lock timer
- [ ] Import from other vault apps
- [ ] QR code generation for sharing
- [ ] Custom categories and tags
- [ ] Backup reminders
- [ ] Password generator

## Support

For issues, questions, or suggestions, please open an issue on GitHub.
