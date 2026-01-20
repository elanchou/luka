import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import '../widgets/gradient_background.dart';
import '../services/master_key_service.dart';
import '../providers/vault_provider.dart';
import '../widgets/error_snackbar.dart';

class SystemSettingsScreen extends StatefulWidget {
  const SystemSettingsScreen({super.key});

  @override
  State<SystemSettingsScreen> createState() => _SystemSettingsScreenState();
}

class _SystemSettingsScreenState extends State<SystemSettingsScreen> {
  final MasterKeyService _masterKeyService = MasterKeyService();
  SecurityLevel _currentSecurityLevel = SecurityLevel.standard;
  bool _hasPassword = false;
  bool _isLoading = true;
  bool _hapticsEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      final hasPassword = await _masterKeyService.hasPassword();
      final level = await _masterKeyService.getSecurityLevel();
      setState(() {
        _hasPassword = hasPassword;
        _currentSecurityLevel = level;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const backgroundDark = Color(0xFF101d22);
    return Scaffold(
      backgroundColor: backgroundDark,
      body: Stack(
        children: [
          const GradientBackground(),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const SizedBox(width: 24),
                      Text(
                        'Settings',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: -0.2,
                        ),
                      ),
                      const SizedBox(width: 24),
                    ],
                  ),
                ),
                if (_isLoading)
                  const Expanded(
                    child: Center(
                      child: CircularProgressIndicator(color: Color(0xFF13b6ec)),
                    ),
                  )
                else
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      children: [
                        _SettingsSection(
                          title: 'SECURITY',
                          children: [
                            if (_hasPassword)
                              _SettingsTile(
                                icon: PhosphorIconsBold.lock,
                                title: 'Change Master Password',
                                subtitle: 'PASSWORD PROTECTED',
                                trailing: const _TrailingArrow(),
                                onTap: () async {
                                  final result = await Navigator.pushNamed(
                                    context,
                                    '/change-master-password',
                                  );
                                  if (result == true) {
                                    _loadSettings();
                                  }
                                },
                              ),
                            if (_hasPassword)
                              _SettingsTile(
                                icon: PhosphorIconsBold.shieldCheck,
                                title: 'Security Level',
                                trailing: _TrailingTextWithArrow(
                                  text: _currentSecurityLevel.displayName,
                                ),
                                onTap: () => _showSecurityInfo(),
                              ),
                            const _SettingsTile(
                              icon: PhosphorIconsBold.timer,
                              title: 'Auto-Lock Timer',
                              trailing: _TrailingTextWithArrow(text: 'Immediate'),
                              isLast: true,
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        _SettingsSection(
                          title: 'BACKUP & DATA',
                          children: [
                            _SettingsTile(
                              icon: PhosphorIconsBold.fileArrowUp,
                              title: 'Backup Vault File',
                              subtitle: 'ENCRYPTED FILE',
                              trailing: const _TrailingArrow(),
                              onTap: () async {
                                final vaultProvider = Provider.of<VaultProvider>(context, listen: false);
                                final file = await vaultProvider.getEncryptedVaultFile();
                                if (file != null) {
                                  await Share.shareXFiles([XFile(file.path)], text: 'Vault Backup');
                                } else {
                                  if (mounted) {
                                    ErrorSnackbar.show(context, message: 'Vault file not found');
                                  }
                                }
                              },
                            ),
                            _SettingsTile(
                              icon: PhosphorIconsBold.broom,
                              title: 'Clear Activity Logs',
                              subtitle: 'WIPE HISTORY',
                              trailing: const _TrailingArrow(),
                              onTap: () async {
                                final confirm = await showDialog<bool>(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    backgroundColor: const Color(0xFF1a2c32),
                                    title: Text('Clear Logs?', style: GoogleFonts.spaceGrotesk(color: Colors.white, fontWeight: FontWeight.bold)),
                                    content: Text('Delete all activity history? This cannot be undone.', style: GoogleFonts.notoSans(color: Colors.grey[300])),
                                    actions: [
                                      TextButton(onPressed: () => Navigator.pop(context, false), child: Text('Cancel', style: GoogleFonts.spaceGrotesk(color: Colors.grey[400]))),
                                      TextButton(
                                        onPressed: () => Navigator.pop(context, true),
                                        child: Text('Clear', style: GoogleFonts.spaceGrotesk(color: Colors.red)),
                                      ),
                                    ],
                                  ),
                                );

                                if (confirm == true && mounted) {
                                  final vaultProvider = Provider.of<VaultProvider>(context, listen: false);
                                  await vaultProvider.clearLogs();
                                  if (mounted) {
                                    SuccessSnackbar.show(context, message: 'Activity logs cleared');
                                  }
                                }
                              },
                              isLast: true,
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        _SettingsSection(
                          title: 'APPEARANCE',
                          children: [
                            const _SettingsTile(
                              icon: PhosphorIconsBold.palette,
                              title: 'Theme',
                              trailing: _TrailingTextWithArrow(text: 'Dark'),
                            ),
                            _SettingsTile(
                              icon: PhosphorIconsBold.waveform,
                              title: 'Haptic Feedback',
                              trailing: _SettingsSwitch(
                                value: _hapticsEnabled,
                                onChanged: (val) {
                                  setState(() => _hapticsEnabled = val);
                                  HapticFeedback.lightImpact();
                                },
                              ),
                              isLast: true,
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        _SettingsSection(
                          title: 'ABOUT',
                          children: [
                            const _SettingsTile(
                              icon: PhosphorIconsBold.info,
                              title: 'App Version',
                              trailing: _TrailingText(text: '1.0.0'),
                            ),
                            _SettingsTile(
                              icon: PhosphorIconsBold.shieldCheck,
                              title: 'Privacy Policy',
                              trailing: const _TrailingArrow(),
                              onTap: () => SuccessSnackbar.show(context, message: 'Privacy Policy is locally enforced.'),
                            ),
                            _SettingsTile(
                              icon: PhosphorIconsBold.fileText,
                              title: 'Terms of Service',
                              trailing: const _TrailingArrow(),
                              onTap: () => SuccessSnackbar.show(context, message: 'Terms of Service: Your data, your responsibility.'),
                              isLast: true,
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        _SettingsSection(
                          title: 'DANGER ZONE',
                          color: const Color(0xFFff4d4d),
                          children: [
                            _SettingsTile(
                              icon: PhosphorIconsBold.warningCircle,
                              title: 'Factory Reset Vault',
                              subtitle: 'WIPE ALL DATA',
                              trailing: const _TrailingArrow(),
                              onTap: () {
                                HapticFeedback.heavyImpact();
                                Navigator.pushNamed(context, '/reset-vault');
                              },
                              isLast: true,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showSecurityInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1a2c32),
        title: Text(
          'Security Level',
          style: GoogleFonts.spaceGrotesk(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Current Level: ${_currentSecurityLevel.displayName}',
              style: GoogleFonts.spaceGrotesk(
                color: const Color(0xFF13b6ec),
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Iterations: ${_formatNumber(_currentSecurityLevel.iterations)}',
              style: GoogleFonts.notoSans(
                color: Colors.grey[400],
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'To change security level, use "Change Master Password" above.',
              style: GoogleFonts.notoSans(
                color: Colors.grey[500],
                fontSize: 12,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'OK',
              style: GoogleFonts.spaceGrotesk(
                color: const Color(0xFF13b6ec),
              ),
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

class _SettingsSection extends StatelessWidget {
  final String title;
  final List<Widget> children;
  final Color? color;

  const _SettingsSection({
    required this.title,
    required this.children,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final titleColor = color ?? Colors.grey[600];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            title,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: titleColor,
              letterSpacing: 1.5,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF1a2c32),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: color?.withValues(alpha: 0.3) ?? const Color(0xFF283539),
            ),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget trailing;
  final bool isLast;
  final VoidCallback? onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.trailing,
    this.isLast = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF13b6ec);
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    color: Color(0xFF283539),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: primaryColor, size: 20),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                      if (subtitle != null)
                        Text(
                          subtitle!,
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 11,
                            color: Colors.grey[500],
                            letterSpacing: 1.0,
                          ),
                        ),
                    ],
                  ),
                ),
                trailing,
              ],
            ),
          ),
          if (!isLast)
            Divider(
              height: 1,
              thickness: 1,
              indent: 68,
              color: const Color(0xFF283539),
            ),
        ],
      ),
    );
  }
}

class _SettingsSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool>? onChanged;
  const _SettingsSwitch({required this.value, this.onChanged});

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF13b6ec);
    return GestureDetector(
      onTap: () => onChanged?.call(!value),
      child: Container(
        width: 48,
        height: 28,
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: value ? primaryColor : const Color(0xFF344247),
          borderRadius: BorderRadius.circular(14),
        ),
        alignment: value ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          width: 20,
          height: 20,
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}

class _TrailingArrow extends StatelessWidget {
  const _TrailingArrow();

  @override
  Widget build(BuildContext context) {
    return Icon(PhosphorIconsBold.caretRight, color: Colors.grey[600], size: 20);
  }
}

class _TrailingTextWithArrow extends StatelessWidget {
  final String text;
  const _TrailingTextWithArrow({required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          text,
          style: GoogleFonts.notoSans(
            fontSize: 14,
            color: Colors.grey[500],
          ),
        ),
        const SizedBox(width: 4),
        const _TrailingArrow(),
      ],
    );
  }
}

class _TrailingText extends StatelessWidget {
  final String text;
  const _TrailingText({required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: GoogleFonts.notoSans(
        fontSize: 14,
        color: Colors.grey[500],
      ),
    );
  }
}

