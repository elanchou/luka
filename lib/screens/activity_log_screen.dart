import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import '../models/activity_log_model.dart';
import '../providers/sault_provider.dart';
import '../utils/constants.dart';
import '../widgets/gradient_background.dart';
import '../widgets/sault_header.dart';

class ActivityLogScreen extends StatelessWidget {
  const ActivityLogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
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
  final List<String> _filters = <String>['All', 'Security', 'Access', 'System'];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Consumer<SaultProvider>(
        builder: (context, provider, _) {
          final List<ActivityLog> logs = provider.logs.where((log) {
            if (_selectedFilterIndex == 0) return true;
            final ActivityCategory filterCategory =
                ActivityCategory.values[_selectedFilterIndex - 1];
            return log.category == filterCategory;
          }).toList();

          return ListView(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
            children: [
              const SaultHeader(title: 'Activity', showUserIcon: false),
              const SizedBox(height: 18),
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.04),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppColors.softBorderColor),
                ),
                child: Text(
                  'A local record of authentication, exports, updates, and operational security events.',
                  style: GoogleFonts.notoSans(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                    height: 1.5,
                  ),
                ),
              ),
              const SizedBox(height: 18),
              SizedBox(
                height: 42,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _filters.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 10),
                  itemBuilder: (context, index) {
                    final bool isSelected = _selectedFilterIndex == index;
                    return ChoiceChip(
                      selected: isSelected,
                      showCheckmark: false,
                      label: Text(
                        _filters[index],
                        style: GoogleFonts.spaceGrotesk(
                          color: isSelected ? AppColors.backgroundDark : AppColors.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      selectedColor: AppColors.primaryColor,
                      backgroundColor: Colors.white.withValues(alpha: 0.04),
                      side: const BorderSide(color: AppColors.softBorderColor),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                      onSelected: (_) => setState(() => _selectedFilterIndex = index),
                    );
                  },
                ),
              ),
              const SizedBox(height: 22),
              if (logs.isEmpty)
                Container(
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.03),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: AppColors.softBorderColor),
                  ),
                  child: Column(
                    children: [
                      const Icon(
                        PhosphorIconsBold.clockCounterClockwise,
                        color: AppColors.primaryColor,
                        size: 28,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'No activity yet',
                        style: GoogleFonts.spaceGrotesk(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w700,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                )
              else
                ...List<Widget>.generate(logs.length, (index) {
                  final ActivityLog log = logs[index];
                  final bool showDate = index == 0 ||
                      !_isSameDay(log.timestamp, logs[index - 1].timestamp);
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (showDate)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12, top: 4),
                          child: Text(
                            _getRelativeDate(log.timestamp),
                            style: GoogleFonts.spaceGrotesk(
                              color: AppColors.textMuted,
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      _ActivityTile(log: log),
                      const SizedBox(height: 12),
                    ],
                  );
                }),
            ],
          );
        },
      ),
    );
  }

  bool _isSameDay(DateTime d1, DateTime d2) {
    return d1.year == d2.year && d1.month == d2.month && d1.day == d2.day;
  }

  String _getRelativeDate(DateTime date) {
    final DateTime now = DateTime.now();
    if (_isSameDay(date, now)) return 'Today';
    if (_isSameDay(date, now.subtract(const Duration(days: 1)))) return 'Yesterday';
    return DateFormat('MMM d, yyyy').format(date);
  }
}

class _ActivityTile extends StatelessWidget {
  final ActivityLog log;

  const _ActivityTile({required this.log});

  @override
  Widget build(BuildContext context) {
    final _ActivityVisual visual = _visualFor(log.category, log.isSuccess);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.softBorderColor),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: visual.color.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: visual.color.withValues(alpha: 0.16)),
            ),
            child: Icon(visual.icon, size: 18, color: visual.color),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        log.title,
                        style: GoogleFonts.spaceGrotesk(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                      ),
                    ),
                    Text(
                      DateFormat('HH:mm').format(log.timestamp),
                      style: GoogleFonts.notoSans(
                        color: AppColors.textMuted,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  log.description,
                  style: GoogleFonts.notoSans(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  _ActivityVisual _visualFor(ActivityCategory category, bool isSuccess) {
    if (!isSuccess) {
      return const _ActivityVisual(
        icon: PhosphorIconsBold.warningCircle,
        color: AppColors.dangerColor,
      );
    }

    switch (category) {
      case ActivityCategory.security:
        return const _ActivityVisual(
          icon: PhosphorIconsBold.shieldCheck,
          color: AppColors.primaryColor,
        );
      case ActivityCategory.access:
        return const _ActivityVisual(
          icon: PhosphorIconsBold.fingerprint,
          color: AppColors.accentColor,
        );
      case ActivityCategory.transfers:
        return const _ActivityVisual(
          icon: PhosphorIconsBold.swap,
          color: AppColors.warningColor,
        );
      case ActivityCategory.system:
        return const _ActivityVisual(
          icon: PhosphorIconsBold.cpu,
          color: AppColors.successColor,
        );
    }
  }
}

class _ActivityVisual {
  final IconData icon;
  final Color color;

  const _ActivityVisual({
    required this.icon,
    required this.color,
  });
}
