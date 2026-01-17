import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../widgets/gradient_background.dart';
import '../providers/vault_provider.dart';
import '../models/activity_log_model.dart';

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
  final List<String> _filters = ['All', 'Security', 'Access', 'System'];

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
              children: [
                IconButton(
                  icon: const Icon(PhosphorIconsBold.arrowLeft, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
                Expanded(
                  child: Center(
                    child: Text(
                      'Activity Log',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 48), // Spacer for centering
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
            child: Consumer<VaultProvider>(
              builder: (context, provider, child) {
                final logs = provider.logs.where((log) {
                  if (_selectedFilterIndex == 0) return true;
                  final filterCategory = ActivityCategory.values[_selectedFilterIndex - 1];
                  return log.category == filterCategory;
                }).toList();

                if (logs.isEmpty) {
                  return Center(
                    child: Text(
                      'No activities found',
                      style: GoogleFonts.notoSans(color: Colors.grey[600]),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  itemCount: logs.length,
                  itemBuilder: (context, index) {
                    final log = logs[index];
                    final showDivider = index == 0 ||
                                       !_isSameDay(log.timestamp, logs[index-1].timestamp);

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (showDivider)
                          _DateDivider(label: _getRelativeDate(log.timestamp)),
                        _TimelineItem(
                          title: log.title,
                          time: DateFormat('HH:mm').format(log.timestamp),
                          description: log.description,
                          icon: _getCategoryIcon(log.category),
                          color: log.isSuccess ? successColor : dangerColor,
                          isFirst: showDivider,
                          isLast: index == logs.length - 1 ||
                                 !_isSameDay(log.timestamp, logs[index+1].timestamp),
                        ),
                      ],
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

  bool _isSameDay(DateTime d1, DateTime d2) {
    return d1.year == d2.year && d1.month == d2.month && d1.day == d2.day;
  }

  String _getRelativeDate(DateTime date) {
    final now = DateTime.now();
    if (_isSameDay(date, now)) return 'TODAY';
    if (_isSameDay(date, now.subtract(const Duration(days: 1)))) return 'YESTERDAY';
    return DateFormat('MMM d, yyyy').format(date).toUpperCase();
  }

  IconData _getCategoryIcon(ActivityCategory category) {
    switch (category) {
      case ActivityCategory.security: return PhosphorIconsBold.shieldCheck;
      case ActivityCategory.access: return PhosphorIconsBold.userFocus;
      case ActivityCategory.transfers: return PhosphorIconsBold.swap;
      case ActivityCategory.system: return PhosphorIconsBold.cpu;
    }
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

