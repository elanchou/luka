import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../utils/constants.dart';

enum SaultDialogTone { neutral, info, danger }

class SaultDialogAction<T> {
  final String label;
  final T? value;
  final bool isPrimary;
  final bool isDestructive;
  final IconData? icon;

  const SaultDialogAction({
    required this.label,
    this.value,
    this.isPrimary = false,
    this.isDestructive = false,
    this.icon,
  });
}

Future<T?> showSaultDialog<T>(
  BuildContext context, {
  required String title,
  String? message,
  Widget? content,
  IconData? icon,
  SaultDialogTone tone = SaultDialogTone.neutral,
  bool barrierDismissible = true,
  List<SaultDialogAction<T>> actions = const [],
}) {
  return showGeneralDialog<T>(
    context: context,
    barrierDismissible: barrierDismissible,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    barrierColor: Colors.black.withValues(alpha: 0.72),
    transitionDuration: const Duration(milliseconds: 260),
    pageBuilder: (context, animation, secondaryAnimation) {
      return SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: SaultDialog(
              title: title,
              message: message,
              content: content,
              icon: icon,
              tone: tone,
              actions: actions,
            ),
          ),
        ),
      );
    },
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      final CurvedAnimation curved = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
      );

      return FadeTransition(
        opacity: curved,
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.94, end: 1.0).animate(curved),
          child: child,
        ),
      );
    },
  );
}

class SaultDialog extends StatelessWidget {
  final String title;
  final String? message;
  final Widget? content;
  final IconData? icon;
  final SaultDialogTone tone;
  final List<SaultDialogAction<dynamic>> actions;

  const SaultDialog({
    super.key,
    required this.title,
    this.message,
    this.content,
    this.icon,
    this.tone = SaultDialogTone.neutral,
    this.actions = const <SaultDialogAction<dynamic>>[],
  });

  Color get _accentColor {
    switch (tone) {
      case SaultDialogTone.info:
        return AppColors.primaryColor;
      case SaultDialogTone.danger:
        return AppColors.dangerColor;
      case SaultDialogTone.neutral:
        return AppColors.accentColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(32),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 440),
          padding: const EdgeInsets.fromLTRB(24, 22, 24, 20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: <Color>[
                AppColors.surfaceHighlight.withValues(alpha: 0.96),
                AppColors.surfaceDark.withValues(alpha: 0.98),
              ],
            ),
            borderRadius: BorderRadius.circular(32),
            border: Border.all(color: _accentColor.withValues(alpha: 0.18)),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.35),
                blurRadius: 36,
                offset: const Offset(0, 18),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  if (icon != null) ...<Widget>[
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: _accentColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: _accentColor.withValues(alpha: 0.18),
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Icon(icon, color: _accentColor, size: 22),
                    ),
                    const SizedBox(width: 14),
                  ],
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(top: icon == null ? 2 : 4),
                      child: Text(
                        title,
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                          letterSpacing: -0.2,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              if (message != null) ...<Widget>[
                const SizedBox(height: 16),
                Text(
                  message!,
                  style: GoogleFonts.notoSans(
                    fontSize: 14,
                    height: 1.55,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
              if (content != null) ...<Widget>[
                const SizedBox(height: 16),
                content!,
              ],
              if (actions.isNotEmpty) ...<Widget>[
                const SizedBox(height: 22),
                Row(
                  children: actions.map((SaultDialogAction<dynamic> action) {
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: _DialogActionButton(
                          label: action.label,
                          icon: action.icon,
                          isPrimary: action.isPrimary,
                          isDestructive: action.isDestructive,
                          onTap: () => Navigator.of(context).pop(action.value),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _DialogActionButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final bool isPrimary;
  final bool isDestructive;
  final VoidCallback onTap;

  const _DialogActionButton({
    required this.label,
    required this.onTap,
    this.icon,
    this.isPrimary = false,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final Color accentColor = isDestructive
        ? AppColors.dangerColor
        : (isPrimary ? AppColors.primaryColor : AppColors.softBorderColor);
    final Color textColor = isPrimary
        ? AppColors.backgroundDark
        : (isDestructive ? AppColors.dangerColor : AppColors.textPrimary);

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(18),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          height: 52,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            gradient: isPrimary
                ? LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: <Color>[
                      AppColors.primaryColor,
                      AppColors.primaryColor.withValues(alpha: 0.86),
                    ],
                  )
                : null,
            color: isPrimary
                ? null
                : accentColor.withValues(alpha: isDestructive ? 0.10 : 0.06),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isPrimary
                  ? AppColors.primaryColor.withValues(alpha: 0.25)
                  : accentColor.withValues(alpha: isDestructive ? 0.35 : 0.7),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              if (icon != null) ...<Widget>[
                Icon(icon, size: 16, color: textColor),
                const SizedBox(width: 8),
              ],
              Flexible(
                child: Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: textColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
