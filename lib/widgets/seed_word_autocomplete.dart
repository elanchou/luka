import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../utils/constants.dart';

class SeedWordAutocomplete extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final List<String> wordList;
  final int wordNumber;
  final VoidCallback? onSubmitted;
  final VoidCallback? onChanged;

  const SeedWordAutocomplete({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.wordList,
    required this.wordNumber,
    this.onSubmitted,
    this.onChanged,
  });

  @override
  State<SeedWordAutocomplete> createState() => _SeedWordAutocompleteState();
}

class _SeedWordAutocompleteState extends State<SeedWordAutocomplete> {
  final LayerLink _layerLink = LayerLink();
  List<String> _suggestions = [];
  OverlayEntry? _overlayEntry;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onTextChanged);
    widget.focusNode.addListener(_onFocusChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    widget.focusNode.removeListener(_onFocusChanged);
    _removeOverlay();
    super.dispose();
  }

  void _onTextChanged() {
    final String text = widget.controller.text.toLowerCase().trim();

    if (text.isEmpty) {
      setState(() => _suggestions = []);
      _removeOverlay();
      widget.onChanged?.call();
      return;
    }

    final List<String> matches =
        widget.wordList.where((word) => word.startsWith(text)).take(5).toList();

    setState(() => _suggestions = matches);

    if (matches.isNotEmpty && widget.focusNode.hasFocus) {
      _showOverlay();
    } else {
      _removeOverlay();
    }

    widget.onChanged?.call();
  }

  void _onFocusChanged() {
    if (!widget.focusNode.hasFocus) {
      _removeOverlay();
    } else if (_suggestions.isNotEmpty) {
      _showOverlay();
    }
  }

  void _showOverlay() {
    _removeOverlay();

    final OverlayState? overlay = Overlay.maybeOf(context, rootOverlay: true);
    if (overlay == null) return;

    _overlayEntry = OverlayEntry(
      builder: (context) => CompositedTransformFollower(
        link: _layerLink,
        showWhenUnlinked: false,
        offset: const Offset(0, 58),
        child: Align(
          alignment: Alignment.topLeft,
          child: Material(
            color: Colors.transparent,
            child: SizedBox(
              width: 220,
              child: _buildSuggestionsList(),
            ),
          ),
        ),
      ),
    );

    overlay.insert(_overlayEntry!);
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  Widget _buildSuggestionsList() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.surfaceDark.withValues(alpha: 0.96),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.softBorderColor),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 24,
                offset: const Offset(0, 14),
              ),
            ],
          ),
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 8),
            shrinkWrap: true,
            itemCount: _suggestions.length,
            separatorBuilder: (context, index) => Divider(
              height: 1,
              color: Colors.white.withValues(alpha: 0.05),
            ),
            itemBuilder: (context, index) {
              final String word = _suggestions[index];
              final String currentText = widget.controller.text.toLowerCase();

              return InkWell(
                onTap: () {
                  widget.controller.text = word;
                  _removeOverlay();
                  widget.onSubmitted?.call();
                },
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  child: Row(
                    children: [
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: AppColors.primaryColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(9),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          '${index + 1}',
                          style: GoogleFonts.spaceMono(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primaryColor,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: word.substring(0, currentText.length),
                                style: GoogleFonts.spaceGrotesk(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primaryColor,
                                ),
                              ),
                              TextSpan(
                                text: word.substring(currentText.length),
                                style: GoogleFonts.spaceGrotesk(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const Icon(
                        PhosphorIconsBold.arrowUpRight,
                        size: 14,
                        color: AppColors.textMuted,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final String currentText = widget.controller.text.toLowerCase().trim();
    final bool hasText = currentText.isNotEmpty;
    final bool isExactMatch = widget.wordList.contains(currentText);

    Color borderColor = AppColors.softBorderColor;
    if (widget.focusNode.hasFocus) {
      borderColor = AppColors.primaryColor.withValues(alpha: 0.65);
    } else if (hasText && isExactMatch) {
      borderColor = AppColors.successColor.withValues(alpha: 0.55);
    } else if (hasText && !isExactMatch) {
      borderColor = AppColors.dangerColor.withValues(alpha: 0.45);
    }

    return CompositedTransformTarget(
      link: _layerLink,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.backgroundElevated,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: borderColor),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 54,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.02),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  bottomLeft: Radius.circular(20),
                ),
              ),
              child: Text(
                '${widget.wordNumber}',
                style: GoogleFonts.spaceMono(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.labelColor,
                ),
              ),
            ),
            Expanded(
              child: TextField(
                controller: widget.controller,
                focusNode: widget.focusNode,
                textInputAction: TextInputAction.next,
                autocorrect: false,
                enableSuggestions: false,
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
                decoration: InputDecoration(
                  hintText: 'word',
                  hintStyle: GoogleFonts.spaceGrotesk(
                    fontSize: 15,
                    color: AppColors.textMuted,
                  ),
                  border: InputBorder.none,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                ),
                onSubmitted: (_) => widget.onSubmitted?.call(),
              ),
            ),
            if (hasText)
              Padding(
                padding: const EdgeInsets.only(right: 10),
                child: Icon(
                  isExactMatch
                      ? PhosphorIconsBold.checkCircle
                      : PhosphorIconsBold.warningCircle,
                  size: 18,
                  color: isExactMatch
                      ? AppColors.successColor
                      : AppColors.dangerColor,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
