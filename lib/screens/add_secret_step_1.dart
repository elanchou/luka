import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../widgets/gradient_background.dart';
import '../widgets/vault_button.dart';
import '../widgets/vault_text_field.dart';
import '../widgets/vault_app_bar.dart';

class AddSecretStep1 extends StatefulWidget {
  const AddSecretStep1({super.key});

  @override
  State<AddSecretStep1> createState() => _AddSecretStep1State();
}

class _AddSecretStep1State extends State<AddSecretStep1> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _networkController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _networkController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_nameController.text.isNotEmpty) {
      // Pass data to Step 2
      Navigator.pushNamed(
        context,
        '/add-secret-2',
        arguments: {
          'name': _nameController.text,
          'network': _networkController.text,
        },
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a secret name')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF13b6ec);
    const backgroundDark = Color(0xFF101d22);
    const labelColor = Color(0xFF5f747a);

    return Scaffold(
      backgroundColor: backgroundDark,
      extendBodyBehindAppBar: true, // Allow gradient to show behind app bar
      appBar: const VaultAppBar(
        title: 'Add Secret',
      ),
      body: Stack(
        children: [
          const GradientBackground(),
          SafeArea(
            child: Column(
              children: [
                // Step Counter
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      '01 / 03',
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
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Column(
                      children: [
                        const SizedBox(height: 16),
                        VaultTextField(
                          controller: _nameController,
                          label: 'SECRET NAME',
                          placeholder: 'e.g. Main Vault',
                        ),
                        const SizedBox(height: 48),
                        VaultTextField(
                          controller: _networkController,
                          label: 'NETWORK',
                          placeholder: 'e.g. Ethereum',
                          suffixIcon: PhosphorIconsBold.globe,
                        ),
                      ],
                    ),
                  ),
                ),

                // Next Button
                Padding(
                  padding: const EdgeInsets.fromLTRB(32, 0, 32, 40),
                  child: VaultButton(
                    text: 'NEXT',
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

