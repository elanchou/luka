import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import '../providers/sault_provider.dart';
import '../services/master_key_service.dart';
import '../utils/constants.dart';
import '../widgets/error_snackbar.dart';
import '../widgets/gradient_background.dart';
import '../widgets/sault_button.dart';
import '../widgets/sault_text_field.dart';

class ChangeMasterPasswordScreen extends StatefulWidget {
  const ChangeMasterPasswordScreen({super.key});

  @override
  State<ChangeMasterPasswordScreen> createState() => _ChangeMasterPasswordScreenState();
}

class _ChangeMasterPasswordScreenState extends State<ChangeMasterPasswordScreen> {
  final TextEditingController _currentPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final MasterKeyService _masterKeyService = MasterKeyService();

  SecurityLevel _selectedLevel = SecurityLevel.standard;
  bool _isLoading = false;
  bool _isLoadingLevel = true;
  String? _errorMessage;
  bool _showPasswords = false;

  @override
  void initState() {
    super.initState();
    _loadCurrentLevel();
  }

  Future<void> _loadCurrentLevel() async {
    try {
      final SecurityLevel level = await _masterKeyService.getSecurityLevel();
      setState(() {
        _selectedLevel = level;
        _isLoadingLevel = false;
      });
    } catch (_) {
      setState(() => _isLoadingLevel = false);
    }
  }

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _changePassword() async {
    final String currentPassword = _currentPasswordController.text;
    final String newPassword = _newPasswordController.text;
    final String confirmPassword = _confirmPasswordController.text;

    if (currentPassword.isEmpty) {
      setState(() => _errorMessage = 'Current password cannot be empty');
      return;
    }
    if (newPassword.isEmpty) {
      setState(() => _errorMessage = 'New password cannot be empty');
      return;
    }
    if (newPassword.length < 8) {
      setState(() => _errorMessage = 'New password must be at least 8 characters');
      return;
    }
    if (newPassword != confirmPassword) {
      setState(() => _errorMessage = 'Passwords do not match');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final SaultProvider vaultProvider = Provider.of<SaultProvider>(context, listen: false);
      final bool success = await vaultProvider.changeMasterPassword(
        oldPassword: currentPassword,
        newPassword: newPassword,
        securityLevel: _selectedLevel,
      );

      if (!success) {
        setState(() {
          _errorMessage = vaultProvider.error ?? 'Failed to change master password';
          _isLoading = false;
        });
        return;
      }

      if (mounted) {
        SuccessSnackbar.show(context, message: 'Master password changed successfully');
        Navigator.pop(context, true);
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
                if (_isLoadingLevel)
                  const Expanded(
                    child: Center(
                      child: CircularProgressIndicator(color: AppColors.primaryColor),
                    ),
                  )
                else
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
                                    PhosphorIconsBold.key,
                                    size: 28,
                                    color: AppColors.primaryColor,
                                  ),
                                ),
                                const SizedBox(height: 24),
                                Text(
                                  'Change Master Password',
                                  style: GoogleFonts.spaceGrotesk(
                                    fontSize: 30,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textPrimary,
                                    letterSpacing: -0.9,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  'Re-encrypt your vault with a new password and, if desired, a stronger derivation level.',
                                  style: GoogleFonts.notoSans(
                                    fontSize: 14,
                                    height: 1.6,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                const SizedBox(height: 22),
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: AppColors.warningColor.withValues(alpha: 0.08),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: AppColors.warningColor.withValues(alpha: 0.18),
                                    ),
                                  ),
                                  child: Text(
                                    'Your vault will be decrypted with the current password and re-encrypted immediately with the new one.',
                                    style: GoogleFonts.notoSans(
                                      fontSize: 13,
                                      color: AppColors.textSecondary,
                                      height: 1.5,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 20),
                                SaultTextField(
                                  controller: _currentPasswordController,
                                  label: 'Current Password',
                                  hintText: 'Enter current password',
                                  isPassword: !_showPasswords,
                                  textInputAction: TextInputAction.next,
                                ),
                                const SizedBox(height: 14),
                                SaultTextField(
                                  controller: _newPasswordController,
                                  label: 'New Password',
                                  hintText: 'At least 8 characters',
                                  isPassword: !_showPasswords,
                                  textInputAction: TextInputAction.next,
                                ),
                                const SizedBox(height: 14),
                                SaultTextField(
                                  controller: _confirmPasswordController,
                                  label: 'Confirm New Password',
                                  hintText: 'Re-enter new password',
                                  isPassword: !_showPasswords,
                                  textInputAction: TextInputAction.done,
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    Checkbox(
                                      value: _showPasswords,
                                      onChanged: (value) {
                                        setState(() => _showPasswords = value ?? false);
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
                                if (_errorMessage != null) ...[
                                  const SizedBox(height: 8),
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
                                  text: 'Apply New Password',
                                  onTap: _isLoading ? null : _changePassword,
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
