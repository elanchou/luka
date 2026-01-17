import '../services/master_key_service.dart';

/// Security settings model
class SecuritySettings {
  final SecurityLevel securityLevel;
  final bool biometricEnabled;
  final AutoLockDuration autoLockDuration;

  SecuritySettings({
    this.securityLevel = SecurityLevel.standard,
    this.biometricEnabled = false,
    this.autoLockDuration = AutoLockDuration.immediate,
  });

  Map<String, dynamic> toJson() => {
    'securityLevel': securityLevel.iterations,
    'biometricEnabled': biometricEnabled,
    'autoLockDuration': autoLockDuration.index,
  };

  factory SecuritySettings.fromJson(Map<String, dynamic> json) {
    return SecuritySettings(
      securityLevel: SecurityLevel.fromIterations(
        json['securityLevel'] ?? SecurityLevel.standard.iterations,
      ),
      biometricEnabled: json['biometricEnabled'] ?? false,
      autoLockDuration: AutoLockDuration.values[
        json['autoLockDuration'] ?? AutoLockDuration.immediate.index
      ],
    );
  }

  SecuritySettings copyWith({
    SecurityLevel? securityLevel,
    bool? biometricEnabled,
    AutoLockDuration? autoLockDuration,
  }) {
    return SecuritySettings(
      securityLevel: securityLevel ?? this.securityLevel,
      biometricEnabled: biometricEnabled ?? this.biometricEnabled,
      autoLockDuration: autoLockDuration ?? this.autoLockDuration,
    );
  }
}

enum AutoLockDuration {
  immediate('Immediate'),
  oneMinute('1 minute'),
  fiveMinutes('5 minutes'),
  fifteenMinutes('15 minutes'),
  never('Never');

  final String displayName;
  const AutoLockDuration(this.displayName);
}
