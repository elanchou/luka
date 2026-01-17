import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:bip39/src/wordlists/english.dart';
import '../providers/vault_provider.dart';
import '../models/secret_model.dart';
import '../widgets/gradient_background.dart';
import '../widgets/vault_button.dart';
import '../widgets/vault_app_bar.dart';
import '../widgets/seed_word_autocomplete.dart';
import '../widgets/error_snackbar.dart';
import '../utils/validators.dart';

class AddSecretStep2 extends StatefulWidget {
  const AddSecretStep2({super.key});

  @override
  State<AddSecretStep2> createState() => _AddSecretStep2State();
}

class _AddSecretStep2State extends State<AddSecretStep2> {
  late String _secretName;
  late String _network;

  // Get BIP39 word list (2048 words)
  final List<String> _bip39Words = WORDLIST;

  final List<TextEditingController> _controllers = List.generate(
    12,
    (index) => TextEditingController(),
  );

  final List<FocusNode> _focusNodes = List.generate(
    12,
    (index) => FocusNode(),
  );

  int _currentIndex = 0;
  bool _initialized = false;
  bool _isVerifying = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      if (args != null) {
        _secretName = args['name'] ?? 'Unknown';
        _network = args['network'] ?? 'Unknown';
      }
      _initialized = true;
    }
  }

  @override
  void initState() {
    super.initState();

    // Set focus listeners
    for (int i = 0; i < 12; i++) {
      _focusNodes[i].addListener(() {
        if (_focusNodes[i].hasFocus) {
          setState(() {
            _currentIndex = i;
          });
        }
      });
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _focusNext(int currentIndex) {
    if (currentIndex < 11) {
      _focusNodes[currentIndex + 1].requestFocus();
    } else {
      // Last word - unfocus to hide keyboard
      _focusNodes[currentIndex].unfocus();
    }
  }

  void _verifyPhrase() async {
    if (_isVerifying) return;

    setState(() {
      _isVerifying = true;
    });

    // Collect all words
    final words = _controllers.map((c) => c.text.trim().toLowerCase()).toList();

    // Use validator
    final validationResult = Validators.validateSeedPhrase(words, _bip39Words);

    if (!validationResult.isValid) {
      if (mounted) {
        ErrorSnackbar.show(
          context,
          message: validationResult.error!,
          duration: const Duration(seconds: 5),
        );
      }
      setState(() {
        _isVerifying = false;
      });
      return;
    }

    // Create Secret
    final secretContent = words.join(' ');
    final secret = Secret.create(
      name: _secretName,
      network: _network,
      content: secretContent,
      type: SecretType.seedPhrase,
      typeLabel: 'SEED PHRASE • 12 WORDS',
    );

    // Save using Provider
    final success = await Provider.of<VaultProvider>(context, listen: false).addSecret(secret);

    setState(() {
      _isVerifying = false;
    });

    if (mounted) {
      if (success) {
        SuccessSnackbar.show(
          context,
          message: 'Seed phrase saved securely',
        );
        Navigator.pushNamedAndRemoveUntil(context, '/dashboard', (route) => false);
      } else {
        ErrorSnackbar.show(
          context,
          message: 'Failed to save seed phrase',
        );
      }
    }
  }

  int _getFilledWordCount() {
    return _controllers.where((c) => c.text.trim().isNotEmpty).length;
  }

  int _getValidWordCount() {
    return _controllers.where((c) {
      final word = c.text.trim().toLowerCase();
      return word.isNotEmpty && _bip39Words.contains(word);
    }).length;
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF13b6ec);
    const backgroundDark = Color(0xFF101d22);
    final filledCount = _getFilledWordCount();
    final validCount = _getValidWordCount();

    return Scaffold(
      backgroundColor: backgroundDark,
      extendBodyBehindAppBar: true,
      appBar: VaultAppBar(
        title: 'New Vault',
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Step 2/3',
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
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    children: [
                      // Headline
                      Text(
                        'Secure your phrase',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Enter your 12-word recovery phrase. Start typing and select from suggestions.',
                        style: GoogleFonts.notoSans(
                          fontSize: 16,
                          color: Colors.grey[400],
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Progress Indicator
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.03),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.1),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.checklist_rounded,
                              color: primaryColor,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Progress: $validCount/12 valid words',
                                    style: GoogleFonts.spaceGrotesk(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(4),
                                    child: LinearProgressIndicator(
                                      value: validCount / 12,
                                      backgroundColor: Colors.white.withOpacity(0.1),
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        validCount == 12 
                                            ? const Color(0xFF00d68f)
                                            : primaryColor,
                                      ),
                                      minHeight: 6,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Grid of Input Cells with Autocomplete
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 16,
                          childAspectRatio: 3.5,
                        ),
                        itemCount: 12,
                        itemBuilder: (context, index) {
                          return SeedWordAutocomplete(
                            controller: _controllers[index],
                            focusNode: _focusNodes[index],
                            wordList: _bip39Words,
                            wordNumber: index + 1,
                            onSubmitted: () => _focusNext(index),
                            onChanged: () {
                              setState(() {});
                            },
                          );
                        },
                      ),
                      const SizedBox(height: 24),

                      // Helpful Tip
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: primaryColor.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: primaryColor.withOpacity(0.2),
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.lightbulb_outline,
                              color: primaryColor,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Tip: Words are auto-suggested as you type. Select from the dropdown to quickly fill in each word.',
                                style: GoogleFonts.spaceGrotesk(
                                  fontSize: 13,
                                  color: Colors.white.withOpacity(0.8),
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

                // Bottom Action
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: backgroundDark.withOpacity(0.95),
                    border: Border(
                      top: BorderSide(
                        color: Colors.white.withOpacity(0.05),
                      ),
                    ),
                  ),
                  child: SafeArea(
                    top: false,
                    child: VaultButton(
                      text: _isVerifying ? 'Verifying...' : 'Verify & Save',
                      onTap: validCount == 12 && !_isVerifying 
                          ? _verifyPhrase 
                          : null,
                      icon: _isVerifying 
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Icon(Icons.verified_user, size: 20),
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
