# AGENTS.md

Guidelines for agentic coding assistants working in this Flutter vault application.

## Build / Lint / Test Commands

```bash
flutter pub get                         # Install dependencies
flutter run                            # Run app
flutter build ios --release              # iOS release build
flutter build apk --release              # Android release build
flutter test                            # Run all tests
flutter test --plain-name "testName"     # Single test function
flutter analyze                         # Lint code
dart format .                           # Format code
```

## Project Structure

```
lib/
├── main.dart                    # App entry point with routes
├── models/                      # Data models (Secret, ActivityLog)
├── providers/                   # State management (Provider pattern)
├── screens/                     # UI screens (pages)
├── services/                    # Business logic, encryption, storage
├── utils/                       # Validators, constants, utilities
└── widgets/                    # Reusable UI components
```

## Code Style Guidelines

### Imports
- Flutter SDK first, packages next, relative imports last. Separate sections with blank lines.

### Naming Conventions
- Classes: PascalCase (`VaultProvider`, `Secret`)
- Variables/Fields: camelCase, private with `_` prefix (`_secrets`, `_isLoading`)
- Constants: camelCase (`primaryColor`, `encryptionKeyLength`)
- Methods: camelCase, private with `_` prefix
- Enums: PascalCase (`SecretType`, `ActivityCategory`)
- Files: snake_case (`secret_model.dart`, `vault_provider.dart`)

### Types
- Always use explicit types for public APIs. Avoid `var` for class members. Use nullable types (`Type?`) for optionals. Never use `dynamic`.

### Error Handling
- All async operations in services/providers must have try-catch blocks. Provide user-friendly error messages. Store error state in providers (`_error` field). Clear errors before new operations, use rollback on failures.

### State Management (Provider Pattern)
- Extend `ChangeNotifier`. Use private fields with public getters. Only call `notifyListeners()` when state actually changes. Use initialization guards (`if (_isInitialized) return;`). Return `bool` for success/failure in async actions. Update UI state before async ops (`_isLoading = true`).

### Models
- Use `final` for all fields (immutable). Provide factory constructors (`create`, `fromJson`). Implement `copyWith`, `==`, `hashCode`. Use getters for computed properties. Validate data in factory constructors.

### Security
- Encrypt all sensitive data (use `EncryptionService`). Never log/print sensitive data. Use `flutter_secure_storage` for encryption keys. Validate all user inputs. Use BIP39 wordlist validation for seed phrases.

### Widgets
- Prefer `StatelessWidget`. Use `const` constructors. Extract reusable components to `widgets/`. Use `GoogleFonts.spaceGrotesk()` for text. Use `PhosphorIconsBold.iconName` for icons. Provide haptic feedback.

### Formatting
- 2-space indentation, 2 blank lines between top-level declarations, 1 blank line between methods. Line length ~100 chars (soft limit). Use trailing commas for multi-line.

### Services
- Single responsibility per service. Initialize with `init()` method. All methods handle errors internally. Return `Future<bool>` for success/failure.

## Testing

- Test files location: `test/` (same structure as `lib/`)
- Use `flutter test --plain-name "testName"` for single test
- Test all service methods with error cases, test widget interactions

## Dependencies

Key packages: `provider: ^6.1.5+1`, `flutter_secure_storage: ^10.0.0`, `encrypt: ^5.0.3`, `bip39: ^1.0.6`, `google_fonts: ^6.1.0`, `phosphor_flutter: ^2.1.0`, `path_provider: ^2.1.5`

## Common Patterns

### Provider Pattern
```dart
class MyProvider extends ChangeNotifier {
  List<Item> _items = [];
  bool _isLoading = false;

  List<Item> get items => _items;
  bool get isLoading => _isLoading;

  Future<void> loadItems() async {
    _isLoading = true;
    notifyListeners();
    try {
      _items = await _service.load();
    } catch (e) {
      _error = 'Failed: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
```

### Validation Pattern
```dart
class Validators {
  static ValidationResult validateName(String name) {
    if (name.trim().isEmpty) {
      return ValidationResult(isValid: false, error: 'Name cannot be empty');
    }
    return ValidationResult(isValid: true);
  }
}
```

### Error Handling in Services
```dart
Future<bool> doSomething() async {
  try {
    await _performOperation();
    return true;
  } catch (e) {
    _error = 'Failed: $e';
    notifyListeners();
    return false;
  }
}
```

## Security Checklist

- [ ] All sensitive data encrypted before storage
- [ ] Encryption keys stored in flutter_secure_storage
- [ ] No sensitive data in logs or error messages
- [ ] Input validation for all user data
- [ ] Secure random for encryption IVs
- [ ] Clear sensitive data from memory after use
