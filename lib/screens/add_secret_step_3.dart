import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';

import '../models/secret_model.dart';
import '../providers/sault_provider.dart';
import '../utils/constants.dart';
import '../widgets/add_secret_flow_widgets.dart';
import '../widgets/error_snackbar.dart';
import '../widgets/gradient_background.dart';
import '../widgets/sault_app_bar.dart';
import '../widgets/sault_button.dart';
import '../widgets/sault_outline_button.dart';

class AddSecretStep3 extends StatefulWidget {
  const AddSecretStep3({super.key});

  @override
  State<AddSecretStep3> createState() => _AddSecretStep3State();
}

class _AddSecretStep3State extends State<AddSecretStep3> {
  static const Map<String, IconData> _iconMap = {
    'wallet': PhosphorIconsBold.wallet,
    'key': PhosphorIconsBold.key,
    'shield': PhosphorIconsBold.shield,
    'cube': PhosphorIconsBold.cube,
    'vault': PhosphorIconsBold.lock,
    'database': PhosphorIconsBold.database,
  };

  late String _secretName;
  late String _network;
  late String _icon;
  late int _wordCount;
  late List<String> _words;

  bool _initialized = false;
  bool _isSaving = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;

    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    _secretName = args?['name'] ?? 'Unknown';
    _network = args?['network'] ?? 'Unknown';
    _icon = args?['icon'] ?? 'wallet';
    _wordCount = args?['wordCount'] ?? 12;
    _words = List<String>.from(args?['words'] ?? <String>[]);

    _initialized = true;
  }

  Future<void> _confirmAndSave() async {
    if (_isSaving) return;

    setState(() => _isSaving = true);
    HapticFeedback.mediumImpact();

    final Secret secret = Secret.create(
      name: _secretName,
      network: _network,
      content: _words.join(' '),
      type: SecretType.seedPhrase,
      typeLabel: 'SEED PHRASE • $_wordCount WORDS',
      metadata: {'icon': _icon},
    );

    final bool success =
        await Provider.of<SaultProvider>(context, listen: false)
            .addSecret(secret);

    if (!mounted) return;

    setState(() => _isSaving = false);

    if (success) {
      SuccessSnackbar.show(context, message: 'Seed phrase saved securely');
      Navigator.pushNamedAndRemoveUntil(
          context, '/dashboard', (route) => false);
      return;
    }

    ErrorSnackbar.show(context, message: 'Failed to save seed phrase');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      extendBodyBehindAppBar: true,
      appBar: const SaultAppBar(
        title: 'New Sault',
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 20),
            child: Center(child: AddSecretStepIndicator(step: 3)),
          ),
        ],
      ),
      body: Stack(
        children: [
          const GradientBackground(),
          SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
                    children: [
                      const AddSecretHero(
                        eyebrow: 'FINAL REVIEW',
                        title: 'Confirm every detail before saving',
                        description:
                            'This is the last checkpoint before the phrase is encrypted and written into your local vault.',
                      ),
                      const SizedBox(height: 24),
                      AddSecretPanel(
                        child: Column(
                          children: [
                            Container(
                              width: 62,
                              height: 62,
                              decoration: BoxDecoration(
                                color: AppColors.primaryColor
                                    .withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(22),
                                border: Border.all(
                                  color: AppColors.primaryColor
                                      .withValues(alpha: 0.28),
                                ),
                              ),
                              child: Icon(
                                _iconMap[_icon] ?? PhosphorIconsBold.wallet,
                                size: 28,
                                color: AppColors.primaryColor,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _secretName,
                              style: GoogleFonts.spaceGrotesk(
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                                letterSpacing: -0.5,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                AddSecretInlineStat(
                                  icon: PhosphorIconsBold.globe,
                                  label: 'NETWORK',
                                  value: _network,
                                ),
                                const SizedBox(width: 12),
                                AddSecretInlineStat(
                                  icon: PhosphorIconsBold.listNumbers,
                                  label: 'LENGTH',
                                  value: '$_wordCount words',
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),
                      AddSecretPanel(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                        child: GridView.builder(
                          padding: EdgeInsets.zero,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 2.8,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                          ),
                          itemCount: _words.length,
                          itemBuilder: (context, index) {
                            return Container(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 14),
                              decoration: BoxDecoration(
                                color: AppColors.backgroundElevated,
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(
                                    color: AppColors.softBorderColor),
                              ),
                              child: Row(
                                children: [
                                  SizedBox(
                                    width: 22,
                                    child: Text(
                                      '${index + 1}',
                                      style: GoogleFonts.spaceMono(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.primaryColor
                                            .withValues(alpha: 0.7),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      _words[index],
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.spaceGrotesk(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  const Icon(
                                    PhosphorIconsBold.checkCircle,
                                    size: 16,
                                    color: AppColors.successColor,
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 18),
                      const AddSecretNotice(
                        icon: PhosphorIconsBold.warningDiamond,
                        accentColor: AppColors.warningColor,
                        text:
                            'After saving, this phrase will be encrypted and stored locally. Review every word carefully before continuing.',
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 10, 24, 10),
                  child: SaultButton(
                    text: _isSaving ? 'Saving securely' : 'Confirm and save',
                    icon: _isSaving ? null : PhosphorIconsBold.shieldCheck,
                    onTap: _isSaving ? null : _confirmAndSave,
                    isLoading: _isSaving,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 18),
                  child: SaultOutlineButton(
                    text: 'Back to edit words',
                    icon: PhosphorIconsBold.arrowLeft,
                    onTap: () => Navigator.pop(context),
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
