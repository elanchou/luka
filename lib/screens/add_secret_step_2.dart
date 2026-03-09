import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../utils/bip39_english_wordlist.dart';
import '../utils/constants.dart';
import '../utils/validators.dart';
import '../widgets/add_secret_flow_widgets.dart';
import '../widgets/error_snackbar.dart';
import '../widgets/gradient_background.dart';
import '../widgets/sault_app_bar.dart';
import '../widgets/sault_button.dart';
import '../widgets/sault_outline_button.dart';
import '../widgets/seed_word_autocomplete.dart';

class AddSecretStep2 extends StatefulWidget {
  const AddSecretStep2({super.key});

  @override
  State<AddSecretStep2> createState() => _AddSecretStep2State();
}

class _AddSecretStep2State extends State<AddSecretStep2> {
  late String _secretName;
  late String _network;
  late String _icon;

  final List<String> _bip39Words = bip39EnglishWordlist;
  final List<int> _availableWordCounts = AppConstants.validSeedPhraseCounts;

  int _selectedWordCount = 12;
  List<TextEditingController> _controllers = [];
  List<FocusNode> _focusNodes = [];
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;

    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    _secretName = args?['name'] ?? 'Unknown';
    _network = args?['network'] ?? 'Unknown';
    _icon = args?['icon'] ?? 'wallet';

    final int? wordCount = args?['wordCount'] as int?;
    if (wordCount != null && _availableWordCounts.contains(wordCount)) {
      _selectedWordCount = wordCount;
    }

    _initializeInputs();
    _initialized = true;
  }

  void _initializeInputs() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    for (final node in _focusNodes) {
      node.dispose();
    }

    _controllers =
        List.generate(_selectedWordCount, (_) => TextEditingController());
    _focusNodes = List.generate(_selectedWordCount, (_) => FocusNode());

    for (int i = 0; i < _selectedWordCount; i++) {
      final int index = i;
      _focusNodes[i].addListener(() {
        if (_focusNodes[index].hasFocus) {
          setState(() {});
        }
      });
    }
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    for (final node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _focusNext(int currentIndex) {
    if (currentIndex < _selectedWordCount - 1) {
      _focusNodes[currentIndex + 1].requestFocus();
    } else {
      _focusNodes[currentIndex].unfocus();
    }
  }

  void _changeWordCount(int newCount) {
    setState(() {
      _selectedWordCount = newCount;
      _initializeInputs();
    });
  }

  int _getValidWordCount() {
    return _controllers.where((controller) {
      final String word = controller.text.trim().toLowerCase();
      return word.isNotEmpty && _bip39Words.contains(word);
    }).length;
  }

  Future<void> _pasteFromClipboard() async {
    final clipboardData = await Clipboard.getData(Clipboard.kTextPlain);
    final String rawText = clipboardData?.text?.trim() ?? '';

    if (rawText.isEmpty) {
      if (mounted) {
        ErrorSnackbar.show(context, message: 'Clipboard is empty');
      }
      return;
    }

    final List<String> words = rawText
        .split(RegExp(r'\s+'))
        .map((word) => word.toLowerCase().trim())
        .where((word) => word.isNotEmpty)
        .toList();

    if (words.isEmpty) {
      if (mounted) {
        ErrorSnackbar.show(context,
            message: 'No valid words found in clipboard');
      }
      return;
    }

    if (_availableWordCounts.contains(words.length) &&
        words.length != _selectedWordCount) {
      setState(() {
        _selectedWordCount = words.length;
        _initializeInputs();
      });
    }

    final int fillCount =
        words.length < _selectedWordCount ? words.length : _selectedWordCount;
    for (int i = 0; i < fillCount; i++) {
      _controllers[i].text = words[i];
    }

    setState(() {});

    if (mounted) {
      SuccessSnackbar.show(context, message: '$fillCount words pasted');
    }
  }

  void _clearAll() {
    for (final controller in _controllers) {
      controller.clear();
    }
    setState(() {});
  }

  void _proceedToConfirm() {
    final List<String> words = _controllers
        .map((controller) => controller.text.trim().toLowerCase())
        .toList();

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

  @override
  Widget build(BuildContext context) {
    final int validCount = _getValidWordCount();
    final double progress = validCount / _selectedWordCount;

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      extendBodyBehindAppBar: true,
      appBar: const SaultAppBar(
        title: 'New Sault',
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 20),
            child: Center(child: AddSecretStepIndicator(step: 2)),
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
                        eyebrow: 'SEED PHRASE ENTRY',
                        title: 'Enter each recovery word carefully',
                        description:
                            'Use autocomplete, paste from a trusted source, or type manually. We validate the phrase before it moves to final review.',
                      ),
                      const SizedBox(height: 24),
                      AddSecretPanel(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                AddSecretInlineStat(
                                  icon: PhosphorIconsBold.identificationCard,
                                  label: 'RECORD',
                                  value: _secretName,
                                ),
                                const SizedBox(width: 12),
                                AddSecretInlineStat(
                                  icon: PhosphorIconsBold.globe,
                                  label: 'NETWORK',
                                  value: _network,
                                ),
                              ],
                            ),
                            const SizedBox(height: 18),
                            const AddSecretSectionLabel('WORD COUNT'),
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 10,
                              runSpacing: 10,
                              children: _availableWordCounts.map((count) {
                                return AddSecretOptionChip(
                                  label: '$count words',
                                  isSelected: count == _selectedWordCount,
                                  onTap: () => _changeWordCount(count),
                                );
                              }).toList(),
                            ),
                            const SizedBox(height: 18),
                            const AddSecretSectionLabel('PROGRESS'),
                            const SizedBox(height: 10),
                            Text(
                              '$validCount of $_selectedWordCount words are currently valid',
                              style: GoogleFonts.notoSans(
                                fontSize: 13,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 10),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(999),
                              child: LinearProgressIndicator(
                                value: progress,
                                minHeight: 8,
                                backgroundColor:
                                    Colors.white.withValues(alpha: 0.06),
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  validCount == _selectedWordCount
                                      ? AppColors.successColor
                                      : AppColors.primaryColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: SaultOutlineButton(
                              text: 'Paste words',
                              icon: PhosphorIconsBold.clipboard,
                              onTap: _pasteFromClipboard,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: SaultOutlineButton(
                              text: 'Clear all',
                              icon: PhosphorIconsBold.eraser,
                              onTap: _clearAll,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      AddSecretPanel(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
                        child: GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 14,
                            childAspectRatio: 2.95,
                          ),
                          itemCount: _selectedWordCount,
                          itemBuilder: (context, index) {
                            return SeedWordAutocomplete(
                              controller: _controllers[index],
                              focusNode: _focusNodes[index],
                              wordList: _bip39Words,
                              wordNumber: index + 1,
                              onSubmitted: () => _focusNext(index),
                              onChanged: () => setState(() {}),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 18),
                      const AddSecretNotice(
                        icon: PhosphorIconsBold.lightbulb,
                        text:
                            'Only use recovery phrases you trust and control. Autocomplete is local and based on the BIP39 English word list.',
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 10, 24, 18),
                  child: SaultButton(
                    text: 'Review and confirm',
                    icon: PhosphorIconsBold.arrowRight,
                    onTap: _proceedToConfirm,
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
