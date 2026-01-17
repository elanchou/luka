import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import '../widgets/error_snackbar.dart';

class ClipboardUtils {
  // Copy to clipboard with feedback
  static Future<void> copyToClipboard(
    BuildContext context, {
    required String text,
    String? successMessage,
  }) async {
    try {
      await Clipboard.setData(ClipboardData(text: text));
      if (context.mounted) {
        SuccessSnackbar.show(
          context,
          message: successMessage ?? 'Copied to clipboard',
          duration: const Duration(seconds: 1),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ErrorSnackbar.show(
          context,
          message: 'Failed to copy to clipboard',
        );
      }
    }
  }

  // Copy seed phrase with confirmation
  static Future<void> copySeedPhrase(
    BuildContext context, {
    required String seedPhrase,
  }) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF16262c),
        title: const Text('Copy Seed Phrase?'),
        content: const Text(
          'This will copy your seed phrase to the clipboard. '
          'Make sure no one can see your screen.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Copy'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await copyToClipboard(
        context,
        text: seedPhrase,
        successMessage: 'Seed phrase copied',
      );
    }
  }

  // Copy private key with confirmation
  static Future<void> copyPrivateKey(
    BuildContext context, {
    required String privateKey,
  }) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF16262c),
        title: const Text('Copy Private Key?'),
        content: const Text(
          'This will copy your private key to the clipboard. '
          'Never share this with anyone.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Copy'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await copyToClipboard(
        context,
        text: privateKey,
        successMessage: 'Private key copied',
      );
    }
  }
}
