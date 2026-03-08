import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../services/master_key_service.dart';
import '../utils/constants.dart';
import '../widgets/gradient_background.dart';
import '../widgets/sault_button.dart';
import '../widgets/sault_text_field.dart';

class SetupMasterPasswordScreen extends StatefulWidget {
  const SetupMasterPasswordScreen({super.key});

  @override
  State<SetupMasterPasswordScreen> createState() => _SetupMasterPasswordScreenState();
}

class _SetupMasterPasswordScreenState extends State<SetupMasterPasswordScreen> {
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final MasterKeyService _masterKeyService = MasterKeyService();

  SecurityLevel _selectedLevel = SecurityLevel.standard;
  bool _isLoading = false;
  String? _errorMessage;
  bool _showPassword = false;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _setupPassword() async {
    final String password = _passwordController.text;
    final String confirmPassword = _confirmPasswordController.text;

    if (password.isEmpty) {
      setState(() => _errorMessage = 'Password cannot be empty');
      return;
    }

    if (password.length < 8) {
      setState(() => _errorMessage = 'Password must be at least 8 characters');
      return;
    }

    if (password != confirmPassword) {
      setState(() => _errorMessage = 'Passwords do not match');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await _masterKeyService.setMasterPassword(password, _selectedLevel);
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/master-password-input');
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: Stack(
        children: [
          const GradientBackground(),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(
                          PhosphorIconsBold.arrowLeft,
                          color: AppColors.textPrimary,
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 560),
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
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 64,
                                height: 64,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(22),
                                  color: AppColors.primaryColor.withValues(alpha: 0.10),
                                  border: Border.all(
                                    color: AppColors.primaryColor.withValues(alpha: 0.24),
                                  ),
                                ),
                                child: const Icon(
                                  PhosphorIconsBold.shieldCheck,
                                  size: 28,
                                  color: AppColors.primaryColor,
                                ),
                              ),
                              const SizedBox(height: 24),
                              Text(
                                'Create Master Password',
                                style: GoogleFonts.spaceGrotesk(
                                  fontSize: 32,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                  letterSpacing: -1.0,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                'This password becomes the root of your private vault. Make it memorable and strong.',
                                style: GoogleFonts.notoSans(
                                  fontSize: 14,
                                  height: 1.6,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 24),
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.03),
                                  borderRadius: BorderRadius.circular(22),
                                  border: Border.all(color: AppColors.softBorderColor),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      PhosphorIconsBold.info,
                                      color: AppColors.primaryColor,
                                      size: 18,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        'Your password derives the encryption key through PBKDF2 and cannot be recovered later.',
                                        style: GoogleFonts.notoSans(
                                          fontSize: 13,
                                          color: AppColors.textSecondary,
                                          height: 1.5,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 22),
                              SaultTextField(
                                controller: _passwordController,
                                label: 'Master Password',
                                hintText: 'At least 8 characters',
                                isPassword: !_showPassword,
                                textInputAction: TextInputAction.next,
                              ),
                              const SizedBox(height: 14),
                              SaultTextField(
                                controller: _confirmPasswordController,
                                label: 'Confirm Password',
                                hintText: 'Re-enter password',
                                isPassword: !_showPassword,
                                textInputAction: TextInputAction.done,
                              ),
                              const SizedBox(height: 12),
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
                                    'Show passwords',
                                    style: GoogleFonts.notoSans(
                                      fontSize: 14,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 18),
                              Text(
                                'Security Level',
                                style: GoogleFonts.spaceGrotesk(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 12),
                              ...SecurityLevel.values.map((level) {
                                final bool isSelected = _selectedLevel == level;
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 10),
                                  child: InkWell(
                                    onTap: () => setState(() => _selectedLevel = level),
                                    borderRadius: BorderRadius.circular(20),
                                    child: Container(
                                      padding: const EdgeInsets.all(18),
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? AppColors.primaryColor.withValues(alpha: 0.08)
                                            : Colors.white.withValues(alpha: 0.025),
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(
                                          color: isSelected
                                              ? AppColors.primaryColor.withValues(alpha: 0.26)
                                              : AppColors.softBorderColor,
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(
                                            isSelected
                                                ? PhosphorIconsBold.checkCircle
                                                : PhosphorIconsBold.circle,
                                            color: isSelected
                                                ? AppColors.primaryColor
                                                : AppColors.textMuted,
                                          ),
                                          const SizedBox(width: 14),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  level.displayName,
                                                  style: GoogleFonts.spaceGrotesk(
                                                    fontSize: 15,
                                                    fontWeight: FontWeight.w600,
                                                    color: AppColors.textPrimary,
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  '${_formatNumber(level.iterations)} iterations',
                                                  style: GoogleFonts.notoSans(
                                                    fontSize: 12,
                                                    color: AppColors.textMuted,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              }),
                              Container(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: AppColors.warningColor.withValues(alpha: 0.08),
                                  borderRadius: BorderRadius.circular(18),
                                  border: Border.all(
                                    color: AppColors.warningColor.withValues(alpha: 0.18),
                                  ),
                                ),
                                child: Text(
                                  'Higher security levels take longer to unlock, but offer stronger resistance to brute-force attacks.',
                                  style: GoogleFonts.notoSans(
                                    fontSize: 13,
                                    color: AppColors.textSecondary,
                                    height: 1.5,
                                  ),
                                ),
                              ),
                              if (_errorMessage != null) ...[
                                const SizedBox(height: 16),
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
                                text: 'Create Secure Vault',
                                onTap: _isLoading ? null : _setupPassword,
                                isLoading: _isLoading,
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
          ),
        ],
      ),
    );
  }

  String _formatNumber(int num) {
    return num.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]},',
    );
  }
}
