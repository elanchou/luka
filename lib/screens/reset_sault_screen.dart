import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import '../providers/sault_provider.dart';
import '../services/master_key_service.dart';
import '../utils/constants.dart';
import '../widgets/gradient_background.dart';
import '../widgets/sault_app_bar.dart';
import '../widgets/sault_button.dart';
import '../widgets/sault_text_field.dart';

class ResetSaultScreen extends StatefulWidget {
  const ResetSaultScreen({super.key});

  @override
  State<ResetSaultScreen> createState() => _ResetSaultScreenState();
}

class _ResetSaultScreenState extends State<ResetSaultScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _passwordController = TextEditingController();
  final MasterKeyService _masterKeyService = MasterKeyService();

  bool _isPasswordVerified = false;
  bool _isLoading = false;
  String? _errorMessage;
  bool _showPassword = false;
  double _resetProgress = 0.0;
  Timer? _progressTimer;
  late final AnimationController _pulseController;
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
    final String password = _passwordController.text;
    if (password.isEmpty) {
      setState(() => _errorMessage = 'Password required');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final bool isValid = await _masterKeyService.verifyPassword(password);
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
    } catch (_) {
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
        _resetProgress += 0.01;
        if (timer.tick % 10 == 0) HapticFeedback.selectionClick();
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
    final SaultProvider vaultProvider = Provider.of<SaultProvider>(context, listen: false);

    try {
      await vaultProvider.clearVault();
      await _masterKeyService.reset();
      if (mounted) {
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
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      extendBodyBehindAppBar: true,
      appBar: const SaultAppBar(title: 'Reset Vault'),
      body: Stack(
        children: [
          const GradientBackground(),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: _isPasswordVerified ? _buildDangerState() : _buildVerifyState(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVerifyState() {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 540),
        child: Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.045),
            borderRadius: BorderRadius.circular(32),
            border: Border.all(color: AppColors.softBorderColor),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(22),
                  color: AppColors.dangerColor.withValues(alpha: 0.10),
                  border: Border.all(color: AppColors.dangerColor.withValues(alpha: 0.20)),
                ),
                child: const Icon(
                  PhosphorIconsBold.warningDiamond,
                  color: AppColors.dangerColor,
                  size: 28,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Verify Before Reset',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 30,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.8,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Enter your current master password before proceeding to the irreversible reset flow.',
                style: GoogleFonts.notoSans(
                  fontSize: 14,
                  height: 1.6,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 22),
              SaultTextField(
                controller: _passwordController,
                label: 'Master Password',
                hintText: 'Enter current password',
                isPassword: !_showPassword,
                textInputAction: TextInputAction.done,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Checkbox(
                    value: _showPassword,
                    onChanged: (value) => setState(() => _showPassword = value ?? false),
                    activeColor: AppColors.primaryColor,
                    side: const BorderSide(color: AppColors.textMuted),
                  ),
                  Text(
                    'Show password',
                    style: GoogleFonts.notoSans(color: AppColors.textSecondary),
                  ),
                ],
              ),
              if (_errorMessage != null) ...[
                const SizedBox(height: 8),
                Text(
                  _errorMessage!,
                  style: GoogleFonts.notoSans(
                    color: AppColors.dangerColor,
                    fontSize: 13,
                  ),
                ),
              ],
              const SizedBox(height: 24),
              SaultButton(
                text: 'Verify Identity',
                onTap: _isLoading ? null : _verifyPassword,
                isLoading: _isLoading,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDangerState() {
    return Column(
      children: [
        Expanded(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: Container(
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.045),
                  borderRadius: BorderRadius.circular(32),
                  border: Border.all(color: AppColors.softBorderColor),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      PhosphorIconsBold.warningDiamond,
                      color: AppColors.dangerColor,
                      size: 48,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Permanent Reset',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 30,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.8,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'This removes all secrets, activity logs, and key material from this device.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.notoSans(
                        color: AppColors.textSecondary,
                        height: 1.6,
                      ),
                    ),
                    const SizedBox(height: 20),
                    _DangerItem(text: 'All locally stored encrypted secrets will be deleted'),
                    _DangerItem(text: 'Master password derivation data will be wiped'),
                    _DangerItem(text: 'This action cannot be reversed'),
                    const SizedBox(height: 28),
                    Text(
                      'Hold to confirm',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 12,
                        color: AppColors.textMuted,
                        fontWeight: FontWeight.w700,
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
                            width: 124,
                            height: 124,
                            child: CircularProgressIndicator(
                              value: _resetProgress,
                              strokeWidth: 7,
                              color: AppColors.dangerColor,
                              backgroundColor: Colors.white.withValues(alpha: 0.05),
                            ),
                          ),
                          ScaleTransition(
                            scale: _isPressing
                                ? Tween<double>(begin: 1.0, end: 1.08).animate(_pulseController)
                                : const AlwaysStoppedAnimation<double>(1.0),
                            child: Container(
                              width: 92,
                              height: 92,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: _isPressing
                                    ? AppColors.dangerColor
                                    : AppColors.dangerColor.withValues(alpha: 0.16),
                              ),
                              child: Icon(
                                PhosphorIconsBold.trash,
                                color: _isPressing ? Colors.white : AppColors.dangerColor,
                                size: 32,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (_errorMessage != null) ...[
                      const SizedBox(height: 20),
                      Text(
                        _errorMessage!,
                        style: GoogleFonts.notoSans(color: AppColors.dangerColor),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _DangerItem extends StatelessWidget {
  final String text;

  const _DangerItem({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 2),
            child: Icon(
              PhosphorIconsBold.caretRight,
              color: AppColors.dangerColor,
              size: 14,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.notoSans(
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
