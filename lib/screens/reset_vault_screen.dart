import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import '../services/master_key_service.dart';
import '../providers/vault_provider.dart';
import '../widgets/gradient_background.dart';
import '../widgets/vault_app_bar.dart';
import '../widgets/vault_text_field.dart';
import '../widgets/vault_brand.dart';

class ResetVaultScreen extends StatefulWidget {
  const ResetVaultScreen({super.key});

  @override
  State<ResetVaultScreen> createState() => _ResetVaultScreenState();
}

class _ResetVaultScreenState extends State<ResetVaultScreen> with SingleTickerProviderStateMixin {
  final _passwordController = TextEditingController();
  final _masterKeyService = MasterKeyService();

  bool _isPasswordVerified = false;
  bool _isLoading = false;
  String? _errorMessage;
  bool _showPassword = false;

  // Long press logic
  double _resetProgress = 0.0;
  Timer? _progressTimer;
  late AnimationController _pulseController;
  bool _isPressing = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _progressTimer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _verifyPassword() async {
    final password = _passwordController.text;
    if (password.isEmpty) {
      setState(() => _errorMessage = 'Password required');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final isValid = await _masterKeyService.verifyPassword(password);
      if (isValid) {
        HapticFeedback.mediumImpact();
        setState(() {
          _isPasswordVerified = true;
          _isLoading = false;
        });
      } else {
        HapticFeedback.vibrate();
        setState(() {
          _errorMessage = 'Incorrect master password';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Verification failed';
        _isLoading = false;
      });
    }
  }

  void _startResetTimer() {
    setState(() {
      _isPressing = true;
      _resetProgress = 0.0;
    });

    _progressTimer = Timer.periodic(const Duration(milliseconds: 30), (timer) {
      setState(() {
        _resetProgress += 0.01; // Approx 3 seconds total

        // Haptic feedback during progress
        if (timer.tick % 10 == 0) {
          HapticFeedback.selectionClick();
        }
        if (_resetProgress > 0.7 && timer.tick % 5 == 0) {
          HapticFeedback.lightImpact();
        }
        if (_resetProgress > 0.9) {
          HapticFeedback.mediumImpact();
        }

        if (_resetProgress >= 1.0) {
          _progressTimer?.cancel();
          _performFinalReset();
        }
      });
    });
  }

  void _cancelResetTimer() {
    _progressTimer?.cancel();
    if (_resetProgress < 1.0) {
      HapticFeedback.heavyImpact();
      setState(() {
        _isPressing = false;
        _resetProgress = 0.0;
      });
    }
  }

  Future<void> _performFinalReset() async {
    HapticFeedback.heavyImpact();
    await Future.delayed(const Duration(milliseconds: 100));
    HapticFeedback.heavyImpact();

    if (!mounted) return;

    final vaultProvider = Provider.of<VaultProvider>(context, listen: false);

    try {
      // Clear data
      await vaultProvider.clearVault();
      await _masterKeyService.reset();

      if (mounted) {
        // Success haptic
        HapticFeedback.mediumImpact();

        // Navigate to onboarding and clear stack
        Navigator.of(context).pushNamedAndRemoveUntil('/onboarding', (route) => false);
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Reset failed: $e';
        _isPressing = false;
        _resetProgress = 0.0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    const backgroundDark = Color(0xFF101d22);
    const primaryColor = Color(0xFF13b6ec);
    const dangerColor = Color(0xFFff4d4d);

    return Scaffold(
      backgroundColor: backgroundDark,
      extendBodyBehindAppBar: true,
      appBar: const VaultAppBar(title: 'Reset Vault'),
      body: Stack(
        children: [
          const GradientBackground(),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (!_isPasswordVerified) ...[
                    const Center(child: VaultBrand(fontSize: 32)),
                    const SizedBox(height: 48),
                    Text(
                      'Verify Identity',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Enter your master password to proceed with vault reset.',
                      style: GoogleFonts.notoSans(color: Colors.grey[400], fontSize: 14),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 40),
                    VaultTextField(
                      controller: _passwordController,
                      hintText: 'Master Password',
                      isPassword: !_showPassword,
                      textInputAction: TextInputAction.done,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Checkbox(
                          value: _showPassword,
                          onChanged: (v) => setState(() => _showPassword = v ?? false),
                          activeColor: primaryColor,
                        ),
                        Text('Show password', style: GoogleFonts.notoSans(color: Colors.grey[500])),
                      ],
                    ),
                    if (_errorMessage != null) ...[
                      const SizedBox(height: 16),
                      Text(
                        _errorMessage!,
                        style: GoogleFonts.notoSans(color: dangerColor, fontSize: 13),
                        textAlign: TextAlign.center,
                      ),
                    ],
                    const Spacer(),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _verifyPassword,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: backgroundDark,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: _isLoading
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                        : Text('VERIFY', style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.bold, letterSpacing: 1)),
                    ),
                  ] else ...[
                    // Final confirmation state
                    const Center(
                      child: Icon(PhosphorIconsBold.warningDiamond, color: dangerColor, size: 80),
                    ),
                    const SizedBox(height: 32),
                    Text(
                      'DANGER ZONE',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: dangerColor,
                        letterSpacing: 2,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: dangerColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: dangerColor.withValues(alpha: 0.3)),
                      ),
                      child: Column(
                        children: [
                          _WarningItem(text: 'All your 12-word seed phrases will be deleted'),
                          const SizedBox(height: 12),
                          _WarningItem(text: 'All local encryption keys will be wiped'),
                          const SizedBox(height: 12),
                          _WarningItem(text: 'This action is PERMANENT and IRREVERSIBLE'),
                        ],
                      ),
                    ),
                    const Spacer(),

                    // The 3-second hold button
                    Column(
                      children: [
                        Text(
                          'HOLD FOR 3 SECONDS TO WIPE EVERYTHING',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 11,
                            color: Colors.grey[500],
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                        ),
                        const SizedBox(height: 16),
                        GestureDetector(
                          onLongPressStart: (_) => _startResetTimer(),
                          onLongPressEnd: (_) => _cancelResetTimer(),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              SizedBox(
                                width: 120,
                                height: 120,
                                child: CircularProgressIndicator(
                                  value: _resetProgress,
                                  strokeWidth: 8,
                                  color: dangerColor,
                                  backgroundColor: Colors.white.withValues(alpha: 0.05),
                                ),
                              ),
                              ScaleTransition(
                                scale: _isPressing
                                  ? Tween(begin: 1.0, end: 1.1).animate(_pulseController)
                                  : const AlwaysStoppedAnimation(1.0),
                                child: Container(
                                  width: 90,
                                  height: 90,
                                  decoration: BoxDecoration(
                                    color: _isPressing ? dangerColor : dangerColor.withValues(alpha: 0.2),
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      if (_isPressing)
                                        BoxShadow(
                                          color: dangerColor.withValues(alpha: 0.4),
                                          blurRadius: 20,
                                          spreadRadius: 5,
                                        ),
                                    ],
                                  ),
                                  child: Icon(
                                    PhosphorIconsBold.trash,
                                    color: _isPressing ? Colors.white : dangerColor,
                                    size: 32,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WarningItem extends StatelessWidget {
  final String text;
  const _WarningItem({required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(PhosphorIconsBold.caretRight, color: Color(0xFFff4d4d), size: 16),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.notoSans(
              color: Colors.white.withValues(alpha: 0.8),
              fontSize: 14,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}
