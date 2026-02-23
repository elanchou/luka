import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:bip39/src/wordlists/english.dart';
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
  late String _icon;

  // Get BIP39 word list (2048 words)
  final List<String> _bip39Words = WORDLIST;

  // Available word counts
  final List<int> _availableWordCounts = [12, 15, 18, 21, 24];
  int _selectedWordCount = 12;

  List<TextEditingController> _controllers = [];
  List<FocusNode> _focusNodes = [];

  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      if (args != null) {
        _secretName = args['name'] ?? 'Unknown';
        _network = args['network'] ?? 'Unknown';
        _icon = args['icon'] ?? 'wallet';
        final wordCount = args['wordCount'] as int?;
        if (wordCount != null && _availableWordCounts.contains(wordCount)) {
          _selectedWordCount = wordCount;
        }
      } else {
        _secretName = 'Unknown';
        _network = 'Unknown';
        _icon = 'wallet';
      }
      _initializeInputs();
      _initialized = true;
    }
  }

  @override
  void initState() {
    super.initState();
  }

  void _initializeInputs() {
    // Dispose existing controllers and focus nodes
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }

    // Create new controllers and focus nodes
    _controllers = List.generate(
      _selectedWordCount,
      (index) => TextEditingController(),
    );

    _focusNodes = List.generate(
      _selectedWordCount,
      (index) => FocusNode(),
    );

    // Set focus listeners
    for (int i = 0; i < _selectedWordCount; i++) {
      final index = i; // Capture for closure
      _focusNodes[i].addListener(() {
        if (_focusNodes[index].hasFocus) {
          setState(() {});
        }
      });
    }
  }

  void _changeWordCount(int newCount) {
    setState(() {
      _selectedWordCount = newCount;
      _initializeInputs();
    });
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
    if (currentIndex < _selectedWordCount - 1) {
      _focusNodes[currentIndex + 1].requestFocus();
    } else {
      // Last word - unfocus to hide keyboard
      _focusNodes[currentIndex].unfocus();
    }
  }

  void _proceedToConfirm() {
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
      return;
    }

    // Navigate to Step 3 for confirmation
    Navigator.pushNamed(
      context,
      '/add-secret-3',
      arguments: {
        'name': _secretName,
        'network': _network,
        'icon': _icon,
        'wordCount': _selectedWordCount,
        'words': words,
      },
    );
  }

  Future<void> _pasteFromClipboard() async {
    final clipboardData = await Clipboard.getData(Clipboard.kTextPlain);
    if (clipboardData == null || clipboardData.text == null || clipboardData.text!.trim().isEmpty) {
      if (mounted) {
        ErrorSnackbar.show(context, message: 'Clipboard is empty');
      }
      return;
    }

    final words = clipboardData.text!.trim().split(RegExp(r'\s+'));
    final cleanWords = words.map((w) => w.toLowerCase().trim()).where((w) => w.isNotEmpty).toList();

    if (cleanWords.isEmpty) {
      if (mounted) {
        ErrorSnackbar.show(context, message: 'No valid words found in clipboard');
      }
      return;
    }

    // Auto-switch word count if pasted count matches an available option
    if (_availableWordCounts.contains(cleanWords.length) && cleanWords.length != _selectedWordCount) {
      setState(() {
        _selectedWordCount = cleanWords.length;
        _initializeInputs();
      });
    }

    // Fill controllers
    final fillCount = cleanWords.length < _selectedWordCount ? cleanWords.length : _selectedWordCount;
    for (int i = 0; i < fillCount; i++) {
      _controllers[i].text = cleanWords[i];
    }

    setState(() {});

    if (mounted) {
      SuccessSnackbar.show(context, message: '$fillCount words pasted');
    }
  }

  void _clearAll() {
    for (var controller in _controllers) {
      controller.clear();
    }
    setState(() {});
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
                  color: Colors.white.withValues(alpha: 0.05),
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
                        'Enter your seed phrase',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Start typing and select from suggestions. Choose your preferred word count below.',
                        style: GoogleFonts.notoSans(
                          fontSize: 16,
                          color: Colors.grey[400],
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Word Count Selector
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.03),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.1),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  PhosphorIconsBold.listNumbers,
                                  color: primaryColor,
                                  size: 20,
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  'Word Count',
                                  style: GoogleFonts.spaceGrotesk(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: _availableWordCounts.map((count) {
                                final isSelected = count == _selectedWordCount;
                                return GestureDetector(
                                  onTap: () => _changeWordCount(count),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? primaryColor
                                          : Colors.white.withValues(alpha: 0.05),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: isSelected
                                            ? primaryColor
                                            : Colors.white.withValues(alpha: 0.1),
                                      ),
                                    ),
                                    child: Text(
                                      '$count',
                                      style: GoogleFonts.spaceGrotesk(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: isSelected
                                            ? backgroundDark
                                            : Colors.white.withValues(alpha: 0.7),
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Progress Indicator
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.03),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.1),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              PhosphorIconsBold.listChecks,
                              color: primaryColor,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Progress: $validCount/$_selectedWordCount valid words',
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
                                      value: validCount / _selectedWordCount,
                                      backgroundColor: Colors.white.withValues(alpha: 0.1),
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        validCount == _selectedWordCount
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
                      // Paste / Clear row
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: _pasteFromClipboard,
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.03),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.1),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      PhosphorIconsBold.clipboard,
                                      color: primaryColor,
                                      size: 16,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'PASTE',
                                      style: GoogleFonts.spaceGrotesk(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: primaryColor,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: GestureDetector(
                              onTap: _clearAll,
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.03),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.1),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      PhosphorIconsBold.eraser,
                                      color: Colors.white.withValues(alpha: 0.5),
                                      size: 16,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'CLEAR',
                                      style: GoogleFonts.spaceGrotesk(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white.withValues(alpha: 0.5),
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
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
                        itemCount: _selectedWordCount,
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
                          color: primaryColor.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: primaryColor.withValues(alpha: 0.2),
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              PhosphorIconsBold.lightbulb,
                              color: primaryColor,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Tip: Words are auto-suggested as you type. Select from the dropdown to quickly fill in each word.',
                                style: GoogleFonts.spaceGrotesk(
                                  fontSize: 13,
                                  color: Colors.white.withValues(alpha: 0.8),
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

                // Action Button
                Padding(
                  padding: const EdgeInsets.fromLTRB(32, 16, 32, 16),
                  child: VaultButton(
                    text: 'REVIEW',
                    onTap: validCount == _selectedWordCount ? _proceedToConfirm : null,
                    icon: PhosphorIconsBold.arrowRight,
                    backgroundColor: primaryColor,
                    textColor: backgroundDark,
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
