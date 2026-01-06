import 'package:flutter/services.dart';
import 'package:csv/csv.dart';
import '../models/book.dart';
import '../utils/reading_level.dart';

class RecommendationResult {
  RecommendationResult({
    required this.comfortReads,
    required this.stretchReads,
  });

  final List<Book> comfortReads;
  final List<Book> stretchReads;
}

class BookRepository {
  Future<List<Book>> loadBooksFromAssets(String assetPath) async {
    final csvData = await rootBundle.loadString(assetPath);
    final rows = const CsvToListConverter().convert(csvData);
    if (rows.isEmpty) return [];

    final headers =
        rows.first.map((header) => header.toString().trim()).toList();
    final headerIndex = <String, int>{};
    for (var i = 0; i < headers.length; i++) {
      headerIndex[headers[i]] = i;
    }

    final books = <Book>[];
    for (var i = 1; i < rows.length; i++) {
      final row = rows[i];
      final title = _getValue(row, headerIndex, 'title');
      final author = _getValue(row, headerIndex, 'author');
      final category = _getValue(row, headerIndex, 'category');
      final keyStageRaw = _getValue(row, headerIndex, 'UK Key Stage');
      final description = _getValue(row, headerIndex, 'segments');
      final wordCount = _getDouble(row, headerIndex, 'word_count');
      final flesch = _getDouble(
        row,
        headerIndex,
        'readability grades_FleschReadingEase',
      );

      if (title.isEmpty) {
        continue;
      }

      final keyStage = normalizeKeyStage(keyStageRaw);
      final lexileBand = lexileBandForStage(keyStage);
      final lexileRange = _parseLexileBand(lexileBand);
      final rating = _ratingFromFlesch(flesch);
      final popularity = wordCount?.round() ?? 0;

      books.add(
        Book(
          id: '${title}_${author}'.replaceAll(' ', '_'),
          title: title,
          author: author.isEmpty ? 'Unknown' : author,
          subjects: _splitSubjects(category),
          description: description,
          keyStage: keyStage,
          lexileBandMin: lexileRange[0],
          lexileBandMax: lexileRange[1],
          rating: rating,
          popularity: popularity,
        ),
      );
    }
    return books;
  }

  RecommendationResult buildRecommendations({
    required List<Book> books,
    required String userKeyStage,
    required double confidence,
    required List<String> interests,
  }) {
    final comfortStage =
        confidence < 0.55 ? shiftKeyStage(userKeyStage, -1) : userKeyStage;
    final stretchStage =
        confidence >= 0.6 ? shiftKeyStage(userKeyStage, 1) : null;

    final comfort = _filterByStage(books, comfortStage, interests);
    final stretch =
        stretchStage == null ? <Book>[] : _filterByStage(books, stretchStage, interests);

    _rankBooks(comfort, userKeyStage, interests);
    _rankBooks(stretch, userKeyStage, interests);

    return RecommendationResult(comfortReads: comfort, stretchReads: stretch);
  }

  List<Book> _filterByStage(
    List<Book> books,
    String stage,
    List<String> interests,
  ) {
    final normalizedInterests =
        interests.map((interest) => interest.toLowerCase()).toList();
    return books.where((book) {
      if (normalizeKeyStage(book.keyStage) != stage) return false;
      if (normalizedInterests.isEmpty) return true;
      final subjectMatch = book.subjects.any(
        (subject) => normalizedInterests.contains(subject.toLowerCase()),
      );
      return subjectMatch;
    }).toList();
  }

  void _rankBooks(
    List<Book> books,
    String userKeyStage,
    List<String> interests,
  ) {
    final normalizedInterests =
        interests.map((interest) => interest.toLowerCase()).toList();
    books.sort((a, b) {
      final userStageIndex = keyStageIndex(userKeyStage) ?? 1;
      final stageDistanceA =
          ((keyStageIndex(a.keyStage) ?? userStageIndex) - userStageIndex).abs();
      final stageDistanceB =
          ((keyStageIndex(b.keyStage) ?? userStageIndex) - userStageIndex).abs();
      if (stageDistanceA != stageDistanceB) {
        return stageDistanceA.compareTo(stageDistanceB);
      }

      final ratingScoreA = a.rating + (a.popularity / 1000);
      final ratingScoreB = b.rating + (b.popularity / 1000);
      if (ratingScoreA != ratingScoreB) {
        return ratingScoreB.compareTo(ratingScoreA);
      }

      final subjectScoreA = _subjectSimilarity(a.subjects, normalizedInterests);
      final subjectScoreB = _subjectSimilarity(b.subjects, normalizedInterests);
      if (subjectScoreA != subjectScoreB) {
        return subjectScoreB.compareTo(subjectScoreA);
      }

      return a.title.compareTo(b.title);
    });
  }

  double _subjectSimilarity(List<String> subjects, List<String> interests) {
    if (interests.isEmpty) return 0;
    final subjectSet =
        subjects.map((subject) => subject.toLowerCase()).toSet();
    var matches = 0;
    for (final interest in interests) {
      if (subjectSet.contains(interest)) {
        matches += 1;
      }
    }
    return matches / interests.length;
  }

  List<String> _splitSubjects(String raw) {
    if (raw.trim().isEmpty) return [];
    return raw
        .split(RegExp(r'[;,/]'))
        .map((subject) => subject.trim())
        .where((subject) => subject.isNotEmpty)
        .toList();
  }

  String _getValue(List<dynamic> row, Map<String, int> headers, String key) {
    final index = headers[key];
    if (index == null || index >= row.length) return '';
    return row[index].toString();
  }

  double? _getDouble(List<dynamic> row, Map<String, int> headers, String key) {
    final value = _getValue(row, headers, key);
    return double.tryParse(value);
  }

  List<int> _parseLexileBand(String band) {
    if (band.contains('+')) {
      final min = int.tryParse(band.replaceAll('+', '')) ?? 1201;
      return [min, min + 200];
    }
    final parts = band.split('-');
    if (parts.length == 2) {
      final min = int.tryParse(parts[0]) ?? 0;
      final max = int.tryParse(parts[1]) ?? min;
      return [min, max];
    }
    return [0, 0];
  }

  double _ratingFromFlesch(double? flesch) {
    if (flesch == null) return 3.8;
    final normalized = (flesch / 100).clamp(0.0, 1.0);
    return (2.5 + normalized * 2.5);
  }
}
