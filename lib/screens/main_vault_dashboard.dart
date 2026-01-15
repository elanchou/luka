import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/vault_provider.dart';
import '../models/secret_model.dart';
import 'activity_log_screen.dart';
import 'system_settings_screen.dart';
import '../widgets/custom_bottom_nav_bar.dart';
import '../widgets/gradient_background.dart';
import '../widgets/vault_header.dart';

class MainVaultDashboard extends StatefulWidget {
  const MainVaultDashboard({super.key});

  @override
  State<MainVaultDashboard> createState() => _MainVaultDashboardState();
}

class _MainVaultDashboardState extends State<MainVaultDashboard> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const _DashboardHome(),
    const ActivityLogBody(),
    const SystemSettingsBody(),
  ];

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF13b6ec);
    const backgroundDark = Color(0xFF101d22);

    final bottomPadding = MediaQuery.of(context).padding.bottom + 8.0;
    final navBarHeight = 80.0 + bottomPadding;

    return Scaffold(
      backgroundColor: backgroundDark,
      body: Stack(
        children: [
          // Ambient Background Glows (Global)
          const GradientBackground(),

          // Main Content
          IndexedStack(
            index: _currentIndex,
            children: _pages.map((page) {
              // Ensure bottom padding for tab bar
              return Padding(
                padding: EdgeInsets.only(bottom: navBarHeight), // Space for bottom bar
                child: page,
              );
            }).toList(),
          ),

          // Bottom Navigation & FAB
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: CustomBottomNavBar(
              currentIndex: _currentIndex,
              onTap: (index) => setState(() => _currentIndex = index),
            ),
          ),

          // FAB (Only on Home)
          if (_currentIndex == 0)
            Positioned(
              bottom: 96 + bottomPadding,
              right: 24,
              child: Material(
                color: primaryColor,
                shape: const CircleBorder(),
                elevation: 10,
                shadowColor: primaryColor.withOpacity(0.4),
                child: InkWell(
                  onTap: () {
                    Navigator.pushNamed(context, '/add-secret-1');
                  },
                  customBorder: const CircleBorder(),
                  child: Container(
                    width: 56,
                    height: 56,
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.add,
                      color: backgroundDark,
                      size: 32,
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
    const primaryColor = Color(0xFF13b6ec);

    return SafeArea(
      bottom: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header Section
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
            child: Column(
              children: [
                const VaultHeader(),
                const SizedBox(height: 24),
                // Search Bar
                Container(
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.03),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.1),
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Icon(
                        Icons.search,
                        color: Colors.grey[600],
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          onChanged: (value) {
                            context.read<VaultProvider>().setSearchQuery(value);
                          },
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 14,
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Search secrets...',
                            hintStyle: GoogleFonts.spaceGrotesk(
                              fontSize: 14,
                              color: Colors.grey[500],
                              fontWeight: FontWeight.w500,
                            ),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // List Content
          Expanded(
            child: Consumer<VaultProvider>(
              builder: (context, vault, child) {
                if (vault.isLoading) {
                  return const Center(child: CircularProgressIndicator(color: primaryColor));
                }

                if (vault.secrets.isEmpty) {
                  return Center(
                    child: Text(
                      'No secrets yet.\nTap + to add one.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.spaceGrotesk(
                        color: Colors.grey[600],
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 40), // Reduced bottom padding as container has padding
                  itemCount: vault.secrets.length + 1, // +1 for header
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      // Filter Header
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'ALL SECRETS',
                              style: GoogleFonts.spaceGrotesk(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[500],
                                letterSpacing: 1.5,
                              ),
                            ),
                            Text(
                              'Filter',
                              style: GoogleFonts.spaceGrotesk(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: primaryColor,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    final secret = vault.secrets[index - 1];
                    return _VaultItem(
                      secret: secret,
                      route: '/seed-detail',
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _VaultItem extends StatelessWidget {
  final Secret secret;
  final String? route;

  const _VaultItem({
    required this.secret,
    this.route,
  });

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF13b6ec);

    IconData icon;
    switch (secret.type) {
      case SecretType.seedPhrase:
        icon = Icons.account_balance_wallet_outlined;
        break;
      case SecretType.privateKey:
        icon = Icons.vpn_key_outlined;
        break;
      case SecretType.note:
        icon = Icons.sticky_note_2_outlined;
        break;
      default:
        icon = Icons.lock_outline;
    }

    final formattedDate = DateFormat('MMM d').format(secret.createdAt).toUpperCase();

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                // Navigate and pass the secret
                Navigator.pushNamed(
                  context,
                  '/seed-detail',
                  arguments: secret,
                );
              },
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.03),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.08),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.05),
                        ),
                      ),
                      child: Icon(
                        icon,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Flexible(
                                child: Text(
                                  secret.name,
                                  style: GoogleFonts.spaceGrotesk(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Text(
                                formattedDate,
                                style: GoogleFonts.spaceGrotesk(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey[600],
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            secret.typeLabel,
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 12,
                              color: Colors.grey[400],
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
