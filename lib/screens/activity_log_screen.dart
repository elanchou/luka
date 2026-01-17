import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../widgets/gradient_background.dart';
import '../widgets/vault_header.dart';

class ActivityLogScreen extends StatelessWidget {
  const ActivityLogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const backgroundDark = Color(0xFF101d22);
    return const Scaffold(
      backgroundColor: backgroundDark,
      body: Stack(
        children: [
          GradientBackground(),
          ActivityLogBody(),
        ],
      ),
    );
  }
}

class ActivityLogBody extends StatefulWidget {
  const ActivityLogBody({super.key});

  @override
  State<ActivityLogBody> createState() => _ActivityLogBodyState();
}

class _ActivityLogBodyState extends State<ActivityLogBody> {
  int _selectedFilterIndex = 0;
  final List<String> _filters = ['All', 'Security', 'Access', 'Transfers'];

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF13b6ec);
    const successColor = Color(0xFF00d68f);
    const dangerColor = Color(0xFFff4d4d);

    return SafeArea(
      child: Column(
        children: [
          // Header
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 16, 20, 16),
            child: VaultHeader(title: 'Activity Log', showUserIcon: false),
          ),

          // Filters
          SizedBox(
            height: 48,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: _filters.length,
              itemBuilder: (context, index) {
                final isSelected = _selectedFilterIndex == index;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: InkWell(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      setState(() => _selectedFilterIndex = index);
                    },
                    borderRadius: BorderRadius.circular(20),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? primaryColor.withValues(alpha: 0.1) : Colors.white.withValues(alpha: 0.03),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected ? primaryColor.withValues(alpha: 0.5) : Colors.white.withValues(alpha: 0.05),
                        ),
                      ),
                      child: Center(
                        child: Text(
                          _filters[index],
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 13,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                            color: isSelected ? primaryColor : Colors.grey[500],
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 16),

          // Timeline
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              children: [
                // Today Section
                const _DateDivider(label: 'TODAY'),
                const _TimelineItem(
                  title: 'New Secret Added',
                  time: '14:02',
                  description: 'Ethereum Main Wallet',
                  color: successColor,
                  isFirst: true,
                ),
                const _TimelineItem(
                  title: 'Vault Accessed',
                  time: '09:15',
                  description: 'FaceID Verified',
                  icon: PhosphorIconsBold.userFocus,
                  color: successColor,
                ),

                // Yesterday Section
                const SizedBox(height: 16),
                const _DateDivider(label: 'YESTERDAY'),
                const _TimelineItem(
                  title: 'Backup Created',
                  time: '22:45',
                  description: 'Cloud Sync',
                  icon: PhosphorIconsBold.cloudArrowUp,
                  color: primaryColor,
                  isFirst: true,
                ),
                const _TimelineItem(
                  title: 'Failed Attempt',
                  time: '18:30',
                  description: 'Incorrect PIN • 3rd try',
                  color: dangerColor,
                ),
                const _TimelineItem(
                  title: 'Vault Accessed',
                  time: '08:12',
                  description: 'Passcode Verified',
                  color: successColor,
                  isLast: true,
                ),

                const SizedBox(height: 48),

                // Footer
                Column(
                  children: [
                    Icon(
                      PhosphorIconsBold.shieldCheck,
                      color: Colors.white.withValues(alpha: 0.2),
                      size: 24,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'END OF ENCRYPTED LOG',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.white.withValues(alpha: 0.2),
                        letterSpacing: 2.0,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 48),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DateDivider extends StatelessWidget {
  final String label;

  const _DateDivider({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          Text(
            label,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
              letterSpacing: 2.0,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              height: 1,
              color: Colors.white.withValues(alpha: 0.05),
            ),
          ),
        ],
      ),
    );
  }
}

class _TimelineItem extends StatelessWidget {
  final String title;
  final String time;
  final String description;
  final IconData? icon;
  final Color color;
  final bool isFirst;
  final bool isLast;

  const _TimelineItem({
    required this.title,
    required this.time,
    required this.description,
    this.icon,
    required this.color,
    this.isFirst = false,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    const backgroundDark = Color(0xFF101d22);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Timeline Line & Dot
          SizedBox(
            width: 24,
            child: Stack(
              alignment: Alignment.topCenter,
              children: [
                if (!isLast)
                  Positioned(
                    top: isFirst ? 12 : 0,
                    bottom: 0,
                    child: Container(
                      width: 1,
                      color: Colors.white.withValues(alpha: 0.05),
                    ),
                  ),
                if (!isFirst)
                  Positioned(
                    top: 0,
                    height: 12,
                    child: Container(
                      width: 1,
                      color: Colors.white.withValues(alpha: 0.05),
                    ),
                  ),
                Container(
                  margin: const EdgeInsets.only(top: 8),
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: color.withValues(alpha: 0.3),
                        blurRadius: 10,
                      ),
                    ],
                    border: Border.all(
                      color: backgroundDark,
                      width: 2,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          // Content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        time,
                        style: GoogleFonts.spaceMono(
                          fontSize: 11,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      if (icon != null) ...[
                        Icon(
                          icon,
                          size: 14,
                          color: Colors.grey[500],
                        ),
                        const SizedBox(width: 6),
                      ],
                      Text(
                        description,
                        style: GoogleFonts.notoSans(
                          fontSize: 13,
                          color: Colors.grey[500],
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

