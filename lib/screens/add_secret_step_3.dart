import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../providers/sault_provider.dart';
import '../models/secret_model.dart';
import '../widgets/gradient_background.dart';
import '../widgets/sault_button.dart';
import '../widgets/sault_app_bar.dart';
import '../widgets/error_snackbar.dart';

class AddSecretStep3 extends StatefulWidget {
  const AddSecretStep3({super.key});

  @override
  State<AddSecretStep3> createState() => _AddSecretStep3State();
}

class _AddSecretStep3State extends State<AddSecretStep3> {
  late String _secretName;
  late String _network;
  late String _icon;
  late int _wordCount;
  late List<String> _words;

  bool _initialized = false;
  bool _isSaving = false;

  static const _iconMap = {
    'wallet': PhosphorIconsBold.wallet,
    'key': PhosphorIconsBold.key,
    'shield': PhosphorIconsBold.shield,
    'cube': PhosphorIconsBold.cube,
    'vault': PhosphorIconsBold.lock,
    'database': PhosphorIconsBold.database,
  };

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      final args =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      if (args != null) {
        _secretName = args['name'] ?? 'Unknown';
        _network = args['network'] ?? 'Unknown';
        _icon = args['icon'] ?? 'wallet';
        _wordCount = args['wordCount'] ?? 12;
        _words = List<String>.from(args['words'] ?? []);
      } else {
        _secretName = 'Unknown';
        _network = 'Unknown';
        _icon = 'wallet';
        _wordCount = 12;
        _words = [];
      }
      _initialized = true;
    }
  }

  Future<void> _confirmAndSave() async {
    if (_isSaving) return;

    setState(() {
      _isSaving = true;
    });

    HapticFeedback.mediumImpact();

    final secretContent = _words.join(' ');
    final secret = Secret.create(
      name: _secretName,
      network: _network,
      content: secretContent,
      type: SecretType.seedPhrase,
      typeLabel: 'SEED PHRASE \u2022 $_wordCount WORDS',
      metadata: {'icon': _icon},
    );

    final success =
        await Provider.of<SaultProvider>(context, listen: false).addSecret(secret);

    setState(() {
      _isSaving = false;
    });

    if (mounted) {
      if (success) {
        SuccessSnackbar.show(
          context,
          message: 'Seed phrase saved securely',
        );
        Navigator.pushNamedAndRemoveUntil(
            context, '/dashboard', (route) => false);
      } else {
        ErrorSnackbar.show(
          context,
          message: 'Failed to save seed phrase',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF13b6ec);
    const backgroundDark = Color(0xFF101d22);
    const surfaceDark = Color(0xFF16262c);

    return Scaffold(
      backgroundColor: backgroundDark,
      extendBodyBehindAppBar: true,
      appBar: SaultAppBar(
        title: 'New Sault',
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Step 3/3',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF9db2b9),
                  ),
                ),
              ),
            ),
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
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 8),
                    children: [
                      // Headline
                      Text(
                        'Confirm your seed phrase',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Please review the details below before saving.',
                        style: GoogleFonts.notoSans(
                          fontSize: 16,
                          color: Colors.grey[400],
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Info Card
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: surfaceDark.withValues(alpha: 0.4),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                              color:
                                  Colors.white.withValues(alpha: 0.05)),
                        ),
                        child: Column(
                          children: [
                            // Icon
                            Container(
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    primaryColor.withValues(alpha: 0.2),
                                    primaryColor.withValues(alpha: 0.05),
                                  ],
                                ),
                                border: Border.all(
                                    color: primaryColor
                                        .withValues(alpha: 0.2)),
                              ),
                              child: Icon(
                                _iconMap[_icon] ??
                                    PhosphorIconsBold.wallet,
                                size: 28,
                                color: primaryColor,
                              ),
                            ),
                            const SizedBox(height: 16),
                            // Name
                            Text(
                              _secretName,
                              style: GoogleFonts.spaceGrotesk(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(height: 8),
                            // Network + Word count badges
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(PhosphorIconsBold.globe,
                                    size: 14, color: Colors.grey[500]),
                                const SizedBox(width: 6),
                                Text(
                                  _network.toUpperCase(),
                                  style: GoogleFonts.spaceMono(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey[500],
                                    letterSpacing: 1.0,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Container(
                                  width: 4,
                                  height: 4,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[700],
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Icon(PhosphorIconsBold.listNumbers,
                                    size: 14, color: Colors.grey[500]),
                                const SizedBox(width: 6),
                                Text(
                                  '$_wordCount WORDS',
                                  style: GoogleFonts.spaceMono(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey[500],
                                    letterSpacing: 1.0,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Seed Phrase Grid (read-only)
                      Container(
                        decoration: BoxDecoration(
                          color: surfaceDark.withValues(alpha: 0.8),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color:
                                  Colors.white.withValues(alpha: 0.1)),
                        ),
                        child: GridView.builder(
                          padding: const EdgeInsets.all(16),
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
                              decoration: BoxDecoration(
                                color:
                                    Colors.black.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                    color: Colors.white
                                        .withValues(alpha: 0.03)),
                              ),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16),
                              child: Row(
                                children: [
                                  SizedBox(
                                    width: 24,
                                    child: Text(
                                      '${index + 1}',
                                      style: GoogleFonts.spaceMono(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: primaryColor
                                            .withValues(alpha: 0.5),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      _words[index],
                                      style: GoogleFonts.spaceGrotesk(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  Icon(
                                    PhosphorIconsBold.checkCircle,
                                    size: 14,
                                    color: const Color(0xFF00d68f),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Security Tip
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.orange.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color:
                                Colors.orange.withValues(alpha: 0.2),
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              PhosphorIconsBold.warningDiamond,
                              color: Colors.orange[300],
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Double-check each word carefully. Once saved, the seed phrase will be encrypted and stored securely on this device.',
                                style: GoogleFonts.spaceGrotesk(
                                  fontSize: 13,
                                  color: Colors.white
                                      .withValues(alpha: 0.8),
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),

                // Bottom Actions
                Padding(
                  padding: const EdgeInsets.fromLTRB(32, 16, 32, 16),
                  child: SaultButton(
                    text: _isSaving ? 'SAVING...' : 'CONFIRM & SAVE',
                    onTap: !_isSaving ? _confirmAndSave : null,
                    icon:
                        _isSaving ? null : PhosphorIconsBold.shieldCheck,
                    backgroundColor: primaryColor,
                    textColor: backgroundDark,
                    isLoading: _isSaving,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(32, 0, 32, 40),
                  child: TextButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(PhosphorIconsBold.arrowLeft,
                        size: 16, color: Colors.grey[500]),
                    label: Text(
                      'GO BACK TO EDIT',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[500],
                        letterSpacing: 1.0,
                      ),
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
