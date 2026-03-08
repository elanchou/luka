import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../widgets/gradient_background.dart';
import '../providers/sault_provider.dart';
import '../services/master_key_service.dart';
import '../utils/constants.dart';

class DecryptingProgressScreen extends StatefulWidget {
  const DecryptingProgressScreen({super.key});

  @override
  State<DecryptingProgressScreen> createState() =>
      _DecryptingProgressScreenState();
}

class _DecryptingProgressScreenState extends State<DecryptingProgressScreen>
    with TickerProviderStateMixin {
  late String _masterPassword;
  late AnimationController _controller;
  late AnimationController _veilController;
  late Animation<double> _progressAnimation;
  late Animation<double> _focusAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _shimmerAnimation;
  final ScrollController _logScrollController = ScrollController();

  final List<LogEntry> _logs = [];
  bool _decryptStarted = false;
  bool _isUnlocked = false;
  double _currentProgress = 0.0;
  String _currentStep = 'Initializing...';

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );

    _veilController = AnimationController(
      duration: const Duration(milliseconds: 1400),
      vsync: this,
    )..repeat(reverse: true);

    _progressAnimation = Tween<double>(begin: 0.0, end: 100.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _focusAnimation = Tween<double>(begin: 0.18, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutCubic),
    );

    _pulseAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _veilController,
        curve: Curves.easeInOut,
      ),
    );

    _shimmerAnimation = Tween<double>(begin: -1.0, end: 1.0).animate(
      CurvedAnimation(parent: _veilController, curve: Curves.easeInOut),
    );

    _controller.addListener(() {
      setState(() {
        _currentProgress = _progressAnimation.value;
      });

      if (_controller.value >= 0.95 && !_isUnlocked) {
        _isUnlocked = true;
        _veilController.stop();
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_decryptStarted) {
      final args =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      _masterPassword = args?['masterPassword'] ?? '';
      _decryptStarted = true;
      _startDecryptProcess();
    }
  }

  Future<void> _startDecryptProcess() async {
    try {
      final SaultProvider vaultProvider = Provider.of<SaultProvider>(
        context,
        listen: false,
      );

      // Step 0: Verify Master Password
      _updateStep('Verifying master password...', 0.0);
      _addLog('[AUTH] Verifying master password', LogType.active);
      final masterKeyService = MasterKeyService();

      final isValid = await masterKeyService.verifyPassword(_masterPassword);
      if (!isValid) {
        throw Exception('Incorrect master password');
      }
      _addLog('[OK] Identity verified', LogType.success);
      await Future.delayed(const Duration(milliseconds: 300));

      // Step 1: 读取配置
      _updateStep('Reading vault configuration...', 0.05);
      _addLog('[INFO] Reading vault configuration', LogType.info);
      await Future.delayed(const Duration(milliseconds: 200));
      _controller.animateTo(0.1, duration: const Duration(milliseconds: 200));

      // Step 2: 读取 salt 和 iterations
      _updateStep('Loading security parameters...', 0.1);
      _addLog('[INIT] Loading salt and iterations', LogType.info);
      final securityLevel = await masterKeyService.getSecurityLevel();
      await Future.delayed(const Duration(milliseconds: 150));
      _controller.animateTo(0.2, duration: const Duration(milliseconds: 150));

      _addLog(
          '[OK] Security Level: ${securityLevel.displayName} (${_formatNumber(securityLevel.iterations)} iterations)',
          LogType.highlight);

      // Step 3: PBKDF2 密钥派生
      _updateStep('Deriving encryption key (PBKDF2)...', 0.2);
      _addLog('[EXEC] Starting PBKDF2 key derivation...', LogType.active);

      final keyDerivationStart = DateTime.now();

      _controller.animateTo(0.3, duration: const Duration(milliseconds: 100));
      await Future.delayed(const Duration(milliseconds: 100));

      // 实际执行 PBKDF2
      if (mounted) {
        _controller.animateTo(0.7,
            duration: Duration(milliseconds: securityLevel.iterations ~/ 1000));

        final bool unlocked = await vaultProvider.reinitialize(_masterPassword);
        if (!unlocked) {
          throw Exception(vaultProvider.error ?? 'Incorrect master password');
        }

        final keyDerivationTime = DateTime.now().difference(keyDerivationStart);
        _addLog('[OK] Key derived in ${keyDerivationTime.inMilliseconds}ms',
            LogType.success);
      }

      _controller.animateTo(0.75, duration: const Duration(milliseconds: 100));

      // Step 4: 读取加密文件
      _updateStep('Reading encrypted vault...', 0.75);
      _addLog('[READ] Loading vault.enc', LogType.info);
      await Future.delayed(const Duration(milliseconds: 150));
      _controller.animateTo(0.8, duration: const Duration(milliseconds: 150));

      final secretCount = vaultProvider.secretCount;
      _addLog('[OK] Found $secretCount encrypted secrets', LogType.highlight);

      // Step 5: AES 解密
      _updateStep('Decrypting vault (AES-256-CBC)...', 0.8);
      _addLog('[DECRYPT] Using AES-256-CBC algorithm', LogType.active);
      await Future.delayed(const Duration(milliseconds: 200));
      _controller.animateTo(0.9, duration: const Duration(milliseconds: 200));

      _addLog(
          '[OK] $secretCount secrets decrypted successfully', LogType.success);

      // Step 6: JSON 解析
      _updateStep('Parsing vault data...', 0.9);
      _addLog('[PARSE] Processing JSON data structure', LogType.info);
      await Future.delayed(const Duration(milliseconds: 100));
      _controller.animateTo(0.95, duration: const Duration(milliseconds: 100));

      _addLog('[OK] Vault data loaded into memory', LogType.success);

      // Step 7: 完成
      _updateStep('Vault unlocked!', 1.0);
      _controller.animateTo(1.0, duration: const Duration(milliseconds: 100));
      _addLog('[SUCCESS] Vault unlocked successfully', LogType.success);

      await Future.delayed(const Duration(milliseconds: 1000));

      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/dashboard');
      }
    } catch (e) {
      _addLog('[ERROR] ${e.toString()}', LogType.error);
      _updateStep('Decryption failed', _currentProgress);

      await Future.delayed(const Duration(milliseconds: 1500));
      if (mounted) {
        Navigator.of(context).pop();
      }
    }
  }

  void _updateStep(String step, double progress) {
    if (!mounted) return;
    setState(() {
      _currentStep = step;
      _currentProgress = progress * 100;
    });
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

  String _formatNumber(int num) {
    return num.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]},',
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _veilController.dispose();
    _logScrollController.dispose();
    super.dispose();
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
                const SizedBox(height: 40),

                // Vault animation
                Expanded(
                  flex: 3,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AnimatedBuilder(
                          animation: Listenable.merge([
                            _controller,
                            _veilController,
                          ]),
                          builder: (context, child) {
                            return CustomPaint(
                              size: const Size(210, 210),
                              painter: LightVeilPainter(
                                progress: _currentProgress / 100,
                                focus: _focusAnimation.value,
                                pulse: _pulseAnimation.value,
                                shimmer: _shimmerAnimation.value,
                                isUnlocked: _isUnlocked,
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 28),
                        Text(
                          _currentStep,
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 24,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                            letterSpacing: -0.6,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _isUnlocked
                              ? 'Your private vault is ready.'
                              : 'Decrypting local records with your master key.',
                          style: GoogleFonts.notoSans(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                            height: 1.6,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 40),
                          child: Column(
                            children: [
                              Container(
                                height: 4,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(999),
                                  color: Colors.white.withValues(alpha: 0.06),
                                ),
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: FractionallySizedBox(
                                    widthFactor: (_currentProgress / 100)
                                        .clamp(0.0, 1.0),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(999),
                                        gradient: LinearGradient(
                                          colors: [
                                            AppColors.accentColor
                                                .withValues(alpha: 0.88),
                                            _isUnlocked
                                                ? Colors.white
                                                    .withValues(alpha: 0.92)
                                                : AppColors.primaryColor,
                                          ],
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: AppColors.primaryColor
                                                .withValues(alpha: 0.24),
                                            blurRadius: 18,
                                            spreadRadius: 1,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 14),
                              Text(
                                '${_currentProgress.toStringAsFixed(0)}% complete',
                                style: GoogleFonts.notoSans(
                                  fontSize: 13,
                                  color: AppColors.textMuted,
                                  letterSpacing: 0.2,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                Expanded(
                  flex: 2,
                  child: Container(
                    margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                    padding: const EdgeInsets.fromLTRB(18, 18, 18, 12),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.03),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color:
                            AppColors.softBorderColor.withValues(alpha: 0.85),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Status trace',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary,
                            letterSpacing: 0.3,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'A quiet view of each step while the vault opens.',
                          style: GoogleFonts.notoSans(
                            fontSize: 12,
                            color: AppColors.textMuted,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Expanded(
                          child: ListView.builder(
                            controller: _logScrollController,
                            itemCount: _logs.length,
                            itemBuilder: (context, index) {
                              final log = _logs[index];
                              return Container(
                                margin: const EdgeInsets.only(bottom: 10),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.02),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: _getLogColor(log.type)
                                        .withValues(alpha: 0.18),
                                  ),
                                ),
                                child: Text(
                                  log.message,
                                  style: GoogleFonts.notoSans(
                                    fontSize: 12,
                                    color: _getLogColor(log.type),
                                    height: 1.45,
                                  ),
                                ),
                              );
                            },
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

  Color _getLogColor(LogType type) {
    switch (type) {
      case LogType.info:
        return AppColors.textSecondary;
      case LogType.highlight:
        return AppColors.primaryColor;
      case LogType.active:
        return AppColors.warningColor;
      case LogType.success:
        return AppColors.successColor;
      case LogType.error:
        return AppColors.dangerColor;
    }
  }
}

class LightVeilPainter extends CustomPainter {
  final double progress;
  final double focus;
  final double pulse;
  final double shimmer;
  final bool isUnlocked;

  LightVeilPainter({
    required this.progress,
    required this.focus,
    required this.pulse,
    required this.shimmer,
    required this.isUnlocked,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final double glowRadius = size.width * 0.34;
    final double outerRadius = size.width * 0.44;
    final double pulseShift = (pulse - 0.5) * 14;
    final double veilOpacity = (0.28 + progress * 0.34).clamp(0.0, 0.65);

    final Rect glowRect = Rect.fromCenter(
      center: center.translate(0, -4),
      width: size.width * (0.78 + focus * 0.08),
      height: size.height * (0.92 + focus * 0.06),
    );

    final Paint ambientGlow = Paint()
      ..shader = RadialGradient(
        colors: [
          AppColors.primaryColor.withValues(alpha: 0.18 + progress * 0.12),
          AppColors.accentColor.withValues(alpha: 0.08 + progress * 0.08),
          Colors.transparent,
        ],
        stops: const [0.0, 0.42, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: outerRadius + 22))
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 36);

    canvas.drawCircle(center, outerRadius + 10, ambientGlow);

    final Paint veilPaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(0, -0.08),
        radius: 0.92,
        colors: [
          Colors.white.withValues(alpha: 0.10 + progress * 0.08),
          AppColors.accentColor.withValues(alpha: veilOpacity),
          AppColors.primaryColor.withValues(alpha: 0.12 + progress * 0.08),
          Colors.transparent,
        ],
        stops: const [0.0, 0.18, 0.56, 1.0],
      ).createShader(glowRect);

    final RRect veil = RRect.fromRectAndRadius(
      glowRect,
      Radius.elliptical(glowRect.width * 0.48, glowRect.height * 0.48),
    );
    canvas.drawRRect(veil, veilPaint);

    final Paint innerGlow = Paint()
      ..shader = RadialGradient(
        colors: [
          Colors.white.withValues(alpha: isUnlocked ? 0.62 : 0.28),
          AppColors.accentColor.withValues(alpha: 0.18 + progress * 0.14),
          Colors.transparent,
        ],
        stops: const [0.0, 0.24, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: glowRadius));

    canvas.drawCircle(center, glowRadius * (0.32 + focus * 0.08), innerGlow);

    final Paint haloPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..color = Colors.white.withValues(alpha: 0.08 + progress * 0.12);

    canvas.drawOval(
      Rect.fromCenter(
        center: center.translate(0, pulseShift),
        width: size.width * 0.54,
        height: size.height * 0.68,
      ),
      haloPaint,
    );

    canvas.drawOval(
      Rect.fromCenter(
        center: center.translate(0, -pulseShift * 0.8),
        width: size.width * 0.66,
        height: size.height * 0.80,
      ),
      haloPaint
        ..color =
            AppColors.primaryColor.withValues(alpha: 0.10 + progress * 0.10),
    );

    final Rect shimmerRect = Rect.fromLTWH(0, 0, size.width, size.height);
    final Paint shimmerPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment(-1.0 + shimmer * 0.7, -0.3),
        end: Alignment(1.0 + shimmer * 0.7, 0.5),
        colors: [
          Colors.transparent,
          Colors.white.withValues(alpha: 0.0),
          Colors.white.withValues(alpha: 0.12 + progress * 0.05),
          Colors.transparent,
        ],
        stops: const [0.0, 0.36, 0.52, 1.0],
      ).createShader(shimmerRect)
      ..blendMode = BlendMode.screen;

    canvas.save();
    canvas.clipRRect(veil);
    canvas.drawRect(shimmerRect, shimmerPaint);
    canvas.restore();

    if (isUnlocked) {
      final Paint confirmationPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.2
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..color = Colors.white.withValues(alpha: 0.92);

      final Path checkPath = Path()
        ..moveTo(center.dx - 16, center.dy + 2)
        ..lineTo(center.dx - 4, center.dy + 14)
        ..lineTo(center.dx + 18, center.dy - 12);
      canvas.drawPath(checkPath, confirmationPaint);
    }
  }

  @override
  bool shouldRepaint(LightVeilPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.focus != focus ||
        oldDelegate.pulse != pulse ||
        oldDelegate.shimmer != shimmer ||
        oldDelegate.isUnlocked != isUnlocked;
  }
}

class LogEntry {
  final String message;
  final LogType type;

  LogEntry(this.message, this.type);
}

enum LogType { info, highlight, active, success, error }
