class Validators {
  // Validate seed phrase
  static ValidationResult validateSeedPhrase(List<String> words, List<String> wordlist) {
    if (words.isEmpty) {
      return ValidationResult(
        isValid: false,
        error: 'Seed phrase cannot be empty',
      );
    }

    // Check for valid word count (12, 15, 18, 21, 24)
    final validCounts = [12, 15, 18, 21, 24];
    if (!validCounts.contains(words.length)) {
      return ValidationResult(
        isValid: false,
        error: 'Seed phrase must be 12, 15, 18, 21, or 24 words. Found ${words.length} words.',
      );
    }

    // Check if all words are in the BIP39 wordlist
    final invalidWords = <String>[];
    for (int i = 0; i < words.length; i++) {
      if (!wordlist.contains(words[i].toLowerCase())) {
        invalidWords.add('Word ${i + 1}: "${words[i]}"');
      }
    }

    if (invalidWords.isNotEmpty) {
      return ValidationResult(
        isValid: false,
        error: 'Invalid words found:\n${invalidWords.join('\n')}',
      );
    }

    return ValidationResult(isValid: true);
  }

  // Validate secret name
  static ValidationResult validateName(String name) {
    final trimmed = name.trim();
    
    if (trimmed.isEmpty) {
      return ValidationResult(
        isValid: false,
        error: 'Name cannot be empty',
      );
    }

    if (trimmed.length < 2) {
      return ValidationResult(
        isValid: false,
        error: 'Name must be at least 2 characters',
      );
    }

    if (trimmed.length > 50) {
      return ValidationResult(
        isValid: false,
        error: 'Name must be less than 50 characters',
      );
    }

    return ValidationResult(isValid: true);
  }

  // Validate network name
  static ValidationResult validateNetwork(String network) {
    final trimmed = network.trim();
    
    if (trimmed.isEmpty) {
      return ValidationResult(isValid: true); // Network is optional
    }

    if (trimmed.length > 30) {
      return ValidationResult(
        isValid: false,
        error: 'Network name must be less than 30 characters',
      );
    }

    return ValidationResult(isValid: true);
  }

  // Validate private key
  static ValidationResult validatePrivateKey(String key) {
    final trimmed = key.trim();
    
    if (trimmed.isEmpty) {
      return ValidationResult(
        isValid: false,
        error: 'Private key cannot be empty',
      );
    }

    // Check if it's a valid hex string (with or without 0x prefix)
    final hexPattern = RegExp(r'^(0x)?[0-9a-fA-F]+$');
    if (!hexPattern.hasMatch(trimmed)) {
      return ValidationResult(
        isValid: false,
        error: 'Private key must be a valid hexadecimal string',
      );
    }

    // Remove 0x prefix for length check
    final cleanKey = trimmed.startsWith('0x') ? trimmed.substring(2) : trimmed;
    
    // Common lengths: 64 characters (32 bytes) for most cryptocurrencies
    if (cleanKey.length != 64) {
      return ValidationResult(
        isValid: false,
        error: 'Private key should be 64 hexadecimal characters (found ${cleanKey.length})',
      );
    }

    return ValidationResult(isValid: true);
  }

  // Validate content (generic)
  static ValidationResult validateContent(String content) {
    final trimmed = content.trim();
    
    if (trimmed.isEmpty) {
      return ValidationResult(
        isValid: false,
        error: 'Content cannot be empty',
      );
    }

    if (trimmed.length > 10000) {
      return ValidationResult(
        isValid: false,
        error: 'Content is too long (max 10000 characters)',
      );
    }

    return ValidationResult(isValid: true);
  }
}

class ValidationResult {
  final bool isValid;
  final String? error;

  ValidationResult({
    required this.isValid,
    this.error,
  });
}
