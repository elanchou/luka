import 'package:shared_preferences/shared_preferences.dart';

enum ThemeMode { light, dark, system }

enum AutoLockDuration {
  immediate(seconds: 0, displayName: 'Immediate'),
  seconds30(seconds: 30, displayName: '30 Seconds'),
  minute1(seconds: 60, displayName: '1 Minute'),
  minutes5(seconds: 300, displayName: '5 Minutes'),
  minutes15(seconds: 900, displayName: '15 Minutes'),
  never(seconds: -1, displayName: 'Never');

  final int seconds;
  final String displayName;

  const AutoLockDuration({required this.seconds, required this.displayName});

  static AutoLockDuration fromSeconds(int seconds) {
    for (var duration in AutoLockDuration.values) {
      if (duration.seconds == seconds) return duration;
    }
    return immediate;
  }
}

enum AppLanguage {
  english(code: 'en', displayName: 'English'),
  chinese(code: 'zh', displayName: '简体中文'),
  spanish(code: 'es', displayName: 'Español'),
  french(code: 'fr', displayName: 'Français'),
  german(code: 'de', displayName: 'Deutsch'),
  japanese(code: 'ja', displayName: '日本語');

  final String code;
  final String displayName;

  const AppLanguage({required this.code, required this.displayName});

  static AppLanguage fromCode(String code) {
    for (var lang in AppLanguage.values) {
      if (lang.code == code) return lang;
    }
    return english;
  }
}

class PreferencesService {
  static const _themeKey = 'app_theme_mode';
  static const _hapticsKey = 'haptics_enabled';
  static const _autoLockKey = 'auto_lock_duration';
  static const _biometricKey = 'biometric_enabled';
  static const _languageKey = 'app_language';
  static const _notificationsKey = 'notifications_enabled';

  SharedPreferences? _prefs;

  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
  }

  SharedPreferences get prefs {
    if (_prefs == null) {
      throw Exception('PreferencesService not initialized');
    }
    return _prefs!;
  }

  // Theme Mode
  Future<void> setThemeMode(ThemeMode mode) async {
    await prefs.setString(_themeKey, mode.name);
  }

  ThemeMode getThemeMode() {
    final value = prefs.getString(_themeKey);
    if (value == null) return ThemeMode.dark;
    try {
      return ThemeMode.values.firstWhere((e) => e.name == value);
    } catch (e) {
      return ThemeMode.dark;
    }
  }

  // Haptics
  Future<void> setHapticsEnabled(bool enabled) async {
    await prefs.setBool(_hapticsKey, enabled);
  }

  bool getHapticsEnabled() {
    return prefs.getBool(_hapticsKey) ?? true;
  }

  // Auto-Lock
  Future<void> setAutoLockDuration(AutoLockDuration duration) async {
    await prefs.setInt(_autoLockKey, duration.seconds);
  }

  AutoLockDuration getAutoLockDuration() {
    final seconds = prefs.getInt(_autoLockKey);
    if (seconds == null) return AutoLockDuration.immediate;
    return AutoLockDuration.fromSeconds(seconds);
  }

  // Biometric
  Future<void> setBiometricEnabled(bool enabled) async {
    await prefs.setBool(_biometricKey, enabled);
  }

  bool getBiometricEnabled() {
    return prefs.getBool(_biometricKey) ?? false;
  }

  // Language
  Future<void> setLanguage(AppLanguage language) async {
    await prefs.setString(_languageKey, language.code);
  }

  AppLanguage getLanguage() {
    final code = prefs.getString(_languageKey);
    if (code == null) return AppLanguage.english;
    return AppLanguage.fromCode(code);
  }

  // Notifications
  Future<void> setNotificationsEnabled(bool enabled) async {
    await prefs.setBool(_notificationsKey, enabled);
  }

  bool getNotificationsEnabled() {
    return prefs.getBool(_notificationsKey) ?? true;
  }

  // Reset all preferences
  Future<void> resetAll() async {
    await prefs.remove(_themeKey);
    await prefs.remove(_hapticsKey);
    await prefs.remove(_autoLockKey);
    await prefs.remove(_biometricKey);
    await prefs.remove(_languageKey);
    await prefs.remove(_notificationsKey);
  }
}
