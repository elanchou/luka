import 'package:flutter/services.dart';
import 'package:flutter/material.dart';

import '../widgets/error_snackbar.dart';
import '../widgets/sault_dialog.dart';

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
    final confirmed = await showSaultDialog<bool>(
      context,
      title: 'Copy Seed Phrase?',
      message:
          'This will copy your seed phrase to the clipboard. Make sure no one can see your screen.',
      icon: Icons.copy_rounded,
      tone: SaultDialogTone.danger,
      actions: const <SaultDialogAction<bool>>[
        SaultDialogAction<bool>(label: 'Cancel', value: false),
        SaultDialogAction<bool>(
          label: 'Copy',
          value: true,
          isPrimary: true,
        ),
      ],
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
    final confirmed = await showSaultDialog<bool>(
      context,
      title: 'Copy Private Key?',
      message:
          'This will copy your private key to the clipboard. Never share this with anyone.',
      icon: Icons.key_rounded,
      tone: SaultDialogTone.danger,
      actions: const <SaultDialogAction<bool>>[
        SaultDialogAction<bool>(label: 'Cancel', value: false),
        SaultDialogAction<bool>(
          label: 'Copy',
          value: true,
          isPrimary: true,
        ),
      ],
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
