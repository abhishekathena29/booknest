import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ForumProvider extends ChangeNotifier {
  ForumProvider({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  int _selectedTab = 0;

  int get selectedTab => _selectedTab;
  User? get currentUser => _auth.currentUser;

  void setSelectedTab(int index) {
    if (_selectedTab == index) {
      return;
    }
    _selectedTab = index;
    notifyListeners();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> forumStream() {
    var query = _firestore
        .collection('forums')
        .orderBy('lastPostAt', descending: true);
    if (_selectedTab == 1 && currentUser != null) {
      query = query.where('createdBy', isEqualTo: currentUser!.uid);
    }
    return query.snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> postsStream(String forumId) {
    return _firestore
        .collection('forums')
        .doc(forumId)
        .collection('posts')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> forumDetailStream(
    String forumId,
  ) {
    return _firestore.collection('forums').doc(forumId).snapshots();
  }

  Future<void> createForum({
    required String title,
    required String description,
    required String bookId,
    required String bookTitle,
    required String bookAuthor,
    String? initialPostTitle,
    String? initialPostContent,
    List<String>? initialPostTags,
  }) async {
    final user = currentUser;
    if (user == null) {
      throw StateError('User not signed in.');
    }

    final forumRef = _firestore.collection('forums').doc();
    final batch = _firestore.batch();
    final hasPost =
        initialPostTitle != null && initialPostContent != null;

    batch.set(forumRef, {
      'title': title,
      'description': description,
      'bookId': bookId,
      'bookTitle': bookTitle,
      'bookAuthor': bookAuthor,
      'createdBy': user.uid,
      'createdByName': user.displayName ?? user.email ?? 'Reader',
      'createdAt': FieldValue.serverTimestamp(),
      'lastPostAt': FieldValue.serverTimestamp(),
      'postCount': hasPost ? 1 : 0,
    });

    if (hasPost) {
      final postRef = forumRef.collection('posts').doc();
      batch.set(postRef, {
        'title': initialPostTitle,
        'content': initialPostContent,
        'tags': initialPostTags ?? <String>[],
        'createdBy': user.uid,
        'createdByName': user.displayName ?? user.email ?? 'Reader',
        'createdAt': FieldValue.serverTimestamp(),
        'likeCount': 0,
        'commentCount': 0,
        'likedBy': <String>[],
      });
    }

    await batch.commit();
  }

  Future<void> createPost({
    required String forumId,
    required String title,
    required String content,
    List<String> tags = const [],
  }) async {
    final user = currentUser;
    if (user == null) {
      throw StateError('User not signed in.');
    }

    final forumRef = _firestore.collection('forums').doc(forumId);
    final postRef = forumRef.collection('posts').doc();
    final batch = _firestore.batch();

    batch.set(postRef, {
      'title': title,
      'content': content,
      'tags': tags,
      'createdBy': user.uid,
      'createdByName': user.displayName ?? user.email ?? 'Reader',
      'createdAt': FieldValue.serverTimestamp(),
      'likeCount': 0,
      'commentCount': 0,
      'likedBy': <String>[],
    });
    batch.update(forumRef, {
      'postCount': FieldValue.increment(1),
      'lastPostAt': FieldValue.serverTimestamp(),
    });

    await batch.commit();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> commentsStream({
    required String forumId,
    required String postId,
  }) {
    return _firestore
        .collection('forums')
        .doc(forumId)
        .collection('posts')
        .doc(postId)
        .collection('comments')
        .orderBy('createdAt', descending: false)
        .snapshots();
  }

  Future<void> addComment({
    required String forumId,
    required String postId,
    required String content,
  }) async {
    final user = currentUser;
    if (user == null) {
      throw StateError('User not signed in.');
    }
    final postRef = _firestore
        .collection('forums')
        .doc(forumId)
        .collection('posts')
        .doc(postId);
    final commentRef = postRef.collection('comments').doc();
    final batch = _firestore.batch();
    batch.set(commentRef, {
      'content': content,
      'createdBy': user.uid,
      'createdByName': user.displayName ?? user.email ?? 'Reader',
      'createdAt': FieldValue.serverTimestamp(),
    });
    batch.update(postRef, {
      'commentCount': FieldValue.increment(1),
    });
    await batch.commit();
  }

  Future<void> toggleLike({
    required String forumId,
    required String postId,
  }) async {
    final user = currentUser;
    if (user == null) {
      throw StateError('User not signed in.');
    }
    final postRef = _firestore
        .collection('forums')
        .doc(forumId)
        .collection('posts')
        .doc(postId);
    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(postRef);
      final data = snapshot.data() ?? {};
      final likedBy =
          (data['likedBy'] as List<dynamic>?)
              ?.map((value) => value.toString())
              .toList() ??
          <String>[];
      final hasLiked = likedBy.contains(user.uid);
      if (hasLiked) {
        transaction.update(postRef, {
          'likedBy': FieldValue.arrayRemove([user.uid]),
          'likeCount': FieldValue.increment(-1),
        });
      } else {
        transaction.update(postRef, {
          'likedBy': FieldValue.arrayUnion([user.uid]),
          'likeCount': FieldValue.increment(1),
        });
      }
    });
  }
}
