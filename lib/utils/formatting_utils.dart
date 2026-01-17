import 'package:intl/intl.dart';

class FormattingUtils {
  // Format date
  static String formatDate(DateTime date, {String format = 'MMM d, yyyy'}) {
    return DateFormat(format).format(date);
  }

  // Format date with time
  static String formatDateTime(DateTime date) {
    return DateFormat('MMM d, yyyy • HH:mm').format(date);
  }

  // Format relative time (e.g., "2 hours ago")
  static String formatRelativeTime(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inSeconds < 60) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      final minutes = difference.inMinutes;
      return '$minutes ${minutes == 1 ? 'minute' : 'minutes'} ago';
    } else if (difference.inHours < 24) {
      final hours = difference.inHours;
      return '$hours ${hours == 1 ? 'hour' : 'hours'} ago';
    } else if (difference.inDays < 7) {
      final days = difference.inDays;
      return '$days ${days == 1 ? 'day' : 'days'} ago';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '$weeks ${weeks == 1 ? 'week' : 'weeks'} ago';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return '$months ${months == 1 ? 'month' : 'months'} ago';
    } else {
      final years = (difference.inDays / 365).floor();
      return '$years ${years == 1 ? 'year' : 'years'} ago';
    }
  }

  // Mask seed phrase (show only first and last word)
  static String maskSeedPhrase(String seedPhrase) {
    final words = seedPhrase.trim().split(RegExp(r'\s+'));
    if (words.length <= 2) return seedPhrase;
    
    final firstWord = words.first;
    final lastWord = words.last;
    final maskedCount = words.length - 2;
    
    return '$firstWord ${'•' * maskedCount} $lastWord';
  }

  // Mask private key (show only first and last 4 characters)
  static String maskPrivateKey(String privateKey) {
    if (privateKey.length <= 8) return privateKey;
    
    final start = privateKey.substring(0, 4);
    final end = privateKey.substring(privateKey.length - 4);
    final maskedLength = privateKey.length - 8;
    
    return '$start${'•' * (maskedLength > 20 ? 20 : maskedLength)}$end';
  }

  // Truncate text with ellipsis
  static String truncate(String text, {int maxLength = 50}) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }

  // Format file size
  static String formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  // Capitalize first letter
  static String capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }

  // Convert to title case
  static String toTitleCase(String text) {
    if (text.isEmpty) return text;
    return text.split(' ').map((word) => capitalize(word)).join(' ');
  }
}
