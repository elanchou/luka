import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import '../models/secret_model.dart';
import '../providers/sault_provider.dart';
import '../utils/constants.dart';
import '../widgets/custom_bottom_nav_bar.dart';
import '../widgets/gradient_background.dart';
import '../widgets/sault_header.dart';
import 'activity_log_screen.dart';
import 'system_settings_screen.dart';

class MainSaultDashboard extends StatefulWidget {
  const MainSaultDashboard({super.key});

  @override
  State<MainSaultDashboard> createState() => _MainSaultDashboardState();
}

class _MainSaultDashboardState extends State<MainSaultDashboard> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    _DashboardHome(),
    ActivityLogBody(),
    SystemSettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final double bottomPadding = MediaQuery.of(context).padding.bottom + 8.0;
    final double navBarHeight = 84.0 + bottomPadding;

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: Stack(
        children: [
          const GradientBackground(),
          IndexedStack(
            index: _currentIndex,
            children: _pages.map((page) {
              return Padding(
                padding: EdgeInsets.only(bottom: navBarHeight),
                child: page,
              );
            }).toList(),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: CustomBottomNavBar(
              currentIndex: _currentIndex,
              onTap: (index) => setState(() => _currentIndex = index),
            ),
          ),
          if (_currentIndex == 0)
            Positioned(
              bottom: 102 + bottomPadding,
              right: 28,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => Navigator.pushNamed(context, '/add-secret-1'),
                  borderRadius: BorderRadius.circular(24),
                  child: Ink(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          AppColors.primaryColor,
                          AppColors.primaryColor.withValues(alpha: 0.82),
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.24),
                          blurRadius: 28,
                          offset: const Offset(0, 16),
                        ),
                      ],
                    ),
                    child: const Icon(
                      PhosphorIconsBold.plus,
                      color: AppColors.backgroundDark,
                      size: 28,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _DashboardHome extends StatelessWidget {
  const _DashboardHome();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Consumer<SaultProvider>(
        builder: (context, vault, _) {
          return ListView(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 36),
            children: [
              const SaultHeader(),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.045),
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: AppColors.softBorderColor),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.22),
                      blurRadius: 32,
                      offset: const Offset(0, 18),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Vault Overview',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textMuted,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      '${vault.secretCount}',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 44,
                        height: 1.0,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                        letterSpacing: -1.8,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      vault.secretCount == 1 ? 'secured item' : 'secured items',
                      style: GoogleFonts.notoSans(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        _StatPill(
                          icon: PhosphorIconsBold.lockKey,
                          label: 'Encrypted',
                        ),
                        const SizedBox(width: 10),
                        _StatPill(
                          icon: PhosphorIconsBold.clockCounterClockwise,
                          label: '${vault.logs.length} logs',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              Container(
                height: 56,
                padding: const EdgeInsets.symmetric(horizontal: 18),
                decoration: BoxDecoration(
                  color: AppColors.backgroundElevated,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: AppColors.softBorderColor),
                ),
                child: Row(
                  children: [
                    const Icon(
                      PhosphorIconsBold.magnifyingGlass,
                      color: AppColors.textMuted,
                      size: 18,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        onChanged: context.read<SaultProvider>().setSearchQuery,
                        style: GoogleFonts.notoSans(
                          color: AppColors.textPrimary,
                          fontSize: 14,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Search your vault',
                          hintStyle: GoogleFonts.notoSans(
                            color: AppColors.textMuted,
                            fontSize: 14,
                          ),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Items',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    '${vault.secrets.length} visible',
                    style: GoogleFonts.notoSans(
                      fontSize: 12,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              if (vault.isLoading)
                const Padding(
                  padding: EdgeInsets.only(top: 48),
                  child: Center(
                    child: CircularProgressIndicator(color: AppColors.primaryColor),
                  ),
                )
              else if (vault.secrets.isEmpty)
                Container(
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.03),
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(color: AppColors.softBorderColor),
                  ),
                  child: Column(
                    children: [
                      const Icon(
                        PhosphorIconsBold.vault,
                        size: 28,
                        color: AppColors.primaryColor,
                      ),
                      const SizedBox(height: 14),
                      Text(
                        'No secrets yet',
                        style: GoogleFonts.spaceGrotesk(
                          color: AppColors.textPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Use the add button to store a seed phrase, private key, or secure note.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.notoSans(
                          color: AppColors.textSecondary,
                          height: 1.6,
                        ),
                      ),
                    ],
                  ),
                )
              else
                ...vault.secrets.map((secret) => _VaultItem(secret: secret)),
            ],
          );
        },
      ),
    );
  }
}

class _VaultItem extends StatelessWidget {
  final Secret secret;

  const _VaultItem({
    required this.secret,
  });

  @override
  Widget build(BuildContext context) {
    final _VaultVisual visual = _visualFor(secret.type);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            HapticFeedback.lightImpact();
            Navigator.pushNamed(
              context,
              '/seed-detail',
              arguments: secret,
            );
          },
          borderRadius: BorderRadius.circular(24),
          child: Ink(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.04),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.softBorderColor),
            ),
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: visual.color.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: visual.color.withValues(alpha: 0.18)),
                    ),
                    child: Icon(
                      visual.icon,
                      color: visual.color,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          secret.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          secret.typeLabel,
                          style: GoogleFonts.notoSans(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          secret.network.isEmpty ? 'Private vault item' : secret.network,
                          style: GoogleFonts.notoSans(
                            fontSize: 12,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    PhosphorIconsBold.caretRight,
                    color: AppColors.textMuted,
                    size: 18,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  _VaultVisual _visualFor(SecretType type) {
    switch (type) {
      case SecretType.seedPhrase:
        return const _VaultVisual(
          icon: PhosphorIconsBold.wallet,
          color: AppColors.primaryColor,
        );
      case SecretType.privateKey:
        return const _VaultVisual(
          icon: PhosphorIconsBold.key,
          color: AppColors.accentColor,
        );
      case SecretType.note:
        return const _VaultVisual(
          icon: PhosphorIconsBold.notepad,
          color: AppColors.warningColor,
        );
      case SecretType.other:
        return const _VaultVisual(
          icon: PhosphorIconsBold.lockKey,
          color: AppColors.textSecondary,
        );
    }
  }
}

class _VaultVisual {
  final IconData icon;
  final Color color;

  const _VaultVisual({
    required this.icon,
    required this.color,
  });
}

class _StatPill extends StatelessWidget {
  final IconData icon;
  final String label;

  const _StatPill({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.03),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.softBorderColor),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 14, color: AppColors.primaryColor),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.notoSans(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
