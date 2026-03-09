import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import '../widgets/gradient_background.dart';
import '../widgets/sault_button.dart';
import '../widgets/sault_outline_button.dart';
import '../widgets/sault_brand.dart';
import '../providers/sault_provider.dart';
import '../services/icloud_backup_service.dart';
import '../utils/constants.dart';
import '../widgets/error_snackbar.dart';
import '../widgets/sault_dialog.dart';

class SaultOnboardingScreen extends StatelessWidget {
  const SaultOnboardingScreen({super.key});

  Future<void> _restoreFromICloud(BuildContext context) async {
    final confirm = await showSaultDialog<bool>(
      context,
      title: 'Restore from iCloud?',
      message:
          'This will restore your vault from iCloud backup. You will need the original master password to unlock it.',
      icon: PhosphorIconsBold.cloudArrowDown,
      tone: SaultDialogTone.info,
      actions: const <SaultDialogAction<bool>>[
        SaultDialogAction<bool>(label: 'Cancel', value: false),
        SaultDialogAction<bool>(
          label: 'Restore',
          value: true,
          isPrimary: true,
        ),
      ],
    );

    if (confirm == true && context.mounted) {
      final icloud = ICloudBackupService();
      final success = await icloud.restoreFromICloud();
      if (context.mounted) {
        if (success) {
          SuccessSnackbar.show(context,
              message: 'Sault restored. Please log in.');
          Navigator.of(context).pushReplacementNamed('/');
        } else {
          ErrorSnackbar.show(context,
              message: 'Restore failed: ${icloud.lastError}');
        }
      }
    }
  }

  Future<void> _importVault(BuildContext context) async {
    final result = await FilePicker.platform.pickFiles();
    if (result != null && result.files.single.path != null) {
      if (!context.mounted) return;

      final confirm = await showSaultDialog<bool>(
        context,
        title: 'Import Sault?',
        message:
            'This will load an existing encrypted vault file. You will need the original master password to unlock it.',
        icon: PhosphorIconsBold.downloadSimple,
        tone: SaultDialogTone.info,
        actions: const <SaultDialogAction<bool>>[
          SaultDialogAction<bool>(label: 'Cancel', value: false),
          SaultDialogAction<bool>(
            label: 'Import',
            value: true,
            isPrimary: true,
          ),
        ],
      );

      if (confirm == true && context.mounted) {
        try {
          final vaultProvider =
              Provider.of<SaultProvider>(context, listen: false);
          await vaultProvider.importVault(File(result.files.single.path!));
          if (context.mounted) {
            SuccessSnackbar.show(context,
                message: 'Sault imported. Please log in.');
            Navigator.of(context).pushReplacementNamed('/');
          }
        } catch (e) {
          if (context.mounted) {
            ErrorSnackbar.show(context, message: 'Failed to import vault: $e');
          }
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: Stack(
        children: [
          const GradientBackground(),
          SafeArea(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SaultBrand(fontSize: 26),
                  Expanded(
                    child: Center(
                      child: Container(
                        constraints: const BoxConstraints(maxWidth: 560),
                        padding: const EdgeInsets.all(28),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.045),
                          borderRadius: BorderRadius.circular(32),
                          border: Border.all(color: AppColors.softBorderColor),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.22),
                              blurRadius: 40,
                              offset: const Offset(0, 20),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 64,
                              height: 64,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(22),
                                color: AppColors.primaryColor
                                    .withValues(alpha: 0.10),
                                border: Border.all(
                                  color: AppColors.primaryColor
                                      .withValues(alpha: 0.24),
                                ),
                              ),
                              child: const Icon(
                                PhosphorIconsBold.lockSimple,
                                color: AppColors.primaryColor,
                                size: 28,
                              ),
                            ),
                            const SizedBox(height: 28),
                            Text(
                              'Private vaulting,\nrefined to essentials.',
                              style: GoogleFonts.spaceGrotesk(
                                fontSize: 34,
                                height: 1.02,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                                letterSpacing: -1.2,
                              ),
                            ),
                            const SizedBox(height: 14),
                            Text(
                              'Sault keeps seed phrases, keys, and sensitive notes in a premium offline vault secured by your master password.',
                              style: GoogleFonts.notoSans(
                                fontSize: 15,
                                height: 1.6,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 26),
                            Container(
                              padding: const EdgeInsets.all(18),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.03),
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(
                                    color: AppColors.softBorderColor),
                              ),
                              child: const Row(
                                children: [
                                  _FeatureChip(
                                    icon: PhosphorIconsBold.shieldCheck,
                                    label: 'PBKDF2',
                                  ),
                                  SizedBox(width: 10),
                                  _FeatureChip(
                                    icon: PhosphorIconsBold.lockKey,
                                    label: 'AES Vault',
                                  ),
                                  SizedBox(width: 10),
                                  _FeatureChip(
                                    icon: PhosphorIconsBold.cloud,
                                    label: 'Backup',
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SaultButton(
                    text: 'Create New Sault',
                    icon: PhosphorIconsBold.arrowRight,
                    onTap: () {
                      Navigator.pushNamed(context, '/set-master-password');
                    },
                    backgroundColor: AppColors.primaryColor,
                    textColor: AppColors.backgroundDark,
                  ),
                  const SizedBox(height: 16),
                  SaultOutlineButton(
                    text: 'Import Sault File',
                    icon: PhosphorIconsBold.fileArrowDown,
                    onTap: () => _importVault(context),
                    textColor: AppColors.textPrimary,
                  ),
                  FutureBuilder<bool>(
                    future: ICloudBackupService().hasICloudBackup(),
                    builder: (context, snapshot) {
                      if (snapshot.data != true) return const SizedBox.shrink();
                      return Padding(
                        padding: const EdgeInsets.only(top: 16),
                        child: SaultOutlineButton(
                          text: 'Restore from iCloud',
                          icon: PhosphorIconsBold.cloudArrowDown,
                          onTap: () => _restoreFromICloud(context),
                          textColor: AppColors.textPrimary,
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  Column(
                    children: [
                      Text(
                        'Private by default',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 12,
                          color: AppColors.textMuted,
                          letterSpacing: 0.8,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'v1.0.2 • Master Password Encrypted',
                        style: GoogleFonts.notoSans(
                          fontSize: 10,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FeatureChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _FeatureChip({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.14),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.softBorderColor),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 14, color: AppColors.primaryColor),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.spaceGrotesk(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
