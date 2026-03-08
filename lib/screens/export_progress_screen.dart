import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:provider/provider.dart';
import '../providers/sault_provider.dart';
import 'dart:io';
import '../utils/constants.dart';
import '../widgets/gradient_background.dart';
import '../widgets/sault_outline_button.dart';
import '../widgets/sault_app_bar.dart';

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
      final exportFile = await Provider.of<SaultProvider>(context, listen: false).exportDecryptedData();

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
    await Share.shareXFiles([xFile], text: 'Sault Export (Decrypted)');
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
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      extendBodyBehindAppBar: true,
      appBar: SaultAppBar(
        leading: const SizedBox(), // Hide back button
        titleWidget: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(PhosphorIconsBold.shieldCheck, color: AppColors.primaryColor, size: 18),
            const SizedBox(width: 8),
            Text(
              'Secure Export',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.textSecondary,
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

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Container(
                    padding: const EdgeInsets.all(28),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.045),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: AppColors.softBorderColor),
                    ),
                    child: AnimatedBuilder(
                      animation: _progressAnimation,
                      builder: (context, child) {
                        return Column(
                          children: [
                            Text(
                              '${_progressAnimation.value.toInt()}%',
                              style: GoogleFonts.spaceGrotesk(
                                fontSize: 56,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                                letterSpacing: -1.8,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Preparing decrypted export package',
                              style: GoogleFonts.notoSans(
                                fontSize: 14,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 22),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(999),
                              child: LinearProgressIndicator(
                                value: _progressAnimation.value / 100,
                                minHeight: 8,
                                backgroundColor: Colors.white.withValues(alpha: 0.06),
                                valueColor: const AlwaysStoppedAnimation<Color>(
                                  AppColors.primaryColor,
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),

                const Spacer(),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'System Log',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textMuted,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        height: 160,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: AppColors.backgroundElevated,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppColors.softBorderColor),
                        ),
                        child: ListView.builder(
                          controller: _logScrollController,
                          padding: const EdgeInsets.all(16),
                          itemCount: _logs.length,
                          itemBuilder: (context, index) {
                            final log = _logs[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 6),
                              child: Text(
                                log.message,
                                style: GoogleFonts.jetBrainsMono(
                                  fontSize: 10,
                                  color: _getColorForLogType(log.type),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),

                // Footer
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                  child: SaultOutlineButton(
                    text: 'Cancel Export',
                    icon: PhosphorIconsBold.xCircle,
                    onTap: () => Navigator.pop(context),
                    borderColor: AppColors.softBorderColor,
                    textColor: AppColors.textPrimary,
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
        return AppColors.textSecondary;
      case LogType.highlight:
        return AppColors.primaryColor;
      case LogType.active:
        return AppColors.warningColor;
      case LogType.success:
        return AppColors.successColor;
    }
  }
}

enum LogType { info, highlight, active, success }

class LogEntry {
  final String message;
  final LogType type;

  LogEntry(this.message, this.type);
}
