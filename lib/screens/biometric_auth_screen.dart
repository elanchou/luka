import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:local_auth/local_auth.dart';
import '../services/biometric_service.dart';
import '../widgets/gradient_background.dart';

class BiometricAuthScreen extends StatefulWidget {
  const BiometricAuthScreen({super.key});

  @override
  State<BiometricAuthScreen> createState() => _BiometricAuthScreenState();
}

class _BiometricAuthScreenState extends State<BiometricAuthScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scanAnimation;
  final BiometricService _biometricService = BiometricService();
  bool _isAuthenticating = false;
  String _statusText = 'Authenticating...';
  bool _isFaceId = false;

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

    // Auto-start authentication
    _checkAndAuthenticate();
  }

  Future<void> _checkAndAuthenticate() async {
    setState(() {
      _statusText = 'Checking biometric support...';
    });

    bool isSupported = await _biometricService.isDeviceSupported();
    if (!isSupported) {
      if (mounted) {
        setState(() {
          _statusText = 'Biometrics not available';
        });
        // Fallback to PIN or other method if implemented, or just show error
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Biometrics not supported on this device')),
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
        // Navigate to Dashboard
        Navigator.of(context).pushReplacementNamed('/dashboard');
      } else {
        setState(() {
          _statusText = 'Authentication Failed. Tap to retry.';
        });
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
    const primaryColor = Color(0xFF13b6ec);
    const backgroundDark = Color(0xFF101d22);

    return Scaffold(
      backgroundColor: backgroundDark,
      body: Stack(
        children: [
          // Ambient Background Glow
          const GradientBackground(),

          // Main Content
          SafeArea(
            child: Column(
              children: [
                const Spacer(),

                // Scanner Section
                GestureDetector(
                  onTap: _authenticate,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Outer glow ring (static for now, could pulse)
                      Container(
                        width: 140,
                        height: 140,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: primaryColor.withOpacity(0.0), // Transparent base
                          boxShadow: [
                            BoxShadow(
                              color: primaryColor.withOpacity(0.1),
                              blurRadius: 30,
                              spreadRadius: 0,
                            ),
                          ],
                        ),
                      ),

                      // Icon Container
                      Container(
                        width: 128,
                        height: 128,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: backgroundDark.withOpacity(0.5),
                          border: Border.all(
                            color: primaryColor.withOpacity(0.1),
                            width: 1,
                          ),
                        ),
                        child: Icon(
                          _isFaceId ? Icons.face_unlock_outlined : Icons.fingerprint,
                          size: 64,
                          color: primaryColor,
                        ),
                      ),

                      // Scanning Line
                      ClipOval(
                        child: SizedBox(
                          width: 128,
                          height: 128,
                          child: AnimatedBuilder(
                            animation: _scanAnimation,
                            builder: (context, child) {
                              return FractionallySizedBox(
                                heightFactor: 0.1, // Thickness of the scan line area
                                alignment: Alignment(0, _scanAnimation.value),
                                child: Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        primaryColor.withOpacity(0.0),
                                        primaryColor.withOpacity(0.5),
                                        primaryColor.withOpacity(0.0),
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
                ),

                const SizedBox(height: 32),

                // Status Text
                Text(
                  _statusText,
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 20,
                    color: Colors.white.withOpacity(0.9),
                    letterSpacing: 0.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Your security is our priority',
                  style: GoogleFonts.notoSans(
                    fontSize: 14,
                    color: Colors.grey[400],
                    fontWeight: FontWeight.w300,
                  ),
                ),

                const Spacer(),

                // Footer: Enter PIN
                Padding(
                  padding: const EdgeInsets.only(bottom: 48.0),
                  child: TextButton(
                    onPressed: () {
                      // Placeholder for PIN entry logic
                      // Navigator.pushNamed(context, '/pin-auth');
                    },
                    style: TextButton.styleFrom(
                      overlayColor: primaryColor.withOpacity(0.1),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'ENTER PIN',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 14,
                            color: Colors.grey[400],
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1.5,
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
}
