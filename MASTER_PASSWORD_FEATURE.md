# Master Password Encryption Feature

## Overview

This vault app now uses **master password-based encryption** with PBKDF2 key derivation, similar to 1Password's security model. All secrets are encrypted using AES-256-CBC with keys derived from your master password.

## Key Features

### 1. **Master Password-Based Key Derivation**
- Uses PBKDF2-HMAC-SHA256 for key derivation
- Random 256-bit salt stored securely
- Configurable iteration count based on security level
- No hardcoded encryption keys

### 2. **Security Levels**

Three security levels available (like 1Password):

- **Standard** (100,000 iterations)
  - Good balance between security and performance
  - Suitable for most users
  - Unlock time: ~100-200ms

- **Enhanced** (650,000 iterations)
  - Higher security, slightly slower
  - Recommended for sensitive data
  - Unlock time: ~500-700ms

- **Paranoid** (1,000,000 iterations)
  - Maximum security
  - Slower unlock time
  - Unlock time: ~1-1.5s

### 3. **Features**

- ✅ Set master password on first launch
- ✅ Change master password anytime
- ✅ Adjust security level (requires password verification)
- ✅ Backward compatible with legacy random keys
- ✅ Migration from legacy to password-based encryption
- ✅ Password strength validation (minimum 8 characters)

## Architecture

### Core Components

#### 1. MasterKeyService (`lib/services/master_key_service.dart`)
- Manages master password storage and verification
- Implements PBKDF2 key derivation
- Stores salt and iteration count securely

#### 2. EncryptionService (`lib/services/encryption_service.dart`)
- Handles AES-256-CBC encryption/decryption
- Supports both password-based and legacy random keys
- Manages encryption key lifecycle

#### 3. VaultService (`lib/services/vault_service.dart`)
- Coordinates encryption and file I/O
- Saves/loads encrypted vault data
- Exports decrypted data

#### 4. Security Settings Model (`lib/models/security_settings.dart`)
- Defines security levels and their parameters
- Auto-lock duration configuration

### UI Components

#### SetMasterPasswordScreen
- Set initial master password
- Change existing password
- Select security level
- Password confirmation
- Show/hide password toggle

#### SystemSettingsScreen
- View current security settings
- Change master password
- Adjust security level
- Other vault settings

## Security Implementation Details

### Key Derivation (PBKDF2)

```dart
Key = PBKDF2-HMAC-SHA256(
  password: master_password,
  salt: random_256_bits,
  iterations: 100000-1000000,
  keyLength: 32 bytes
)
```

### Encryption (AES-256-CBC)

```dart
Encrypted = AES-256-CBC(
  key: derived_key,
  iv: random_128_bits,
  plaintext: secret_data
)

Stored = Base64(IV + Encrypted)
```

### Storage Layout

**FlutterSecureStorage** stores:
- `vault_master_salt`: Base64-encoded 256-bit salt
- `vault_pbkdf2_iterations`: Iteration count (100000-1000000)
- `vault_has_password`: Boolean flag

**File System** stores:
- `vault.enc`: Encrypted secrets (AES-256-CBC)

## Usage Flow

### First Time Setup

1. User launches app
2. App detects no master password set
3. User navigates to "Set Master Password"
4. User enters password (min 8 chars)
5. User selects security level
6. Salt is generated and stored
7. Key is derived from password
8. Vault is initialized

### Normal Unlock

1. User enters master password
2. Salt and iterations are loaded
3. Key is derived using PBKDF2
4. Vault is decrypted with derived key
5. Secrets become accessible

### Changing Password

1. User enters current password
2. System verifies current password
3. User enters new password
4. New salt is generated
5. All data remains encrypted with new key
6. Old password becomes invalid

### Changing Security Level

1. User selects new security level
2. System prompts for password
3. Password is verified
4. Iteration count is updated
5. Next unlock will use new iteration count

## Migration Strategy

### From Legacy Random Key

The app supports automatic migration:

1. **Detection**: Check if `vault_has_password` is false
2. **Legacy Mode**: Use existing random key
3. **Migration Prompt**: Offer to set master password
4. **Migration**: Re-encrypt all secrets with password-based key
5. **Cleanup**: Remove legacy random key

```dart
// Check if migration needed
if (!encryptionService.usesPassword) {
  // Prompt user to migrate
  await encryptionService.migrateToPasswordBased(
    masterPassword,
    SecurityLevel.standard,
  );
}
```

## Security Considerations

### ✅ Strong Points

- Industry-standard PBKDF2 key derivation
- High iteration counts (100k-1M)
- Random salts prevent rainbow table attacks
- AES-256 encryption
- Secure storage of cryptographic materials

### ⚠️ Important Notes

- **Password Recovery**: No password recovery mechanism. Lost password = lost data
- **Export Warning**: Exported JSON files are unencrypted
- **Biometric**: Biometric auth is convenience only, not primary security
- **No Cloud Sync**: All data stored locally

### 🔒 Best Practices

1. **Strong Passwords**: Use at least 12+ characters with mixed case, numbers, symbols
2. **Unique Password**: Don't reuse passwords from other services
3. **Security Level**: Choose Enhanced or Paranoid for sensitive data
4. **Backup**: Export and securely store encrypted backups
5. **Device Security**: Use device encryption and screen lock

## Testing

### Test Password Setup

```dart
final masterKeyService = MasterKeyService();
await masterKeyService.setMasterPassword(
  'MySecurePassword123!',
  SecurityLevel.standard,
);
```

### Test Key Derivation

```dart
final key = await masterKeyService.deriveMasterKey('MySecurePassword123!');
print('Derived key: ${base64.encode(key.bytes)}');
```

### Test Encryption/Decryption

```dart
final encryptionService = EncryptionService();
await encryptionService.init(masterPassword: 'MySecurePassword123!');

final encrypted = encryptionService.encryptData('Secret message');
final decrypted = encryptionService.decryptData(encrypted);
assert(decrypted == 'Secret message');
```

## Performance

### Key Derivation Benchmarks (iPhone 12)

- Standard (100k): ~100-200ms
- Enhanced (650k): ~500-700ms
- Paranoid (1M): ~1000-1500ms

### Recommendations

- **Standard**: Daily-use devices
- **Enhanced**: Shared devices or public spaces
- **Paranoid**: Maximum security, infrequent access

## Dependencies

```yaml
dependencies:
  crypto: ^3.0.3          # PBKDF2 and HMAC-SHA256
  encrypt: ^5.0.3         # AES encryption
  flutter_secure_storage: ^10.0.0  # Secure key storage
```

## API Reference

### MasterKeyService

```dart
class MasterKeyService {
  Future<bool> hasPassword();
  Future<void> setMasterPassword(String password, SecurityLevel level);
  Future<Key> deriveMasterKey(String password);
  Future<SecurityLevel> getSecurityLevel();
  Future<void> updateSecurityLevel(String password, SecurityLevel level);
  Future<bool> verifyPassword(String password);
  Future<void> changeMasterPassword(String oldPassword, String newPassword, SecurityLevel level);
  Future<void> reset();
}
```

### EncryptionService

```dart
class EncryptionService {
  Future<void> init({String? masterPassword});
  Future<void> migrateToPasswordBased(String password, SecurityLevel level);
  Future<void> updatePassword(String oldPassword, String newPassword, SecurityLevel level);
  String encryptData(String plainText);
  String decryptData(String encryptedBase64);
  Future<void> reset();
  bool get usesPassword;
}
```

## Future Enhancements

- [ ] Password strength meter
- [ ] Biometric unlock with master password fallback
- [ ] Encrypted cloud backup
- [ ] Password hints (stored securely)
- [ ] Emergency access codes
- [ ] Multi-device sync with end-to-end encryption
- [ ] Hardware security key support

## Troubleshooting

### "Master password required" error
- **Cause**: Password not set or vault locked
- **Solution**: Navigate to Settings > Set Master Password

### "Failed to derive master key" error
- **Cause**: Incorrect password or corrupted salt
- **Solution**: Verify password or reset vault (loses all data)

### Slow unlock times
- **Cause**: High security level on older devices
- **Solution**: Reduce security level to Standard

## References

- [PBKDF2 Specification (RFC 2898)](https://www.rfc-editor.org/rfc/rfc2898)
- [AES-256 Encryption](https://en.wikipedia.org/wiki/Advanced_Encryption_Standard)
- [1Password Security Design](https://1password.com/security/)
- [OWASP Password Storage Cheat Sheet](https://cheatsheetseries.owasp.org/cheatsheets/Password_Storage_Cheat_Sheet.html)

