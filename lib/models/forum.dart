import 'package:cloud_firestore/cloud_firestore.dart';

class Forum {
  Forum({
    required this.id,
    required this.title,
    required this.description,
    required this.bookId,
    required this.bookTitle,
    required this.bookAuthor,
    required this.createdBy,
    required this.createdByName,
    required this.createdAt,
    required this.lastPostAt,
    required this.postCount,
  });

  final String id;
  final String title;
  final String description;
  final String bookId;
  final String bookTitle;
  final String bookAuthor;
  final String createdBy;
  final String createdByName;
  final DateTime? createdAt;
  final DateTime? lastPostAt;
  final int postCount;

  factory Forum.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data() ?? {};
    return Forum(
      id: snapshot.id,
      title: (data['title'] as String?) ?? 'Untitled forum',
      description: (data['description'] as String?) ?? '',
      bookId: (data['bookId'] as String?) ?? '',
      bookTitle: (data['bookTitle'] as String?) ?? 'Unknown book',
      bookAuthor: (data['bookAuthor'] as String?) ?? '',
      createdBy: (data['createdBy'] as String?) ?? '',
      createdByName: (data['createdByName'] as String?) ?? 'Reader',
      createdAt: _parseTimestamp(data['createdAt']),
      lastPostAt: _parseTimestamp(data['lastPostAt']),
      postCount: (data['postCount'] as num?)?.toInt() ?? 0,
    );
  }

  static DateTime? _parseTimestamp(dynamic value) {
    if (value is Timestamp) {
      return value.toDate();
    }
    if (value is DateTime) {
      return value;
    }
    return null;
  }
}
