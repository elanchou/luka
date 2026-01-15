import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui';
import 'package:intl/intl.dart';
import '../models/secret_model.dart';
import 'package:provider/provider.dart';
import '../providers/vault_provider.dart';
import '../widgets/gradient_background.dart';
import '../widgets/vault_app_bar.dart';

class SeedPhraseDetailView extends StatelessWidget {
  const SeedPhraseDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF13b6ec);
    const backgroundDark = Color(0xFF101d22);
    const surfaceDark = Color(0xFF16262c);
    const surfaceHighlight = Color(0xFF1f363d);

    final secret = ModalRoute.of(context)!.settings.arguments as Secret;

    // Decrypting logic is handled by implicit access to .content which is stored as plain string in memory
    // but in a real app, Secret.content should be encrypted in memory and decrypted only when viewing.
    // Our Secret model currently holds the content. We assume it's decrypted for display here.
    // If we were following strict security, we'd use a service to decrypt it now.

    List<String> seedWords = [];
    if (secret.type == SecretType.seedPhrase) {
      seedWords = secret.content.split(' ');
    } else {
      // Handle other types or display content as single block
      seedWords = [secret.content];
    }

    final formattedDate = DateFormat('MMM d, yyyy').format(secret.createdAt);

    return Scaffold(
      backgroundColor: backgroundDark,
      extendBodyBehindAppBar: true,
      appBar: VaultAppBar(
        titleWidget: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.lock, size: 14, color: primaryColor),
            const SizedBox(width: 6),
            Text(
              'SECURE VAULT',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 12, // Increased slightly from 10
                fontWeight: FontWeight.bold,
                color: Colors.grey[500],
                letterSpacing: 1.5,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline, size: 24),
            color: Colors.white.withOpacity(0.5),
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  backgroundColor: surfaceDark,
                  title: const Text('Delete Secret?'),
                  content: const Text('This action cannot be undone.'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      style: TextButton.styleFrom(foregroundColor: Colors.red),
                      child: const Text('Delete'),
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
          // Background Ambience
          const GradientBackground(),

          SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
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
                            border: Border.all(color: Colors.white.withOpacity(0.1)),
                          ),
                          child: Icon(
                            secret.type == SecretType.seedPhrase
                                ? Icons.account_balance_wallet_outlined
                                : Icons.vpn_key_outlined,
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
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: BackdropFilter(
                                filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: surfaceDark.withOpacity(0.6),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: Colors.white.withOpacity(0.05)),
                                  ),
                                  child: Column(
                                    children: [
                                      // Top Gradient Line
                                      Container(
                                        height: 1,
                                        width: double.infinity,
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [
                                              Colors.transparent,
                                              primaryColor.withOpacity(0.5),
                                              Colors.transparent,
                                            ],
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: GridView.builder(
                                          padding: const EdgeInsets.all(12),
                                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                            crossAxisCount: 2,
                                            childAspectRatio: 3.5,
                                            crossAxisSpacing: 8,
                                            mainAxisSpacing: 8,
                                          ),
                                          itemCount: seedWords.length,
                                          itemBuilder: (context, index) {
                                            return Container(
                                              decoration: BoxDecoration(
                                                color: surfaceDark,
                                                borderRadius: BorderRadius.circular(4),
                                              ),
                                              padding: const EdgeInsets.symmetric(horizontal: 16),
                                              child: Row(
                                                children: [
                                                  Text(
                                                    (index + 1).toString().padLeft(2, '0'),
                                                    style: GoogleFonts.spaceMono(
                                                      fontSize: 10,
                                                      fontWeight: FontWeight.bold,
                                                      color: primaryColor.withOpacity(0.7),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 12),
                                                  Expanded(
                                                    child: Text(
                                                      seedWords[index],
                                                      style: GoogleFonts.spaceGrotesk(
                                                        fontSize: 14, // Slightly smaller to fit
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
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          )
                        else
                          // Display non-seed content
                          Expanded(
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: surfaceDark.withOpacity(0.6),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.white.withOpacity(0.05)),
                              ),
                              child: Text(
                                secret.content,
                                style: GoogleFonts.spaceMono(
                                  color: Colors.white,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),

                        const SizedBox(height: 24),

                        // Warning
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.orange.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.orange.withOpacity(0.2)),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.warning_amber_rounded,
                                color: Colors.orange[500],
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Never share these words with anyone. Anyone with this phrase can access your wallet.',
                                  style: GoogleFonts.notoSans(
                                    fontSize: 12,
                                    color: Colors.orange[200]!.withOpacity(0.8),
                                    height: 1.4,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Bottom Actions
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.face, size: 16, color: Colors.grey),
                            const SizedBox(width: 8),
                            Text(
                              'FACE ID VERIFIED',
                              style: GoogleFonts.spaceGrotesk(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey,
                                letterSpacing: 1.0,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Hold to Hide Button
                        Container(
                          height: 56,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: surfaceDark,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: primaryColor.withOpacity(0.3)),
                          ),
                          child: Stack(
                            children: [
                              Positioned.fill(
                                child: Container(
                                  color: primaryColor.withOpacity(0.1),
                                ),
                              ),
                              Center(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(
                                      Icons.visibility_off_outlined,
                                      color: primaryColor,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'HOLD TO HIDE',
                                      style: GoogleFonts.spaceGrotesk(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: primaryColor,
                                        letterSpacing: 1.5,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'SESSION EXPIRES IN 28S',
                          style: GoogleFonts.spaceMono(
                            fontSize: 10,
                            color: Colors.grey[600],
                            letterSpacing: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
