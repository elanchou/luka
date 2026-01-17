import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:provider/provider.dart';
import '../providers/vault_provider.dart';
import 'dart:io';
import '../widgets/gradient_background.dart';
import '../widgets/vault_outline_button.dart';
import '../widgets/vault_app_bar.dart';

class ExportProgressScreen extends StatefulWidget {
  const ExportProgressScreen({super.key});

  @override
  State<ExportProgressScreen> createState() => _ExportProgressScreenState();
}

class _ExportProgressScreenState extends State<ExportProgressScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _progressAnimation;
  final ScrollController _logScrollController = ScrollController();

  final List<LogEntry> _logs = [];
  bool _exportStarted = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    );

    _progressAnimation = Tween<double>(begin: 0.0, end: 100.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    // Don't forward controller immediately, drive it via logic
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_exportStarted) {
      _exportStarted = true;
      _startExportProcess();
    }
  }

  Future<void> _startExportProcess() async {
    _addLog('Initialize sequence started', LogType.info);
    await Future.delayed(const Duration(milliseconds: 500));
    _controller.animateTo(0.2, duration: const Duration(milliseconds: 500));

    _addLog('Handshake established: secure_enclave', LogType.info);
    await Future.delayed(const Duration(milliseconds: 400));

    _addLog('Deriving keys using Argon2id...', LogType.highlight);
    _controller.animateTo(0.4, duration: const Duration(milliseconds: 800));
    await Future.delayed(const Duration(milliseconds: 600));

    _addLog('Reading encrypted vault...', LogType.info);
    _controller.animateTo(0.6, duration: const Duration(milliseconds: 600));
    await Future.delayed(const Duration(milliseconds: 500));

    _addLog('Decrypting content (AES-256-GCM)...', LogType.active);
    _controller.animateTo(0.8, duration: const Duration(milliseconds: 1000));

    // Perform actual export
    try {
      final exportFile = await Provider.of<VaultProvider>(context, listen: false).exportDecryptedData();

      if (exportFile != null) {
        _controller.animateTo(1.0, duration: const Duration(milliseconds: 400));
        _addLog('Decryption complete', LogType.success);
        _addLog('Generating JSON package...', LogType.highlight);
        await Future.delayed(const Duration(milliseconds: 300));
        _addLog('Export complete successfully', LogType.success);

        await Future.delayed(const Duration(milliseconds: 1000));

        if (mounted) {
           _shareFile(exportFile);
        }
      } else {
        _addLog('Export failed: No data or error', LogType.active); // Error color reused
      }
    } catch (e) {
      _addLog('Critical Error: $e', LogType.active);
    }
  }

  void _shareFile(File file) async {
    final xFile = XFile(file.path);
    await Share.shareXFiles([xFile], text: 'Vault Export (Decrypted)');
    if (mounted) {
      Navigator.pop(context);
    }
  }

  void _addLog(String message, LogType type) {
    if (!mounted) return;
    setState(() {
      _logs.add(LogEntry(message, type));
    });
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_logScrollController.hasClients) {
        _logScrollController.animateTo(
          _logScrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _logScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF13b6ec);
    const backgroundDark = Color(0xFF101d22);
    const surfaceDark = Color(0xFF16262c);

    return Scaffold(
      backgroundColor: backgroundDark,
      extendBodyBehindAppBar: true,
      appBar: VaultAppBar(
        leading: const SizedBox(), // Hide back button
        titleWidget: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(PhosphorIconsBold.shieldCheck, color: primaryColor, size: 20),
            const SizedBox(width: 8),
            Text(
              'SECURE EXPORT',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.grey[500],
                letterSpacing: 2.0,
              ),
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          // Background Glow
          const GradientBackground(),

          SafeArea(
            child: Column(
              children: [
                const Spacer(),

                // Progress Section
                AnimatedBuilder(
                  animation: _progressAnimation,
                  builder: (context, child) {
                    return Column(
                      children: [
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: _progressAnimation.value.toInt().toString(),
                                style: GoogleFonts.spaceGrotesk(
                                  fontSize: 80,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  height: 1.0,
                                  letterSpacing: -2.0,
                                ),
                              ),
                              TextSpan(
                                text: '%',
                                style: GoogleFonts.spaceGrotesk(
                                  fontSize: 40,
                                  color: primaryColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: primaryColor,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Processing Vault...',
                              style: GoogleFonts.spaceGrotesk(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                                color: primaryColor,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 32),
                          child: Column(
                            children: [
                              Container(
                                height: 6,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: surfaceDark,
                                  borderRadius: BorderRadius.circular(3),
                                  border: Border.all(color: Colors.white.withOpacity(0.05)),
                                ),
                                alignment: Alignment.centerLeft,
                                child: LayoutBuilder(
                                  builder: (context, constraints) {
                                    return Container(
                                      width: constraints.maxWidth * (_progressAnimation.value / 100),
                                      decoration: BoxDecoration(
                                        color: primaryColor,
                                        borderRadius: BorderRadius.circular(3),
                                        boxShadow: [
                                          BoxShadow(
                                            color: primaryColor.withOpacity(0.5),
                                            blurRadius: 10,
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'DECRYPTING',
                                    style: GoogleFonts.spaceMono(
                                      fontSize: 10,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  Text(
                                    'PLEASE WAIT',
                                    style: GoogleFonts.spaceMono(
                                      fontSize: 10,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),

                const Spacer(),

                // Log View
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'SYSTEM LOG',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[500],
                          letterSpacing: 2.0,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        height: 160,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: surfaceDark.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.white.withOpacity(0.05)),
                        ),
                        child: Stack(
                          children: [
                            // Scanlines
                            Positioned.fill(
                              child: Opacity(
                                opacity: 0.05,
                                child: Container(
                                  decoration: const BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [Colors.black, Colors.transparent],
                                      stops: [0.5, 0.5],
                                      tileMode: TileMode.repeated,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            ListView.builder(
                              controller: _logScrollController,
                              padding: const EdgeInsets.all(16),
                              itemCount: _logs.length,
                              itemBuilder: (context, index) {
                                final log = _logs[index];
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 4),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '> ',
                                        style: GoogleFonts.spaceMono(
                                          fontSize: 10,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                      Expanded(
                                        child: Text(
                                          log.message,
                                          style: GoogleFonts.spaceMono(
                                            fontSize: 10,
                                            color: _getColorForLogType(log.type),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Footer
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                  child: VaultOutlineButton(
                    text: 'Cancel Export',
                    icon: PhosphorIconsBold.xCircle,
                    onTap: () => Navigator.pop(context),
                    borderColor: Colors.white.withOpacity(0.1),
                    textColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getColorForLogType(LogType type) {
    switch (type) {
      case LogType.info:
        return Colors.grey[400]!;
      case LogType.highlight:
        return const Color(0xFF13b6ec);
      case LogType.active:
        return const Color(0xFF13b6ec);
      case LogType.success:
        return const Color(0xFF00d68f);
    }
  }
}

enum LogType { info, highlight, active, success }

class LogEntry {
  final String message;
  final LogType type;

  LogEntry(this.message, this.type);
}

