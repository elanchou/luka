import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import '../models/secret_model.dart';
import '../providers/sault_provider.dart';
import '../utils/constants.dart';
import '../widgets/gradient_background.dart';
import '../widgets/sault_app_bar.dart';
import '../widgets/sault_brand.dart';

class SeedPhraseDetailView extends StatefulWidget {
  const SeedPhraseDetailView({super.key});

  @override
  State<SeedPhraseDetailView> createState() => _SeedPhraseDetailViewState();
}

class _SeedPhraseDetailViewState extends State<SeedPhraseDetailView> {
  bool _isVisible = false;

  @override
  Widget build(BuildContext context) {
    final Secret secret = ModalRoute.of(context)!.settings.arguments as Secret;
    final List<String> seedWords =
        secret.type == SecretType.seedPhrase ? secret.content.split(' ') : <String>[secret.content];
    final String formattedDate = DateFormat('MMM d, yyyy').format(secret.createdAt);

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      extendBodyBehindAppBar: true,
      appBar: SaultAppBar(
        titleWidget: const SaultBrand(fontSize: 14),
        actions: [
          IconButton(
            icon: const Icon(
              PhosphorIconsBold.trash,
              size: 20,
              color: AppColors.textMuted,
            ),
            onPressed: () async {
              final bool? confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text(
                    'Delete secret?',
                    style: GoogleFonts.spaceGrotesk(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  content: Text(
                    'This action cannot be undone.',
                    style: GoogleFonts.notoSans(color: AppColors.textSecondary),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: Text(
                        'Cancel',
                        style: GoogleFonts.spaceGrotesk(color: AppColors.textSecondary),
                      ),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: Text(
                        'Delete',
                        style: GoogleFonts.spaceGrotesk(color: AppColors.dangerColor),
                      ),
                    ),
                  ],
                ),
              );

              if (confirm == true && mounted) {
                await Provider.of<SaultProvider>(context, listen: false).deleteSecret(secret.id);
                if (mounted) {
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
            child: ListView(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.045),
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(color: AppColors.softBorderColor),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: AppColors.primaryColor.withValues(alpha: 0.10),
                          border: Border.all(
                            color: AppColors.primaryColor.withValues(alpha: 0.22),
                          ),
                        ),
                        child: Icon(
                          secret.type == SecretType.seedPhrase
                              ? PhosphorIconsBold.wallet
                              : PhosphorIconsBold.lockKey,
                          color: AppColors.primaryColor,
                          size: 26,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        secret.name,
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 30,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                          letterSpacing: -1.0,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: [
                          _MetaPill(
                            icon: PhosphorIconsBold.globe,
                            label: secret.network.isEmpty ? 'Private vault' : secret.network,
                          ),
                          _MetaPill(
                            icon: PhosphorIconsBold.calendarBlank,
                            label: formattedDate,
                          ),
                          _MetaPill(
                            icon: PhosphorIconsBold.fingerprint,
                            label: secret.typeLabel,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Protected Content',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 10),
                GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    setState(() => _isVisible = !_isVisible);
                  },
                  child: Container(
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      color: AppColors.backgroundElevated,
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(color: AppColors.softBorderColor),
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        ImageFiltered(
                          imageFilter: ImageFilter.blur(
                            sigmaX: _isVisible ? 0 : 14,
                            sigmaY: _isVisible ? 0 : 14,
                          ),
                          child: secret.type == SecretType.seedPhrase
                              ? GridView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    crossAxisSpacing: 12,
                                    mainAxisSpacing: 12,
                                    childAspectRatio: 2.9,
                                  ),
                                  itemCount: seedWords.length,
                                  itemBuilder: (context, index) {
                                    return Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 14),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withValues(alpha: 0.03),
                                        borderRadius: BorderRadius.circular(18),
                                        border: Border.all(color: AppColors.softBorderColor),
                                      ),
                                      child: Row(
                                        children: [
                                          Text(
                                            '${index + 1}',
                                            style: GoogleFonts.spaceGrotesk(
                                              color: AppColors.primaryColor,
                                              fontSize: 11,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Text(
                                              _isVisible ? seedWords[index] : '••••••••',
                                              overflow: TextOverflow.ellipsis,
                                              style: GoogleFonts.spaceGrotesk(
                                                color: AppColors.textPrimary,
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                )
                              : Text(
                                  _isVisible ? secret.content : '••••••••••••••••••••••••',
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.jetBrainsMono(
                                    color: AppColors.textPrimary,
                                    fontSize: 16,
                                    height: 1.6,
                                  ),
                                ),
                        ),
                        if (!_isVisible)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.38),
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color: AppColors.primaryColor.withValues(alpha: 0.20),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  PhosphorIconsBold.eye,
                                  color: AppColors.primaryColor,
                                  size: 16,
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  'Tap to reveal',
                                  style: GoogleFonts.spaceGrotesk(
                                    color: AppColors.textPrimary,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.dangerColor.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColors.dangerColor.withValues(alpha: 0.16),
                    ),
                  ),
                  child: Text(
                    'Avoid screenshots, clipboard copies, and cloud notes. Store this information only in locations you fully control.',
                    style: GoogleFonts.notoSans(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                      height: 1.6,
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                FilledButton(
                  onPressed: () {
                    HapticFeedback.mediumImpact();
                    setState(() => _isVisible = !_isVisible);
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: _isVisible ? AppColors.surfaceHighlight : AppColors.primaryColor,
                    foregroundColor: _isVisible ? AppColors.textPrimary : AppColors.backgroundDark,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(22),
                    ),
                  ),
                  child: Text(
                    _isVisible ? 'Hide Content' : 'Reveal Content',
                    style: GoogleFonts.spaceGrotesk(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
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

class _MetaPill extends StatelessWidget {
  final IconData icon;
  final String label;

  const _MetaPill({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.softBorderColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.primaryColor),
          const SizedBox(width: 8),
          Text(
            label,
            style: GoogleFonts.notoSans(
              color: AppColors.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
