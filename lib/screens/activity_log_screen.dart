import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/gradient_background.dart';

class ActivityLogScreen extends StatelessWidget {
  const ActivityLogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const backgroundDark = Color(0xFF101d22);
    return Scaffold(
      backgroundColor: backgroundDark,
      body: Stack(
        children: [
          const GradientBackground(),
          const ActivityLogBody(),
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
    const dangerColor = Color(0xFFff3b30);

    return SafeArea(
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // If we are in a tab view, we might not want the back button.
                // We can check if we can pop, or just hide it if it's the root of the tab.
                // For now, let's keep the design but maybe make the back button optional or functional only if not in tab.
                // Assuming this is used in MainDashboard which replaces the route stack or is the root,
                // "Back" might not make sense if it's a tab.
                // Let's assume for the TabBar implementation, we don't want the back button.
                // But the original design had it. I'll make it conditionally visible or just keep it for now.
                // Actually, if I switch tabs, I don't "pop".
                // I'll hide the back button if it's used in the tab context (implied by this refactor).

                // Let's just keep the header simple.
                const SizedBox(width: 24), // Placeholder for alignment if back button removed

                Text(
                  'Activity Log',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 24), // Spacer for centering
              ],
            ),
          ),

          // Filters
          SizedBox(
            height: 48,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              itemCount: _filters.length,
              itemBuilder: (context, index) {
                final isSelected = _selectedFilterIndex == index;
                return Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: ActionChip(
                    label: Text(
                      _filters[index],
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: isSelected ? Colors.white : Colors.grey[400],
                      ),
                    ),
                    backgroundColor: isSelected ? primaryColor : Colors.white.withOpacity(0.05),
                    side: BorderSide.none,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    onPressed: () {
                      setState(() {
                        _selectedFilterIndex = index;
                      });
                    },
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
                  icon: Icons.face,
                  color: successColor,
                ),

                // Yesterday Section
                const SizedBox(height: 16),
                const _DateDivider(label: 'YESTERDAY'),
                const _TimelineItem(
                  title: 'Backup Created',
                  time: '22:45',
                  description: 'Cloud Sync',
                  icon: Icons.cloud_sync_outlined,
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
                      Icons.verified_user_outlined,
                      color: Colors.white.withOpacity(0.3),
                      size: 24,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'END OF ENCRYPTED LOG',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white.withOpacity(0.3),
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
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              height: 1,
              color: Colors.white.withOpacity(0.1),
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
                      color: Colors.white.withOpacity(0.1),
                    ),
                  ),
                if (!isFirst)
                  Positioned(
                    top: 0,
                    height: 12,
                    child: Container(
                      width: 1,
                      color: Colors.white.withOpacity(0.1),
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
                        color: color.withOpacity(0.4),
                        blurRadius: 8,
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
                          fontSize: 12,
                          color: Colors.grey[500],
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
                          color: Colors.grey[400],
                        ),
                        const SizedBox(width: 6),
                      ],
                      Text(
                        description,
                        style: GoogleFonts.notoSans(
                          fontSize: 14,
                          color: Colors.grey[400],
                          fontWeight: FontWeight.w300,
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
