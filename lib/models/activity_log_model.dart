import 'package:uuid/uuid.dart';

enum ActivityCategory { security, access, transfers, system }

class ActivityLog {
  final String id;
  final String title;
  final String description;
  final DateTime timestamp;
  final ActivityCategory category;
  final bool isSuccess;

  ActivityLog({
    required this.id,
    required this.title,
    required this.description,
    required this.timestamp,
    required this.category,
    this.isSuccess = true,
  });

  factory ActivityLog.create({
    required String title,
    required String description,
    required ActivityCategory category,
    bool isSuccess = true,
  }) {
    return ActivityLog(
      id: const Uuid().v4(),
      title: title,
      description: description,
      timestamp: DateTime.now(),
      category: category,
      isSuccess: isSuccess,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'timestamp': timestamp.toIso8601String(),
    'category': category.index,
    'isSuccess': isSuccess,
  };

  factory ActivityLog.fromJson(Map<String, dynamic> json) => ActivityLog(
    id: json['id'],
    title: json['title'],
    description: json['description'],
    timestamp: DateTime.parse(json['timestamp']),
    category: ActivityCategory.values[json['category']],
    isSuccess: json['isSuccess'] ?? true,
  );
}
