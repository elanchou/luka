import 'package:uuid/uuid.dart';

enum SecretType {
  seedPhrase,
  privateKey,
  note,
  other
}

class Secret {
  final String id;
  final String name;
  final String typeLabel; // For display, e.g., "SEED PHRASE • 24 WORDS"
  final String network; // e.g., "Ethereum", "Bitcoin"
  final String content; // The encrypted content (decrypted in memory)
  final DateTime createdAt;
  final SecretType type;

  Secret({
    required this.id,
    required this.name,
    required this.typeLabel,
    required this.network,
    required this.content,
    required this.createdAt,
    required this.type,
  });

  factory Secret.create({
    required String name,
    required String network,
    required String content,
    required SecretType type,
    String? typeLabel,
  }) {
    String label = typeLabel ?? '';
    if (label.isEmpty) {
      switch (type) {
        case SecretType.seedPhrase:
          label = 'SEED PHRASE';
          break;
        case SecretType.privateKey:
          label = 'PRIVATE KEY';
          break;
        case SecretType.note:
          label = 'SECURE NOTE';
          break;
        default:
          label = 'SECRET';
      }
    }

    return Secret(
      id: const Uuid().v4(),
      name: name,
      typeLabel: label,
      network: network,
      content: content,
      createdAt: DateTime.now(),
      type: type,
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
      'type': type.index,
    };
  }

  factory Secret.fromJson(Map<String, dynamic> json) {
    return Secret(
      id: json['id'],
      name: json['name'],
      typeLabel: json['typeLabel'] ?? '',
      network: json['network'] ?? '',
      content: json['content'],
      createdAt: DateTime.parse(json['createdAt']),
      type: SecretType.values[json['type'] ?? 0],
    );
  }
}
