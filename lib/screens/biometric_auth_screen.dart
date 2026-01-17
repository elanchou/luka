import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:local_auth/local_auth.dart';
import '../services/biometric_service.dart';
import '../widgets/gradient_background.dart';
import '../utils/constants.dart';
import '../widgets/error_snackbar.dart';

class BiometricAuthScreen extends StatefulWidget {
  const BiometricAuthScreen({super.key});

  @override
  State<BiometricAuthScreen> createState() => _BiometricAuthScreenState();
}

class _BiometricAuthScreenState extends State<BiometricAuthScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scanAnimation;
  late Animation<double> _pulseAnimation;
  final BiometricService _biometricService = BiometricService();
  bool _isAuthenticating = false;
  String _statusText = 'Authenticating...';
  bool _isFaceId = false;
  bool _authAttempted = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();

    _scanAnimation = Tween<double>(begin: -1.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    // Auto-start authentication
    Future.delayed(const Duration(milliseconds: 500), () {
      _checkAndAuthenticate();
    });
  }

  Future<void> _checkAndAuthenticate() async {
    if (_authAttempted) {
      // If already attempted, just retry
      _authenticate();
      return;
    }

    setState(() {
      _statusText = 'Checking biometric support...';
    });

    bool isSupported = await _biometricService.isDeviceSupported();
    if (!isSupported) {
      if (mounted) {
        setState(() {
          _statusText = 'Biometrics not available';
        });
        ErrorSnackbar.show(
          context,
          message: 'Biometrics not supported on this device',
        );
      }
      return;
    }

    // Check biometric type
    List<BiometricType> availableBiometrics = await _biometricService.getAvailableBiometrics();
    if (mounted) {
      setState(() {
        _isFaceId = availableBiometrics.contains(BiometricType.face);
      });
    }

    _authAttempted = true;
    _authenticate();
  }

  Future<void> _authenticate() async {
    if (_isAuthenticating) return;

    setState(() {
      _isAuthenticating = true;
      _statusText = _isFaceId ? 'Scanning Face ID...' : 'Scan your fingerprint';
    });

    bool authenticated = await _biometricService.authenticate();

    if (mounted) {
      setState(() {
        _isAuthenticating = false;
      });

      if (authenticated) {
        setState(() {
          _statusText = 'Authentication Successful';
        });
        // Navigate to decrypting screen
        Navigator.of(context).pushReplacementNamed('/decrypting-progress');
      } else {
        setState(() {
          _statusText = 'Authentication Failed. Tap to retry.';
        });
        if (mounted) {
          ErrorSnackbar.show(
            context,
            message: 'Authentication failed. Please try again.',
          );
        }
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _biometricService.cancelAuthentication();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: Stack(
        children: [
          const GradientBackground(),

          SafeArea(
            child: SizedBox(
              width: double.infinity,
              height: double.infinity,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Spacer(flex: 2),

                    // App Logo/Title
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'VAULT',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: -1.0,
                          ),
                        ),
                        Text(
                          '.',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryColor,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 60),

                    // Scanner Section
                    GestureDetector(
                      onTap: _authenticate,
                      child: AnimatedBuilder(
                        animation: _pulseAnimation,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: _isAuthenticating ? _pulseAnimation.value : 1.0,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                // Outer glow ring
                                Container(
                                  width: 160,
                                  height: 160,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.primaryColor.withOpacity(0.2),
                                        blurRadius: 40,
                                        spreadRadius: 10,
                                      ),
                                    ],
                                  ),
                                ),

                                // Icon Container
                                Container(
                                  width: 140,
                                  height: 140,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white.withOpacity(0.05),
                                    border: Border.all(
                                      color: AppColors.primaryColor.withOpacity(0.3),
                                      width: 2,
                                    ),
                                  ),
                                  child: Icon(
                                    _isFaceId ? Icons.face_unlock_outlined : Icons.fingerprint,
                                    size: 70,
                                    color: AppColors.primaryColor,
                                  ),
                                ),

                                // Scanning Line
                                if (_isAuthenticating)
                                  ClipOval(
                                    child: SizedBox(
                                      width: 140,
                                      height: 140,
                                      child: AnimatedBuilder(
                                        animation: _scanAnimation,
                                        builder: (context, child) {
                                          return FractionallySizedBox(
                                            heightFactor: 0.15,
                                            alignment: Alignment(0, _scanAnimation.value),
                                            child: Container(
                                              decoration: BoxDecoration(
                                                gradient: LinearGradient(
                                                  begin: Alignment.topCenter,
                                                  end: Alignment.bottomCenter,
                                                  colors: [
                                                    AppColors.primaryColor.withOpacity(0.0),
                                                    AppColors.primaryColor.withOpacity(0.6),
                                                    AppColors.primaryColor.withOpacity(0.0),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 48),

                    // Status Text
                    SizedBox(
                      width: double.infinity,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            _statusText,
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: Colors.white.withOpacity(0.95),
                              letterSpacing: 0.5,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 12),
                          Container(
                            constraints: BoxConstraints(maxWidth: size.width * 0.8),
                            child: Text(
                              'Your security is our priority',
                              style: GoogleFonts.notoSans(
                                fontSize: 14,
                                color: Colors.grey[400],
                                fontWeight: FontWeight.w400,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const Spacer(flex: 3),

                    // Instruction Card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.03),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.1),
                        ),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            _isFaceId ? Icons.face : Icons.fingerprint,
                            size: 24,
                            color: AppColors.primaryColor.withOpacity(0.7),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            _isFaceId 
                                ? 'Position your face within the frame'
                                : 'Place your finger on the sensor',
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 13,
                              color: Colors.white.withOpacity(0.7),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Footer: Enter PIN
                    SizedBox(
                      width: double.infinity,
                      child: TextButton(
                        onPressed: () {
                          // Placeholder for PIN entry
                        },
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: Colors.white.withOpacity(0.02),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(
                              color: Colors.white.withOpacity(0.1),
                            ),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.dialpad,
                              size: 18,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'ENTER PIN INSTEAD',
                              style: GoogleFonts.spaceGrotesk(
                                fontSize: 13,
                                color: Colors.grey[400],
                                fontWeight: FontWeight.w600,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
