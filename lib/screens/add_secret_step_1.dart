import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../widgets/gradient_background.dart';
import '../widgets/vault_button.dart';
import '../widgets/vault_text_field.dart';
import '../widgets/vault_app_bar.dart';

import '../widgets/error_snackbar.dart';

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
    {'id': 'wallet', 'icon': PhosphorIconsBold.wallet},
    {'id': 'key', 'icon': PhosphorIconsBold.key},
    {'id': 'shield', 'icon': PhosphorIconsBold.shield},
    {'id': 'cube', 'icon': PhosphorIconsBold.cube},
    {'id': 'vault', 'icon': PhosphorIconsBold.lock},
    {'id': 'database', 'icon': PhosphorIconsBold.database},
  ];

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_nameController.text.isNotEmpty) {
      Navigator.pushNamed(
        context,
        '/add-secret-2',
        arguments: {
          'name': _nameController.text,
          'network': _selectedNetwork,
          'wordCount': _wordCount,
          'icon': _selectedIcon,
        },
      );
    } else {
      ErrorSnackbar.show(context, message: 'Please enter a secret name');
    }
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF13b6ec);
    const backgroundDark = Color(0xFF101d22);
    const labelColor = Color(0xFF5f747a);
    const surfaceColor = Color(0xFF1a2c32);

    return Scaffold(
      backgroundColor: backgroundDark,
      extendBodyBehindAppBar: true,
      appBar: const VaultAppBar(title: 'Add Secret'),
      body: Stack(
        children: [
          const GradientBackground(),
          SafeArea(
            child: Column(
              children: [
                // Step Counter
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      '01 / 02',
                      style: GoogleFonts.spaceMono(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: labelColor,
                        letterSpacing: 2.0,
                      ),
                    ),
                  ),
                ),

                // Form Fields
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        VaultTextField(
                          controller: _nameController,
                          label: 'SECRET NAME',
                          placeholder: 'e.g. My Primary Wallet',
                        ),
                        const SizedBox(height: 32),

                        // Network Selection
                        Text(
                          'NETWORK',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: labelColor,
                            letterSpacing: 1.5,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            color: surfaceColor,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _selectedNetwork,
                              isExpanded: true,
                              dropdownColor: surfaceColor,
                              icon: const Icon(PhosphorIconsBold.caretDown, size: 16, color: Colors.white),
                              items: _networks.map((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(
                                    value,
                                    style: GoogleFonts.spaceGrotesk(color: Colors.white, fontSize: 14),
                                  ),
                                );
                              }).toList(),
                              onChanged: (newValue) {
                                if (newValue != null) setState(() => _selectedNetwork = newValue);
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),

                        // Icon Selection
                        Text(
                          'ICON',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: labelColor,
                            letterSpacing: 1.5,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: _icons.map((item) {
                            final isSelected = _selectedIcon == item['id'];
                            return GestureDetector(
                              onTap: () {
                                HapticFeedback.selectionClick();
                                setState(() => _selectedIcon = item['id']);
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: isSelected ? primaryColor.withValues(alpha: 0.2) : surfaceColor,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: isSelected ? primaryColor : Colors.white.withValues(alpha: 0.1),
                                    width: 1.5,
                                  ),
                                ),
                                child: Icon(
                                  item['icon'],
                                  size: 20,
                                  color: isSelected ? primaryColor : Colors.grey[500],
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 32),

                        // Seed Phrase Length
                        Text(
                          'SEED PHRASE LENGTH',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: labelColor,
                            letterSpacing: 1.5,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [12, 18, 24].map((count) {
                            final isSelected = _wordCount == count;
                            return Expanded(
                              child: Padding(
                                padding: EdgeInsets.only(
                                  left: count == 12 ? 0 : 4,
                                  right: count == 24 ? 0 : 4,
                                ),
                                child: GestureDetector(
                                  onTap: () {
                                    HapticFeedback.selectionClick();
                                    setState(() => _wordCount = count);
                                  },
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    height: 44,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      color: isSelected ? primaryColor : surfaceColor,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: isSelected ? primaryColor : Colors.white.withValues(alpha: 0.1),
                                      ),
                                    ),
                                    child: Text(
                                      '$count WORDS',
                                      style: GoogleFonts.spaceMono(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: isSelected ? backgroundDark : Colors.grey[500],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),

                // Next Button
                Padding(
                  padding: const EdgeInsets.fromLTRB(32, 16, 32, 40),
                  child: VaultButton(
                    text: 'NEXT STEP',
                    icon: PhosphorIconsBold.arrowRight,
                    onTap: _nextStep,
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

