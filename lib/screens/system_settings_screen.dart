import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/gradient_background.dart';

class SystemSettingsScreen extends StatelessWidget {
  const SystemSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const backgroundDark = Color(0xFF101d22);
    return Scaffold(
      backgroundColor: backgroundDark,
      body: Stack(
        children: [
          const GradientBackground(),
          const SystemSettingsBody(),
        ],
      ),
    );
  }
}

class SystemSettingsBody extends StatelessWidget {
  const SystemSettingsBody({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Back button or placeholder depending on context
                // If in Tab, we might not want it.
                // But for now, let's keep it conditional or simple.
                // Assuming this replaces the previous header.
                const SizedBox(width: 24), // Placeholder if back button removed

                Text(
                  'System Settings',
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

          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              children: [
                const _SettingsSection(
                  title: 'SECURITY',
                  children: [
                    _SettingsTile(
                      icon: Icons.face,
                      title: 'Biometric Unlock',
                      trailing: _SettingsSwitch(value: true),
                    ),
                    _SettingsTile(
                      icon: Icons.timer_outlined,
                      title: 'Auto-Lock Timer',
                      trailing: _TrailingTextWithArrow(text: 'Immediate'),
                    ),
                    _SettingsTile(
                      icon: Icons.lock_reset,
                      title: 'Master Password',
                      trailing: _TrailingArrow(),
                      isLast: true,
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                _SettingsSection(
                  title: 'BACKUP & DATA',
                  children: [
                    const _SettingsTile(
                      icon: Icons.cloud_sync_outlined,
                      title: 'Cloud Sync',
                      subtitle: 'ENCRYPTED',
                      trailing: _SettingsSwitch(value: false),
                    ),
                    _SettingsTile(
                      icon: Icons.output,
                      title: 'Export Seed Vault',
                      trailing: const _TrailingArrow(),
                      onTap: () {
                        Navigator.pushNamed(context, '/export-progress');
                      },
                    ),
                    const _SettingsTile(
                      icon: Icons.cleaning_services_outlined,
                      title: 'Clear Local Cache',
                      trailing: _TrailingArrow(),
                      isLast: true,
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                const _SettingsSection(
                  title: 'APPEARANCE',
                  children: [
                    _SettingsTile(
                      icon: Icons.contrast,
                      title: 'Theme',
                      trailing: _TrailingTextWithArrow(text: 'Dark'),
                    ),
                    _SettingsTile(
                      icon: Icons.vibration,
                      title: 'Haptic Feedback',
                      trailing: _SettingsSwitch(value: true),
                      isLast: true,
                    ),
                  ],
                ),

                const SizedBox(height: 32),

                // Footer
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.verified_user,
                      size: 16,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'VAULT SECURE SYSTEM V2.1',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[600],
                        letterSpacing: 1.5,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SettingsSection({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16, bottom: 8),
          child: Text(
            title,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.grey[500],
              letterSpacing: 1.0,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF1c292e),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.white.withOpacity(0.05),
            ),
          ),
          child: Column(
            children: children,
          ),
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
                  decoration: BoxDecoration(
                    color: const Color(0xFF283539),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    color: primaryColor,
                    size: 20,
                  ),
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

  const _SettingsSwitch({required this.value});

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF13b6ec);

    return Container(
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
    );
  }
}

class _TrailingArrow extends StatelessWidget {
  const _TrailingArrow();

  @override
  Widget build(BuildContext context) {
    return Icon(
      Icons.chevron_right,
      color: Colors.grey[600],
      size: 20,
    );
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
