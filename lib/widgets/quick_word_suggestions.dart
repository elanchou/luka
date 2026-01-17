import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui';
import '../utils/constants.dart';
import 'dart:math';

/// Quick word suggestions for faster input
class QuickWordSuggestions extends StatelessWidget {
  final List<String> wordList;
  final Function(String) onWordSelected;
  final int maxSuggestions;

  const QuickWordSuggestions({
    super.key,
    required this.wordList,
    required this.onWordSelected,
    this.maxSuggestions = 6,
  });

  List<String> _getRandomWords() {
    final random = Random();
    final selectedWords = <String>[];
    
    while (selectedWords.length < maxSuggestions) {
      final word = wordList[random.nextInt(wordList.length)];
      if (!selectedWords.contains(word)) {
        selectedWords.add(word);
      }
    }
    
    return selectedWords;
  }

  @override
  Widget build(BuildContext context) {
    final suggestions = _getRandomWords();

    return Container(
      height: 45,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: suggestions.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final word = suggestions[index];
          return _WordChip(
            word: word,
            onTap: () => onWordSelected(word),
          );
        },
      ),
    );
  }
}

class _WordChip extends StatelessWidget {
  final String word;
  final VoidCallback onTap;

  const _WordChip({
    required this.word,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withOpacity(0.1),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                word,
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.white.withOpacity(0.9),
                ),
              ),
              const SizedBox(width: 6),
              Icon(
                Icons.add_circle_outline,
                size: 16,
                color: AppColors.primaryColor.withOpacity(0.6),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
