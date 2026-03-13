import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Book {
  const Book({
    required this.id,
    required this.title,
    required this.author,
    required this.subjects,
    required this.description,
    required this.keyStage,
    required this.lexileBandMin,
    required this.lexileBandMax,
    required this.rating,
    required this.popularity,
    this.coverColor,
  });

  final String id;
  final String title;
  final String author;
  final List<String> subjects;
  final String description;
  final String keyStage;
  final int lexileBandMin;
  final int lexileBandMax;
  final double rating;
  final int popularity;
  final Color? coverColor;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'author': author,
      'subjects': subjects,
      'description': description,
      'keyStage': keyStage,
      'lexileBandMin': lexileBandMin,
      'lexileBandMax': lexileBandMax,
      'rating': rating,
      'popularity': popularity,
    };
  }

  factory Book.fromMap(Map<String, dynamic> data, {String? docId}) {
    return Book(
      id: docId ?? (data['id'] as String?) ?? '',
      title: (data['title'] as String?) ?? 'Untitled',
      author: (data['author'] as String?) ?? 'Unknown',
      subjects:
          (data['subjects'] as List<dynamic>?)
              ?.map((s) => s.toString())
              .toList() ??
          [],
      description: (data['description'] as String?) ?? '',
      keyStage: (data['keyStage'] as String?) ?? 'KS3',
      lexileBandMin: (data['lexileBandMin'] as num?)?.toInt() ?? 0,
      lexileBandMax: (data['lexileBandMax'] as num?)?.toInt() ?? 0,
      rating: (data['rating'] as num?)?.toDouble() ?? 0.0,
      popularity: (data['popularity'] as num?)?.toInt() ?? 0,
    );
  }

  factory Book.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    return Book.fromMap(snapshot.data() ?? {}, docId: snapshot.id);
  }

  /// Generate a consistent cover color based on the book's key stage.
  Color get displayColor {
    if (coverColor != null) return coverColor!;
    switch (keyStage.toUpperCase()) {
      case 'KS2':
        return const Color(0xFF5B8FA3);
      case 'KS3':
        return const Color(0xFF2D5F5D);
      case 'KS4':
        return const Color(0xFF6B4E7B);
      case 'KS5':
        return const Color(0xFF8B5E3C);
      default:
        return const Color(0xFF3A5F5C);
    }
  }

  Color get secondaryDisplayColor {
    switch (keyStage.toUpperCase()) {
      case 'KS2':
        return const Color(0xFF85B7C8);
      case 'KS3':
        return const Color(0xFF4B847F);
      case 'KS4':
        return const Color(0xFF8D6AA0);
      case 'KS5':
        return const Color(0xFFBD8757);
      default:
        return const Color(0xFF5D8882);
    }
  }

  String get searchIndex {
    final buffer = StringBuffer()
      ..write(title.toLowerCase())
      ..write(' ')
      ..write(author.toLowerCase());
    for (final subject in subjects) {
      buffer
        ..write(' ')
        ..write(subject.toLowerCase());
    }
    return buffer.toString();
  }
}
