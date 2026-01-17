import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import "decrypting_progress_screen.dart";
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../services/master_key_service.dart';
import '../providers/vault_provider.dart';
import '../widgets/gradient_background.dart';
import '../widgets/vault_button.dart';
import '../widgets/vault_text_field.dart';
import '../widgets/vault_brand.dart';

class MasterPasswordInputScreen extends StatefulWidget {
  const MasterPasswordInputScreen({super.key});

  @override
  State<MasterPasswordInputScreen> createState() => _MasterPasswordInputScreenState();
}

class _MasterPasswordInputScreenState extends State<MasterPasswordInputScreen> {
  final _passwordController = TextEditingController();
  final _masterKeyService = MasterKeyService();
  bool _isLoading = false;
  String? _errorMessage;
  bool _showPassword = false;

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }


  Future<void> _unlock() async {
    final password = _passwordController.text;

    if (password.isEmpty) {
      setState(() => _errorMessage = 'Password cannot be empty');
      return;
    }

    HapticFeedback.mediumImpact();
    FocusScope.of(context).unfocus();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => DecryptingProgressScreen(
          masterPassword: password,
        ),
      ),
    );
  }
  Widget build(BuildContext context) {
    const backgroundDark = Color(0xFF101d22);
    const primaryColor = Color(0xFF13b6ec);

    return Scaffold(
      backgroundColor: backgroundDark,
      body: Stack(
        children: [
          const GradientBackground(),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Logo/Brand
                  const VaultBrand(
                    fontSize: 48,
                    mainAxisAlignment: MainAxisAlignment.center,
                  ),
                  const SizedBox(height: 48),

                  // Title
                  Text(
                    'Enter Master Password',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Unlock your vault',
                    style: GoogleFonts.notoSans(
                      fontSize: 14,
                      color: Colors.grey[400],
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 48),

                  // Password field
                  VaultTextField(
                    controller: _passwordController,
                    hintText: 'Enter your master password',
                    isPassword: !_showPassword,
                    textInputAction: TextInputAction.done,
                    onChanged: (_) => setState(() => _errorMessage = null),
                  ),

                  const SizedBox(height: 16),

                  // Show password toggle
                  Row(
                    children: [
                      Checkbox(
                        value: _showPassword,
                        onChanged: (value) {
                          setState(() => _showPassword = value ?? false);
                        },
                        activeColor: primaryColor,
                      ),
                      Text(
                        'Show password',
                        style: GoogleFonts.notoSans(
                          fontSize: 14,
                          color: Colors.grey[400],
                        ),
                      ),
                    ],
                  ),

                  if (_errorMessage != null) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        children: [
                          const Icon(PhosphorIconsBold.warningCircle, color: Colors.red, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _errorMessage!,
                              style: GoogleFonts.notoSans(
                                fontSize: 12,
                                color: Colors.red[200],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 32),

                  // Unlock button
                  VaultButton(
                    text: 'Unlock Vault',
                    onTap: _isLoading ? null : _unlock,
                    isLoading: _isLoading,
                  ),

                  const SizedBox(height: 16),

                  // Reset option
                  TextButton(
                    onPressed: () {
                      // Show warning dialog
                      _showResetDialog();
                    },
                    child: Text(
                      'Forgot Password?',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 14,
                        color: Colors.grey[500],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showResetDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1a2c32),
        title: Text(
          'Reset Vault?',
          style: GoogleFonts.spaceGrotesk(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'If you forgot your master password, you will need to reset the vault. This will delete all your secrets permanently.',
          style: GoogleFonts.notoSans(
            color: Colors.grey[300],
            fontSize: 14,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: GoogleFonts.spaceGrotesk(color: Colors.grey[400]),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              // Reset vault
              final vaultProvider = Provider.of<VaultProvider>(context, listen: false);
              await vaultProvider.clearVault();
              await _masterKeyService.reset();
              if (mounted) {
                Navigator.of(context).pushReplacementNamed('/onboarding');
              }
            },
            child: Text(
              'Reset Vault',
              style: GoogleFonts.spaceGrotesk(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}

