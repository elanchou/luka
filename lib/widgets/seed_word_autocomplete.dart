import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui';
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
  List<String> _suggestions = [];
  OverlayEntry? _overlayEntry;
  final LayerLink _layerLink = LayerLink();

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
    final text = widget.controller.text.toLowerCase().trim();
    
    if (text.isEmpty) {
      setState(() {
        _suggestions = [];
      });
      _removeOverlay();
      return;
    }

    // Find matching words
    final matches = widget.wordList
        .where((word) => word.startsWith(text))
        .take(5)
        .toList();

    setState(() {
      _suggestions = matches;
    });

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

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        width: 200,
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: const Offset(0, 50),
          child: Material(
            color: Colors.transparent,
            child: _buildSuggestionsList(),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  Widget _buildSuggestionsList() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.surfaceDark.withOpacity(0.95),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.white.withOpacity(0.1),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 8),
            shrinkWrap: true,
            itemCount: _suggestions.length,
            separatorBuilder: (context, index) => Divider(
              height: 1,
              color: Colors.white.withOpacity(0.05),
            ),
            itemBuilder: (context, index) {
              final word = _suggestions[index];
              final currentText = widget.controller.text.toLowerCase();
              
              return InkWell(
                onTap: () {
                  widget.controller.text = word;
                  _removeOverlay();
                  widget.onSubmitted?.call();
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: AppColors.primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Center(
                          child: Text(
                            '${index + 1}',
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryColor,
                            ),
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
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primaryColor,
                                ),
                              ),
                              TextSpan(
                                text: word.substring(currentText.length),
                                style: GoogleFonts.spaceGrotesk(
                                  fontSize: 14,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward,
                        size: 14,
                        color: Colors.white.withOpacity(0.3),
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
    final isValid = _suggestions.contains(widget.controller.text.toLowerCase().trim());
    final hasText = widget.controller.text.isNotEmpty;

    return CompositedTransformTarget(
      link: _layerLink,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.03),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: widget.focusNode.hasFocus
                ? AppColors.primaryColor.withOpacity(0.5)
                : (hasText && isValid)
                    ? AppColors.successColor.withOpacity(0.3)
                    : (hasText && !isValid)
                        ? AppColors.dangerColor.withOpacity(0.3)
                        : Colors.white.withOpacity(0.1),
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.02),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  bottomLeft: Radius.circular(12),
                ),
              ),
              child: Center(
                child: Text(
                  '${widget.wordNumber}',
                  style: GoogleFonts.spaceMono(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[600],
                  ),
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
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
                decoration: InputDecoration(
                  hintText: 'word',
                  hintStyle: GoogleFonts.spaceGrotesk(
                    fontSize: 15,
                    color: Colors.grey[600],
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 14,
                  ),
                ),
                onSubmitted: (_) => widget.onSubmitted?.call(),
              ),
            ),
            if (hasText)
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Icon(
                  isValid ? Icons.check_circle : Icons.error,
                  size: 18,
                  color: isValid 
                      ? AppColors.successColor 
                      : AppColors.dangerColor.withOpacity(0.5),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
