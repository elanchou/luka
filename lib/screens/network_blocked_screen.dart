import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../widgets/vault_brand.dart';

class NetworkBlockedScreen extends StatefulWidget {
  const NetworkBlockedScreen({super.key});

  @override
  State<NetworkBlockedScreen> createState() => _NetworkBlockedScreenState();
}

class _NetworkBlockedScreenState extends State<NetworkBlockedScreen> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  Timer? _hapticTimer;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    // Constant warning haptics
    _hapticTimer = Timer.periodic(const Duration(milliseconds: 1500), (timer) {
      HapticFeedback.heavyImpact();
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _hapticTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const backgroundDark = Color(0xFF0a0a0a);
    const dangerColor = Color(0xFFff4d4d);

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: backgroundDark,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(40.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const VaultBrand(fontSize: 32),
                const SizedBox(height: 64),

                ScaleTransition(
                  scale: Tween(begin: 1.0, end: 1.2).animate(_pulseController),
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: dangerColor.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                      border: Border.all(color: dangerColor, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: dangerColor.withValues(alpha: 0.2),
                          blurRadius: 30,
                          spreadRadius: 10,
                        ),
                      ],
                    ),
                    child: const Icon(
                      PhosphorIconsBold.wifiSlash,
                      color: dangerColor,
                      size: 64,
                    ),
                  ),
                ),

                const SizedBox(height: 48),

                Text(
                  'AIR-GAP REQUIRED',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: dangerColor,
                    letterSpacing: 2.0,
                  ),
                ),

                const SizedBox(height: 16),

                Text(
                  'This vault requires strict offline isolation. Network activity detected. App has been locked to prevent potential data leakage.',
                  style: GoogleFonts.notoSans(
                    fontSize: 14,
                    color: Colors.grey[400],
                    height: 1.6,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 64),

                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(
                        width: 12,
                        height: 12,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: dangerColor,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'MONITORING ACTIVE',
                        style: GoogleFonts.spaceMono(
                          fontSize: 10,
                          color: Colors.grey[500],
                          letterSpacing: 1.0,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                Text(
                  'Disable all network connections (Wi-Fi, Mobile Data, Bluetooth) to restore access.',
                  style: GoogleFonts.notoSans(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontStyle: FontStyle.italic,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
