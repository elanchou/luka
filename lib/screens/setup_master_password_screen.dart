import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/master_key_service.dart';
import '../widgets/gradient_background.dart';
import '../widgets/vault_button.dart';
import '../widgets/vault_text_field.dart';

/// 初次设置 Master Password 的专用页面
class SetupMasterPasswordScreen extends StatefulWidget {
  const SetupMasterPasswordScreen({super.key});

  @override
  State<SetupMasterPasswordScreen> createState() => _SetupMasterPasswordScreenState();
}

class _SetupMasterPasswordScreenState extends State<SetupMasterPasswordScreen> {
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _masterKeyService = MasterKeyService();
  
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
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

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
        // 设置成功后，导航到密码输入页面
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
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Create Master Password',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Welcome message
                        Center(
                          child: Column(
                            children: [
                              Icon(
                                Icons.shield_outlined,
                                size: 80,
                                color: primaryColor,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Secure Your Vault',
                                style: GoogleFonts.spaceGrotesk(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Create a strong master password to protect your secrets',
                                style: GoogleFonts.notoSans(
                                  fontSize: 14,
                                  color: Colors.grey[400],
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 32),

                        // Info card
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1a2c32),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: primaryColor.withOpacity(0.2),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                color: primaryColor,
                                size: 24,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Your master password derives the encryption key using PBKDF2. Choose a strong, memorable password.',
                                  style: GoogleFonts.notoSans(
                                    fontSize: 13,
                                    color: Colors.grey[300],
                                    height: 1.4,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Password field
                        Text(
                          'Master Password',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey[400],
                          ),
                        ),
                        const SizedBox(height: 8),
                        VaultTextField(
                          controller: _passwordController,
                          hintText: 'At least 8 characters',
                          isPassword: !_showPassword,
                          textInputAction: TextInputAction.next,
                        ),

                        const SizedBox(height: 16),

                        // Confirm Password
                        Text(
                          'Confirm Password',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey[400],
                          ),
                        ),
                        const SizedBox(height: 8),
                        VaultTextField(
                          controller: _confirmPasswordController,
                          hintText: 'Re-enter password',
                          isPassword: !_showPassword,
                          textInputAction: TextInputAction.done,
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
                                          ? Icons.radio_button_checked
                                          : Icons.radio_button_unchecked,
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

                        const SizedBox(height: 8),

                        // Security info
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.orange.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: Colors.orange.withOpacity(0.3),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.warning_amber_rounded,
                                color: Colors.orange[300],
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Higher security levels take longer to unlock but are more resistant to attacks.',
                                  style: GoogleFonts.notoSans(
                                    fontSize: 12,
                                    color: Colors.orange[200],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        if (_errorMessage != null) ...[
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: Colors.red.withOpacity(0.3),
                              ),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.error_outline,
                                  color: Colors.red,
                                  size: 20,
                                ),
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

                        // Create Password Button
                        VaultButton(
                          text: 'Create Password',
                          onTap: _isLoading ? null : _setupPassword,
                          isLoading: _isLoading,
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Warning
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: Colors.red.withOpacity(0.3),
                            ),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.lock_outline,
                                color: Colors.red[300],
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Important: There is no way to recover your master password. Make sure you remember it!',
                                  style: GoogleFonts.notoSans(
                                    fontSize: 12,
                                    color: Colors.red[200],
                                    height: 1.4,
                                  ),
                                ),
                              ),
                            ],
                          ),
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
