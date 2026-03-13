import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../models/book.dart';

class AppBookCover extends StatelessWidget {
  const AppBookCover({
    super.key,
    required this.book,
    this.width = 120,
    this.height = 180,
    this.borderRadius = 20,
    this.compact = false,
  });

  final Book book;
  final double width;
  final double height;
  final double borderRadius;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final accent = book.displayColor;
    final secondary = book.secondaryDisplayColor;
    final onAccent =
        ThemeData.estimateBrightnessForColor(accent) == Brightness.dark
        ? Colors.white
        : const Color(0xFF10202C);

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [accent, secondary],
        ),
        boxShadow: [
          BoxShadow(
            color: accent.withValues(alpha: 0.28),
            blurRadius: 22,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Positioned(
              top: -height * 0.16,
              right: -width * 0.1,
              child: Container(
                width: width * 0.8,
                height: width * 0.8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.10),
                ),
              ),
            ),
            Positioned(
              left: -width * 0.12,
              bottom: -height * 0.10,
              child: Transform.rotate(
                angle: -math.pi / 8,
                child: Container(
                  width: width * 0.6,
                  height: height * 0.25,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(width),
                    color: Colors.black.withValues(alpha: 0.08),
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(compact ? 10 : 14),
              child: compact
                  ? _CompactCoverContent(book: book, onAccent: onAccent)
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(999),
                            color: Colors.white.withValues(alpha: 0.16),
                          ),
                          child: Text(
                            book.subjects.isNotEmpty
                                ? book.subjects.first
                                : book.keyStage,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: onAccent.withValues(alpha: 0.9),
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          book.title,
                          maxLines: 4,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: onAccent,
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            height: 1.05,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          book.author,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: onAccent.withValues(alpha: 0.8),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CompactCoverContent extends StatelessWidget {
  const _CompactCoverContent({required this.book, required this.onAccent});

  final Book book;
  final Color onAccent;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            color: Colors.white.withValues(alpha: 0.16),
          ),
          child: Text(
            book.keyStage,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: onAccent.withValues(alpha: 0.92),
              fontSize: 8,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const Spacer(),
        Text(
          book.title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: onAccent,
            fontSize: 9.5,
            fontWeight: FontWeight.w800,
            height: 1.0,
          ),
        ),
      ],
    );
  }
}
