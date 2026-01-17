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

class SeedPhraseDetailView extends StatefulWidget {
  const SeedPhraseDetailView({super.key});

  @override
  State<SeedPhraseDetailView> createState() => _SeedPhraseDetailViewState();
}

class _SeedPhraseDetailViewState extends State<SeedPhraseDetailView> {
  bool _isVisible = false;

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
                if (mounted) {
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
                  // Information Header Card
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: surfaceDark.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
                    ),
                    child: Column(
                      children: [
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                primaryColor.withValues(alpha: 0.2),
                                primaryColor.withValues(alpha: 0.05),
                              ],
                            ),
                            border: Border.all(color: primaryColor.withValues(alpha: 0.2)),
                          ),
                          child: Icon(
                            secret.type == SecretType.seedPhrase
                                ? PhosphorIconsBold.wallet
                                : PhosphorIconsBold.key,
                            size: 32,
                            color: primaryColor,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          secret.name,
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(PhosphorIconsBold.globe, size: 14, color: Colors.grey[500]),
                            const SizedBox(width: 6),
                            Text(
                              secret.network.toUpperCase(),
                              style: GoogleFonts.spaceMono(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[500],
                                letterSpacing: 1.0,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Container(width: 4, height: 4, decoration: BoxDecoration(color: Colors.grey[700], shape: BoxShape.circle)),
                            const SizedBox(width: 12),
                            Icon(PhosphorIconsBold.calendarBlank, size: 14, color: Colors.grey[500]),
                            const SizedBox(width: 6),
                            Text(
                              formattedDate,
                              style: GoogleFonts.spaceMono(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Seed Grid or Content View with Reveal Toggle
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: _isVisible ? [
                        BoxShadow(
                          color: primaryColor.withValues(alpha: 0.1),
                          blurRadius: 40,
                          spreadRadius: -10,
                        )
                      ] : [],
                    ),
                    child: GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      setState(() => _isVisible = !_isVisible);
                    },
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Content
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: ImageFiltered(
                            imageFilter: ImageFilter.blur(
                              sigmaX: _isVisible ? 0 : 16,
                              sigmaY: _isVisible ? 0 : 16,
                            ),
                            child: secret.type == SecretType.seedPhrase
                                ? Container(
                                    decoration: BoxDecoration(
                                      color: surfaceDark.withValues(alpha: 0.8),
                                      borderRadius: BorderRadius.circular(24),
                                      border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                                    ),
                                    child: GridView.builder(
                                      padding: const EdgeInsets.all(20),
                                      shrinkWrap: true,
                                      physics: const NeverScrollableScrollPhysics(),
                                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 2,
                                        childAspectRatio: 2.8,
                                        crossAxisSpacing: 12,
                                        mainAxisSpacing: 12,
                                      ),
                                      itemCount: seedWords.length,
                                      itemBuilder: (context, index) {
                                        return Container(
                                          decoration: BoxDecoration(
                                            color: Colors.black.withValues(alpha: 0.2),
                                            borderRadius: BorderRadius.circular(12),
                                            border: Border.all(color: Colors.white.withValues(alpha: 0.03)),
                                          ),
                                          padding: const EdgeInsets.symmetric(horizontal: 16),
                                          child: Row(
                                            children: [
                                              Text(
                                                (index + 1).toString(),
                                                style: GoogleFonts.spaceMono(
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.bold,
                                                  color: primaryColor.withValues(alpha: 0.5),
                                                ),
                                              ),
                                              const SizedBox(width: 12),
                                              Expanded(
                                                child: Text(
                                                  _isVisible ? seedWords[index] : '••••••••',
                                                  style: GoogleFonts.spaceGrotesk(
                                                    fontSize: 15,
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
                                  )
                                : Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(32),
                                    decoration: BoxDecoration(
                                      color: surfaceDark.withValues(alpha: 0.8),
                                      borderRadius: BorderRadius.circular(24),
                                      border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                                    ),
                                    child: Text(
                                      _isVisible ? secret.content : '••••••••••••••••••••••••',
                                      style: GoogleFonts.jetBrainsMono(
                                        color: Colors.white,
                                        fontSize: 16,
                                        height: 1.6,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                          ),
                        ),

                        // Overlay Message when Hidden
                        if (!_isVisible)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.5),
                              borderRadius: BorderRadius.circular(30),
                              border: Border.all(color: primaryColor.withValues(alpha: 0.3)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(PhosphorIconsBold.eye, color: primaryColor, size: 18),
                                const SizedBox(width: 12),
                                Text(
                                  'TAP TO REVEAL',
                                  style: GoogleFonts.spaceGrotesk(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: primaryColor,
                                    letterSpacing: 1.0,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                  ),

                  const SizedBox(height: 24),

                  // Warning
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red.withValues(alpha: 0.2)),
                    ),
                    child: Column(
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              PhosphorIconsBold.warningDiamond,
                              color: Color(0xFFff4d4d),
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'STRICT SECURITY PROTOCOL ACTIVE',
                                style: GoogleFonts.spaceGrotesk(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFFff4d4d),
                                  letterSpacing: 1.0,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Copying is disabled to prevent clipboard monitoring. Do not take screenshots. Hand-write this phrase and store it in a physical vault.',
                          style: GoogleFonts.notoSans(
                            fontSize: 12,
                            color: Colors.grey[400],
                            height: 1.5,
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
                        icon: _isVisible ? PhosphorIconsBold.eyeSlash : PhosphorIconsBold.eye,
                        label: _isVisible ? 'HIDE CONTENT' : 'REVEAL CONTENT',
                        onTap: () {
                          HapticFeedback.mediumImpact();
                          setState(() => _isVisible = !_isVisible);
                        },
                        primaryColor: _isVisible ? const Color(0xFFff4d4d) : primaryColor,
                      ),
                      const SizedBox(height: 16),
                      TextButton.icon(
                        onPressed: () => Navigator.pop(context),
                        icon: Icon(PhosphorIconsBold.arrowLeft, size: 16, color: Colors.grey[600]),
                        label: Text(
                          'RETURN TO DASHBOARD',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[600],
                            letterSpacing: 1.2,
                          ),
                        ),
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
                        'AIR-GAPPED STORAGE',
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
