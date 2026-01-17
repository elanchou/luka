import 'package:uuid/uuid.dart';

enum SecretType {
  seedPhrase,
  privateKey,
  note,
  other
}

extension SecretTypeExtension on SecretType {
  String get displayName {
    switch (this) {
      case SecretType.seedPhrase:
        return 'Seed Phrase';
      case SecretType.privateKey:
        return 'Private Key';
      case SecretType.note:
        return 'Secure Note';
      case SecretType.other:
        return 'Secret';
    }
  }

  String get defaultLabel {
    switch (this) {
      case SecretType.seedPhrase:
        return 'SEED PHRASE';
      case SecretType.privateKey:
        return 'PRIVATE KEY';
      case SecretType.note:
        return 'SECURE NOTE';
      default:
        return 'SECRET';
    }
  }
}

class Secret {
  final String id;
  final String name;
  final String typeLabel; // For display, e.g., "SEED PHRASE • 24 WORDS"
  final String network; // e.g., "Ethereum", "Bitcoin"
  final String content; // The encrypted content (decrypted in memory)
  final DateTime createdAt;
  final DateTime? updatedAt;
  final SecretType type;
  final Map<String, dynamic>? metadata; // Additional custom fields

  Secret({
    required this.id,
    required this.name,
    required this.typeLabel,
    required this.network,
    required this.content,
    required this.createdAt,
    this.updatedAt,
    required this.type,
    this.metadata,
  });

  factory Secret.create({
    required String name,
    required String network,
    required String content,
    required SecretType type,
    String? typeLabel,
    Map<String, dynamic>? metadata,
  }) {
    // Validation
    if (name.trim().isEmpty) {
      throw ArgumentError('Secret name cannot be empty');
    }
    if (content.trim().isEmpty) {
      throw ArgumentError('Secret content cannot be empty');
    }

    String label = typeLabel ?? type.defaultLabel;
    
    // Auto-generate label for seed phrases based on word count
    if (type == SecretType.seedPhrase && typeLabel == null) {
      final wordCount = content.trim().split(RegExp(r'\s+')).length;
      label = 'SEED PHRASE • $wordCount WORDS';
    }

    return Secret(
      id: const Uuid().v4(),
      name: name.trim(),
      typeLabel: label,
      network: network.trim(),
      content: content.trim(),
      createdAt: DateTime.now(),
      type: type,
      metadata: metadata,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'typeLabel': typeLabel,
      'network': network,
      'content': content,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'type': type.index,
      'metadata': metadata,
    };
  }

  factory Secret.fromJson(Map<String, dynamic> json) {
    return Secret(
      id: json['id'] ?? '',
      name: json['name'] ?? 'Untitled',
      typeLabel: json['typeLabel'] ?? '',
      network: json['network'] ?? '',
      content: json['content'] ?? '',
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt']) 
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt']) 
          : null,
      type: SecretType.values[json['type'] ?? 0],
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  Secret copyWith({
    String? name,
    String? typeLabel,
    String? network,
    String? content,
    DateTime? createdAt,
    DateTime? updatedAt,
    SecretType? type,
    Map<String, dynamic>? metadata,
  }) {
    return Secret(
      id: id, // ID should never change
      name: name ?? this.name,
      typeLabel: typeLabel ?? this.typeLabel,
      network: network ?? this.network,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      type: type ?? this.type,
      metadata: metadata ?? this.metadata,
    );
  }

  bool get isSeedPhrase => type == SecretType.seedPhrase;
  bool get isPrivateKey => type == SecretType.privateKey;
  bool get isNote => type == SecretType.note;

  int get wordCount {
    if (type == SecretType.seedPhrase) {
      return content.trim().split(RegExp(r'\s+')).length;
    }
    return 0;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Secret && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
