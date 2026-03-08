import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../services/master_key_service.dart';
import '../providers/sault_provider.dart';
import '../widgets/gradient_background.dart';
import '../widgets/sault_button.dart';
import '../widgets/sault_text_field.dart';
import '../widgets/sault_brand.dart';
import '../utils/constants.dart';

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
    Navigator.of(context).pushReplacementNamed(
      '/decrypting-progress',
      arguments: {'masterPassword': password},
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: Stack(
        children: [
          const GradientBackground(),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 520),
                  child: Container(
                    padding: const EdgeInsets.all(28),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.045),
                      borderRadius: BorderRadius.circular(32),
                      border: Border.all(color: AppColors.softBorderColor),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.24),
                          blurRadius: 36,
                          offset: const Offset(0, 18),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SaultBrand(
                          fontSize: 24,
                          mainAxisAlignment: MainAxisAlignment.center,
                        ),
                        const SizedBox(height: 32),
                        Text(
                          'Enter Master Password',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 30,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                            letterSpacing: -0.8,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Authenticate to access your encrypted vault.',
                          style: GoogleFonts.notoSans(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                            height: 1.6,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 28),
                        SaultTextField(
                          controller: _passwordController,
                          label: 'Master Password',
                          hintText: 'Enter your master password',
                          isPassword: !_showPassword,
                          textInputAction: TextInputAction.done,
                          onChanged: (_) => setState(() => _errorMessage = null),
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            Checkbox(
                              value: _showPassword,
                              onChanged: (value) {
                                setState(() => _showPassword = value ?? false);
                              },
                              activeColor: AppColors.primaryColor,
                              side: const BorderSide(color: AppColors.textMuted),
                            ),
                            Text(
                              'Show password',
                              style: GoogleFonts.notoSans(
                                fontSize: 14,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                        if (_errorMessage != null) ...[
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: AppColors.dangerColor.withValues(alpha: 0.10),
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                color: AppColors.dangerColor.withValues(alpha: 0.22),
                              ),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  PhosphorIconsBold.warningCircle,
                                  color: AppColors.dangerColor,
                                  size: 18,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    _errorMessage!,
                                    style: GoogleFonts.notoSans(
                                      fontSize: 12,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                        const SizedBox(height: 24),
                        SaultButton(
                          text: 'Unlock Sault',
                          onTap: _isLoading ? null : _unlock,
                          isLoading: _isLoading,
                        ),
                        const SizedBox(height: 12),
                        TextButton(
                          onPressed: _showResetDialog,
                          child: Text(
                            'Forgot Password?',
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 14,
                              color: AppColors.textMuted,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
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
          'Reset Sault?',
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
              final vaultProvider = Provider.of<SaultProvider>(context, listen: false);
              await vaultProvider.clearVault();
              await _masterKeyService.reset();
              if (mounted) {
                Navigator.of(context).pushReplacementNamed('/onboarding');
              }
            },
            child: Text(
              'Reset Sault',
              style: GoogleFonts.spaceGrotesk(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}
