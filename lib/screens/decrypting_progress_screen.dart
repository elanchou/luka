import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;
import '../widgets/gradient_background.dart';
import '../providers/vault_provider.dart';
import '../services/master_key_service.dart';

class DecryptingProgressScreen extends StatefulWidget {
  final String masterPassword;
  
  const DecryptingProgressScreen({super.key, required this.masterPassword});

  @override
  State<DecryptingProgressScreen> createState() => _DecryptingProgressScreenState();
}

class _DecryptingProgressScreenState extends State<DecryptingProgressScreen> with TickerProviderStateMixin {
  late AnimationController _controller;
  late AnimationController _vaultController;
  late Animation<double> _progressAnimation;
  late Animation<double> _doorAnimation;
  late Animation<double> _lockRotation;
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

    _vaultController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _progressAnimation = Tween<double>(begin: 0.0, end: 100.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _doorAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _vaultController, curve: Curves.easeInOut),
    );

    _lockRotation = Tween<double>(begin: 0.0, end: 2 * math.pi).animate(
      CurvedAnimation(
        parent: _vaultController,
        curve: const Interval(0.0, 0.3, curve: Curves.easeOut),
      ),
    );

    _controller.addListener(() {
      setState(() {
        _currentProgress = _progressAnimation.value;
      });
      
      if (_controller.value >= 0.95 && !_isUnlocked) {
        _isUnlocked = true;
        _vaultController.forward();
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_decryptStarted) {
      _decryptStarted = true;
      _startDecryptProcess();
    }
  }

  Future<void> _startDecryptProcess() async {
    try {
      // Step 1: 读取配置
      _updateStep('Reading vault configuration...', 0.0);
      _addLog('[INFO] Reading vault configuration', LogType.info);
      await Future.delayed(const Duration(milliseconds: 200));
      _controller.animateTo(0.1, duration: const Duration(milliseconds: 200));

      // Step 2: 读取 salt 和 iterations
      _updateStep('Loading security parameters...', 0.1);
      _addLog('[INIT] Loading salt and iterations', LogType.info);
      final masterKeyService = MasterKeyService();
      final securityLevel = await masterKeyService.getSecurityLevel();
      await Future.delayed(const Duration(milliseconds: 150));
      _controller.animateTo(0.2, duration: const Duration(milliseconds: 150));
      
      _addLog('[OK] Security Level: ${securityLevel.displayName} (${_formatNumber(securityLevel.iterations)} iterations)', LogType.highlight);

      // Step 3: PBKDF2 密钥派生
      _updateStep('Deriving encryption key (PBKDF2)...', 0.2);
      _addLog('[EXEC] Starting PBKDF2 key derivation...', LogType.active);
      
      final keyDerivationStart = DateTime.now();
      
      _controller.animateTo(0.3, duration: const Duration(milliseconds: 100));
      await Future.delayed(const Duration(milliseconds: 100));
      
      // 实际执行 PBKDF2
      if (mounted) {
        final vaultProvider = Provider.of<VaultProvider>(context, listen: false);
        
        _controller.animateTo(0.7, duration: Duration(milliseconds: securityLevel.iterations ~/ 1000));
        
        await vaultProvider.reinitialize(widget.masterPassword);
        
        final keyDerivationTime = DateTime.now().difference(keyDerivationStart);
        _addLog('[OK] Key derived in ${keyDerivationTime.inMilliseconds}ms', LogType.success);
      }

      _controller.animateTo(0.75, duration: const Duration(milliseconds: 100));

      // Step 4: 读取加密文件
      _updateStep('Reading encrypted vault...', 0.75);
      _addLog('[READ] Loading vault.enc', LogType.info);
      await Future.delayed(const Duration(milliseconds: 150));
      _controller.animateTo(0.8, duration: const Duration(milliseconds: 150));

      final vaultProvider = Provider.of<VaultProvider>(context, listen: false);
      final secretCount = vaultProvider.secretCount;
      _addLog('[OK] Found ${secretCount} encrypted secrets', LogType.highlight);

      // Step 5: AES 解密
      _updateStep('Decrypting vault (AES-256-CBC)...', 0.8);
      _addLog('[DECRYPT] Using AES-256-CBC algorithm', LogType.active);
      await Future.delayed(const Duration(milliseconds: 200));
      _controller.animateTo(0.9, duration: const Duration(milliseconds: 200));
      
      _addLog('[OK] ${secretCount} secrets decrypted successfully', LogType.success);

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
    _vaultController.dispose();
    _logScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const backgroundDark = Color(0xFF101d22);
    const primaryColor = Color(0xFF13b6ec);
    const successColor = Color(0xFF00d68f);

    return Scaffold(
      backgroundColor: backgroundDark,
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
                          animation: Listenable.merge([_doorAnimation, _lockRotation]),
                          builder: (context, child) {
                            return CustomPaint(
                              size: const Size(150, 150),
                              painter: VaultDoorPainter(
                                doorProgress: _doorAnimation.value,
                                lockRotation: _lockRotation.value,
                                isUnlocked: _isUnlocked,
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 32),
                        
                        // Current step
                        Text(
                          _currentStep,
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        
                        // Progress bar
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 40),
                          child: Column(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: LinearProgressIndicator(
                                  value: _currentProgress / 100,
                                  backgroundColor: Colors.white.withOpacity(0.1),
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    _isUnlocked ? successColor : primaryColor,
                                  ),
                                  minHeight: 8,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '${_currentProgress.toStringAsFixed(0)}%',
                                style: GoogleFonts.spaceGrotesk(
                                  fontSize: 14,
                                  color: Colors.grey[400],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                // Log console
                Expanded(
                  flex: 2,
                  child: Container(
                    margin: const EdgeInsets.all(20),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.1),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.terminal,
                              color: primaryColor,
                              size: 16,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'DECRYPTION LOG',
                              style: GoogleFonts.spaceGrotesk(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[500],
                                letterSpacing: 1.2,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Expanded(
                          child: ListView.builder(
                            controller: _logScrollController,
                            itemCount: _logs.length,
                            itemBuilder: (context, index) {
                              final log = _logs[index];
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 4),
                                child: Text(
                                  log.message,
                                  style: GoogleFonts.jetBrainsMono(
                                    fontSize: 11,
                                    color: _getLogColor(log.type),
                                    height: 1.4,
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
        return Colors.grey[400]!;
      case LogType.highlight:
        return const Color(0xFF13b6ec);
      case LogType.active:
        return Colors.orange[300]!;
      case LogType.success:
        return const Color(0xFF00d68f);
      case LogType.error:
        return Colors.red[400]!;
    }
  }
}

class VaultDoorPainter extends CustomPainter {
  final double doorProgress;
  final double lockRotation;
  final bool isUnlocked;

  VaultDoorPainter({
    required this.doorProgress,
    required this.lockRotation,
    required this.isUnlocked,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 10;
    const primaryColor = Color(0xFF13b6ec);
    const successColor = Color(0xFF00d68f);
    const surfaceColor = Color(0xFF1a2c32);

    // Draw vault body
    final bodyPaint = Paint()
      ..color = surfaceColor
      ..style = PaintingStyle.fill;
    
    canvas.drawCircle(center, radius, bodyPaint);

    // Draw vault outer ring
    final outerRingPaint = Paint()
      ..color = isUnlocked ? successColor : primaryColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    
    canvas.drawCircle(center, radius, outerRingPaint);

    // Draw inner decorative rings
    final innerRingPaint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    
    canvas.drawCircle(center, radius - 10, innerRingPaint);
    canvas.drawCircle(center, radius - 20, innerRingPaint);

    // Draw vault door
    canvas.save();
    canvas.translate(center.dx, center.dy);
    final doorAngle = doorProgress * math.pi * 0.5;
    canvas.rotate(doorAngle);
    
    final doorPaint = Paint()
      ..color = surfaceColor
      ..style = PaintingStyle.fill;
    
    final doorPath = Path()
      ..moveTo(0, -radius)
      ..arcTo(
        Rect.fromCircle(center: Offset.zero, radius: radius),
        -math.pi / 2,
        math.pi,
        false,
      )
      ..lineTo(0, -radius)
      ..close();
    
    canvas.drawPath(doorPath, doorPaint);
    
    final doorBorderPaint = Paint()
      ..color = isUnlocked ? successColor : primaryColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    
    canvas.drawPath(doorPath, doorBorderPaint);
    canvas.restore();

    // Draw lock/dial
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(lockRotation);
    
    final lockPaint = Paint()
      ..color = isUnlocked ? successColor : primaryColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    
    canvas.drawCircle(Offset.zero, 15, lockPaint);
    canvas.drawCircle(Offset.zero, 8, lockPaint);
    
    for (int i = 0; i < 8; i++) {
      final angle = (math.pi * 2 / 8) * i;
      final start = Offset(math.cos(angle) * 15, math.sin(angle) * 15);
      final end = Offset(math.cos(angle) * 20, math.sin(angle) * 20);
      canvas.drawLine(start, end, lockPaint);
    }
    
    canvas.drawLine(Offset.zero, const Offset(0, -25), lockPaint);
    canvas.restore();

    if (isUnlocked) {
      final glowPaint = Paint()
        ..color = successColor.withOpacity(0.2)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20);
      canvas.drawCircle(center, radius + 5, glowPaint);
    }
  }

  @override
  bool shouldRepaint(VaultDoorPainter oldDelegate) {
    return oldDelegate.doorProgress != doorProgress ||
           oldDelegate.lockRotation != lockRotation ||
           oldDelegate.isUnlocked != isUnlocked;
  }
}

enum LogType { info, highlight, active, success, error }

class LogEntry {
  final String message;
  final LogType type;

  LogEntry(this.message, this.type);
}
