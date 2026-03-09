import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../utils/constants.dart';
import '../widgets/add_secret_flow_widgets.dart';
import '../widgets/error_snackbar.dart';
import '../widgets/gradient_background.dart';
import '../widgets/sault_app_bar.dart';
import '../widgets/sault_button.dart';
import '../widgets/sault_text_field.dart';

class AddSecretStep1 extends StatefulWidget {
  const AddSecretStep1({super.key});

  @override
  State<AddSecretStep1> createState() => _AddSecretStep1State();
}

class _AddSecretStep1State extends State<AddSecretStep1> {
  final TextEditingController _nameController = TextEditingController();

  String _selectedNetwork = 'Ethereum';
  int _wordCount = 12;
  String _selectedIcon = 'wallet';

  final List<String> _networks = [
    'Ethereum',
    'Bitcoin',
    'Solana',
    'Polkadot',
    'Cardano',
    'Polygon',
    'Optimism',
    'Arbitrum',
    'Base',
    'Cosmos',
  ];

  final List<Map<String, dynamic>> _icons = [
    {'id': 'wallet', 'label': 'Wallet', 'icon': PhosphorIconsBold.wallet},
    {'id': 'key', 'label': 'Key', 'icon': PhosphorIconsBold.key},
    {'id': 'shield', 'label': 'Shield', 'icon': PhosphorIconsBold.shield},
    {'id': 'cube', 'label': 'Asset', 'icon': PhosphorIconsBold.cube},
    {'id': 'vault', 'label': 'Vault', 'icon': PhosphorIconsBold.lock},
    {'id': 'database', 'label': 'Archive', 'icon': PhosphorIconsBold.database},
  ];

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_nameController.text.trim().isEmpty) {
      ErrorSnackbar.show(context, message: 'Please enter a secret name');
      return;
    }

    Navigator.pushNamed(
      context,
      '/add-secret-2',
      arguments: {
        'name': _nameController.text.trim(),
        'network': _selectedNetwork,
        'wordCount': _wordCount,
        'icon': _selectedIcon,
      },
    );
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
            child: Center(child: AddSecretStepIndicator(step: 1)),
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
                        eyebrow: 'SEED VAULT SETUP',
                        title: 'Create the shell of your new record',
                        description:
                            'Name it clearly, choose its network context, and set the structure before entering the recovery phrase.',
                      ),
                      const SizedBox(height: 24),
                      AddSecretPanel(
                        child: Row(
                          children: [
                            const AddSecretInlineStat(
                              icon: PhosphorIconsBold.globe,
                              label: 'NETWORK',
                              value: 'Chain-aware',
                            ),
                            const SizedBox(width: 12),
                            AddSecretInlineStat(
                              icon: PhosphorIconsBold.listNumbers,
                              label: 'FORMAT',
                              value: '$_wordCount words',
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      AddSecretPanel(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const AddSecretSectionLabel('SECRET NAME'),
                            const SizedBox(height: 12),
                            SaultTextField(
                              controller: _nameController,
                              placeholder: 'e.g. Main cold wallet',
                            ),
                            const SizedBox(height: 24),
                            const AddSecretSectionLabel('NETWORK'),
                            const SizedBox(height: 12),
                            Container(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 18),
                              decoration: BoxDecoration(
                                color: AppColors.backgroundElevated,
                                borderRadius: BorderRadius.circular(22),
                                border: Border.all(
                                    color: AppColors.softBorderColor),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: _selectedNetwork,
                                  isExpanded: true,
                                  dropdownColor: AppColors.backgroundElevated,
                                  icon: const Icon(
                                    PhosphorIconsBold.caretDown,
                                    size: 16,
                                    color: AppColors.textSecondary,
                                  ),
                                  style: GoogleFonts.spaceGrotesk(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary,
                                  ),
                                  items: _networks
                                      .map(
                                        (network) => DropdownMenuItem<String>(
                                          value: network,
                                          child: Text(network),
                                        ),
                                      )
                                      .toList(),
                                  onChanged: (value) {
                                    if (value == null) return;
                                    HapticFeedback.selectionClick();
                                    setState(() => _selectedNetwork = value);
                                  },
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),
                            const AddSecretSectionLabel('VISUAL MARKER'),
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 10,
                              runSpacing: 10,
                              children: _icons.map((item) {
                                final bool isSelected =
                                    _selectedIcon == item['id'];
                                return AddSecretOptionChip(
                                  label: item['label'] as String,
                                  icon: item['icon'] as IconData,
                                  isSelected: isSelected,
                                  onTap: () {
                                    HapticFeedback.selectionClick();
                                    setState(() =>
                                        _selectedIcon = item['id'] as String);
                                  },
                                );
                              }).toList(),
                            ),
                            const SizedBox(height: 24),
                            const AddSecretSectionLabel('SEED PHRASE LENGTH'),
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 10,
                              runSpacing: 10,
                              children: AppConstants.validSeedPhraseCounts
                                  .map((count) {
                                return AddSecretOptionChip(
                                  label: '$count words',
                                  isSelected: _wordCount == count,
                                  onTap: () {
                                    HapticFeedback.selectionClick();
                                    setState(() => _wordCount = count);
                                  },
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),
                      const AddSecretNotice(
                        icon: PhosphorIconsBold.info,
                        text:
                            'This step only defines context and layout. The actual recovery phrase will be entered and reviewed in the next two steps.',
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 10, 24, 18),
                  child: SaultButton(
                    text: 'Continue to seed phrase',
                    icon: PhosphorIconsBold.arrowRight,
                    onTap: _nextStep,
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
