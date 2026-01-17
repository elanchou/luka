import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import '../services/master_key_service.dart';
import '../services/encryption_service.dart';
import '../providers/vault_provider.dart';
import '../widgets/gradient_background.dart';
import '../widgets/vault_button.dart';
import '../widgets/vault_text_field.dart';

class ChangeMasterPasswordScreen extends StatefulWidget {
  const ChangeMasterPasswordScreen({super.key});

  @override
  State<ChangeMasterPasswordScreen> createState() => _ChangeMasterPasswordScreenState();
}

class _ChangeMasterPasswordScreenState extends State<ChangeMasterPasswordScreen> {
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _masterKeyService = MasterKeyService();
  final _encryptionService = EncryptionService();

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
      final level = await _masterKeyService.getSecurityLevel();
      setState(() {
        _selectedLevel = level;
        _isLoadingLevel = false;
      });
    } catch (e) {
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
    final currentPassword = _currentPasswordController.text;
    final newPassword = _newPasswordController.text;
    final confirmPassword = _confirmPasswordController.text;

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
      // Verify current password
      final isValid = await _masterKeyService.verifyPassword(currentPassword);
      if (!isValid) {
        setState(() {
          _errorMessage = 'Current password is incorrect';
          _isLoading = false;
        });
        return;
      }

      // Change master password
      await _masterKeyService.changeMasterPassword(
        currentPassword,
        newPassword,
        _selectedLevel,
      );

      // Reinitialize vault with new password
      if (mounted) {
        final vaultProvider = Provider.of<VaultProvider>(context, listen: false);
        await vaultProvider.reinitialize(newPassword);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Master password changed successfully',
                style: GoogleFonts.notoSans(),
              ),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
            ),
          );
          Navigator.pop(context, true);
        }
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
    const backgroundDark = Color(0xFF101d22);
    const primaryColor = Color(0xFF13b6ec);

    return Scaffold(
      backgroundColor: backgroundDark,
      body: Stack(
        children: [
          const GradientBackground(),
          SafeArea(
            child: Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(PhosphorIconsBold.arrowLeft, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Change Master Password',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),

                if (_isLoadingLevel)
                  const Expanded(
                    child: Center(
                      child: CircularProgressIndicator(color: primaryColor),
                    ),
                  )
                else
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Warning card
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.orange.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.orange.withOpacity(0.3),
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  PhosphorIconsBold.warning,
                                  color: Colors.orange[300],
                                  size: 24,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    'Changing your master password will re-encrypt all your vault data.',
                                    style: GoogleFonts.notoSans(
                                      fontSize: 13,
                                      color: Colors.orange[200],
                                      height: 1.4,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 24),

                          // Current Password
                          Text(
                            'Current Password',
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey[400],
                            ),
                          ),
                          const SizedBox(height: 8),
                          VaultTextField(
                            controller: _currentPasswordController,
                            hintText: 'Enter current password',
                            isPassword: !_showPasswords,
                            textInputAction: TextInputAction.next,
                          ),

                          const SizedBox(height: 20),

                          // New Password
                          Text(
                            'New Password',
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey[400],
                            ),
                          ),
                          const SizedBox(height: 8),
                          VaultTextField(
                            controller: _newPasswordController,
                            hintText: 'At least 8 characters',
                            isPassword: !_showPasswords,
                            textInputAction: TextInputAction.next,
                          ),

                          const SizedBox(height: 16),

                          // Confirm Password
                          Text(
                            'Confirm New Password',
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey[400],
                            ),
                          ),
                          const SizedBox(height: 8),
                          VaultTextField(
                            controller: _confirmPasswordController,
                            hintText: 'Re-enter new password',
                            isPassword: !_showPasswords,
                            textInputAction: TextInputAction.done,
                          ),

                          const SizedBox(height: 16),

                          // Show passwords toggle
                          Row(
                            children: [
                              Checkbox(
                                value: _showPasswords,
                                onChanged: (value) {
                                  setState(() => _showPasswords = value ?? false);
                                },
                                activeColor: primaryColor,
                              ),
                              Text(
                                'Show passwords',
                                style: GoogleFonts.notoSans(
                                  fontSize: 14,
                                  color: Colors.grey[400],
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 24),

                          // Security Level
                          Text(
                            'Security Level',
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey[400],
                            ),
                          ),
                          const SizedBox(height: 12),

                          ...SecurityLevel.values.map((level) {
                            final isSelected = _selectedLevel == level;
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: InkWell(
                                onTap: () => setState(() => _selectedLevel = level),
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? primaryColor.withOpacity(0.1)
                                        : const Color(0xFF1a2c32),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: isSelected
                                          ? primaryColor
                                          : Colors.grey[800]!,
                                      width: isSelected ? 2 : 1,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        isSelected
                                            ? PhosphorIconsBold.checkCircle
                                            : PhosphorIconsBold.circle,
                                        color: isSelected
                                            ? primaryColor
                                            : Colors.grey[600],
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              level.displayName,
                                              style: GoogleFonts.spaceGrotesk(
                                                fontSize: 15,
                                                fontWeight: FontWeight.w500,
                                                color: Colors.white,
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              '${_formatNumber(level.iterations)} iterations',
                                              style: GoogleFonts.notoSans(
                                                fontSize: 12,
                                                color: Colors.grey[500],
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
                          }).toList(),

                          if (_errorMessage != null) ...[
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.red.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.red.withOpacity(0.3)),
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

                          const SizedBox(height: 24),

                          // Change Password Button
                          VaultButton(
                            text: 'Change Password',
                            onTap: _isLoading ? null : _changePassword,
                            isLoading: _isLoading,
                          ),
                        ],
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

