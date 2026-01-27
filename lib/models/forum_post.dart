import 'package:cloud_firestore/cloud_firestore.dart';

class ForumPost {
  ForumPost({
    required this.id,
    required this.title,
    required this.content,
    required this.createdBy,
    required this.createdByName,
    required this.createdAt,
  });

  final String id;
  final String title;
  final String content;
  final String createdBy;
  final String createdByName;
  final DateTime? createdAt;

  factory ForumPost.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data() ?? {};
    return ForumPost(
      id: snapshot.id,
      title: (data['title'] as String?) ?? 'Untitled post',
      content: (data['content'] as String?) ?? '',
      createdBy: (data['createdBy'] as String?) ?? '',
      createdByName: (data['createdByName'] as String?) ?? 'Reader',
      createdAt: _parseTimestamp(data['createdAt']),
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
