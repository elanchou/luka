import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'dart:ui';
import 'package:intl/intl.dart';
import '../models/secret_model.dart';
import 'package:provider/provider.dart';
import '../providers/vault_provider.dart';
import '../widgets/gradient_background.dart';
import '../widgets/vault_app_bar.dart';
import '../widgets/vault_brand.dart';
import '../widgets/error_snackbar.dart';

class SeedPhraseDetailView extends StatelessWidget {
  const SeedPhraseDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF13b6ec);
    const backgroundDark = Color(0xFF101d22);
    const surfaceDark = Color(0xFF16262c);
    const surfaceHighlight = Color(0xFF1f363d);

    final secret = ModalRoute.of(context)!.settings.arguments as Secret;

    List<String> seedWords = [];
    if (secret.type == SecretType.seedPhrase) {
      seedWords = secret.content.split(' ');
    } else {
      seedWords = [secret.content];
    }

    final formattedDate = DateFormat('MMM d, yyyy').format(secret.createdAt);

    return Scaffold(
      backgroundColor: backgroundDark,
      extendBodyBehindAppBar: true,
      appBar: VaultAppBar(
        titleWidget: const VaultBrand(fontSize: 16),
        actions: [
          IconButton(
            icon: const Icon(PhosphorIconsBold.trash, size: 22),
            color: Colors.white.withValues(alpha: 0.5),
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  backgroundColor: surfaceDark,
                  title: Text(
                    'Delete Secret?',
                    style: GoogleFonts.spaceGrotesk(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  content: Text(
                    'This action cannot be undone.',
                    style: GoogleFonts.notoSans(color: Colors.grey[400]),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: Text(
                        'Cancel',
                        style: GoogleFonts.spaceGrotesk(color: Colors.grey[400]),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        HapticFeedback.heavyImpact();
                        Navigator.pop(context, true);
                      },
                      style: TextButton.styleFrom(foregroundColor: Colors.red),
                      child: Text(
                        'Delete',
                        style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              );

              if (confirm == true) {
                if (context.mounted) {
                  await Provider.of<VaultProvider>(context, listen: false).deleteSecret(secret.id);
                  Navigator.pop(context);
                }
              }
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          const GradientBackground(),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: Column(
                children: [
                  // Header
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [surfaceDark, surfaceHighlight],
                      ),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                    ),
                    child: Icon(
                      secret.type == SecretType.seedPhrase
                          ? PhosphorIconsBold.wallet
                          : PhosphorIconsBold.key,
                      size: 32,
                      color: primaryColor,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    secret.name,
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Created on $formattedDate',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 12,
                      color: Colors.grey[500],
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Seed Grid or Content View
                  if (secret.type == SecretType.seedPhrase)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                        child: Container(
                          decoration: BoxDecoration(
                            color: surfaceDark.withValues(alpha: 0.6),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                height: 1,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.transparent,
                                      primaryColor.withValues(alpha: 0.5),
                                      Colors.transparent,
                                    ],
                                  ),
                                ),
                              ),
                              GridView.builder(
                                padding: const EdgeInsets.all(12),
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  childAspectRatio: 3.2,
                                  crossAxisSpacing: 8,
                                  mainAxisSpacing: 8,
                                ),
                                itemCount: seedWords.length,
                                itemBuilder: (context, index) {
                                  return Container(
                                    decoration: BoxDecoration(
                                      color: surfaceDark,
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(color: Colors.white.withValues(alpha: 0.02)),
                                    ),
                                    padding: const EdgeInsets.symmetric(horizontal: 12),
                                    child: Row(
                                      children: [
                                        SizedBox(
                                          width: 20,
                                          child: Text(
                                            (index + 1).toString().padLeft(2, '0'),
                                            style: GoogleFonts.spaceMono(
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                              color: primaryColor.withValues(alpha: 0.5),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            seedWords[index],
                                            style: GoogleFonts.spaceGrotesk(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.white,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  else
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: surfaceDark.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
                      ),
                      child: Text(
                        secret.content,
                        style: GoogleFonts.spaceMono(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                    ),

                  const SizedBox(height: 24),

                  // Warning
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.orange.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.orange.withValues(alpha: 0.2)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          PhosphorIconsBold.warning,
                          color: Colors.orange[500],
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Never share these words with anyone. Anyone with this phrase can access your wallet.',
                            style: GoogleFonts.notoSans(
                              fontSize: 12,
                              color: Colors.orange[200]!.withValues(alpha: 0.8),
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Actions
                  Column(
                    children: [
                      _ActionButton(
                        icon: PhosphorIconsBold.copy,
                        label: 'COPY SEED PHRASE',
                        onTap: () {
                          HapticFeedback.mediumImpact();
                          Clipboard.setData(ClipboardData(text: secret.content));
                          SuccessSnackbar.show(context, message: 'Copied to clipboard');
                        },
                        primaryColor: primaryColor,
                      ),
                      const SizedBox(height: 12),
                      _ActionButton(
                        icon: PhosphorIconsBold.eyeSlash,
                        label: 'HIDE CONTENT',
                        onTap: () => Navigator.pop(context),
                        primaryColor: Colors.grey[600]!,
                        isOutline: true,
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // Verification Badge
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(PhosphorIconsBold.shieldCheck, size: 16, color: primaryColor),
                      const SizedBox(width: 8),
                      Text(
                        'ENCRYPTED & VERIFIED',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[500],
                          letterSpacing: 2.0,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color primaryColor;
  final bool isOutline;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.primaryColor,
    this.isOutline = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isOutline ? Colors.transparent : primaryColor.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isOutline ? primaryColor.withValues(alpha: 0.3) : primaryColor.withValues(alpha: 0.5),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 20, color: isOutline ? primaryColor : primaryColor),
              const SizedBox(width: 12),
              Text(
                label,
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: isOutline ? primaryColor : primaryColor,
                  letterSpacing: 1.0,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
