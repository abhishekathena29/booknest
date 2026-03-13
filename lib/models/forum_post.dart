import 'package:cloud_firestore/cloud_firestore.dart';

class ForumPost {
  ForumPost({
    required this.id,
    required this.title,
    required this.content,
    required this.tags,
    required this.createdBy,
    required this.createdByName,
    required this.createdAt,
    required this.likeCount,
    required this.commentCount,
    required this.likedBy,
  });

  final String id;
  final String title;
  final String content;
  final List<String> tags;
  final String createdBy;
  final String createdByName;
  final DateTime? createdAt;
  final int likeCount;
  final int commentCount;
  final List<String> likedBy;

  factory ForumPost.fromSnapshot(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
  ) {
    final data = snapshot.data() ?? {};
    final likedBy =
        (data['likedBy'] as List<dynamic>?)
            ?.map((value) => value.toString())
            .toList() ??
        <String>[];
    final likeCount =
        (data['likeCount'] as num?)?.toInt() ?? likedBy.length;
    return ForumPost(
      id: snapshot.id,
      title: (data['title'] as String?) ?? 'Untitled post',
      content: (data['content'] as String?) ?? '',
      tags:
          (data['tags'] as List<dynamic>?)
              ?.map((value) => value.toString())
              .toList() ??
          <String>[],
      createdBy: (data['createdBy'] as String?) ?? '',
      createdByName: (data['createdByName'] as String?) ?? 'Reader',
      createdAt: _parseTimestamp(data['createdAt']),
      likeCount: likeCount,
      commentCount: (data['commentCount'] as num?)?.toInt() ?? 0,
      likedBy: likedBy,
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
