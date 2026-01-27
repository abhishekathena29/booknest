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
    String? initialPostTitle,
    String? initialPostContent,
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
        'createdBy': user.uid,
        'createdByName': user.displayName ?? user.email ?? 'Reader',
        'createdAt': FieldValue.serverTimestamp(),
      });
    }

    await batch.commit();
  }

  Future<void> createPost({
    required String forumId,
    required String title,
    required String content,
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
      'createdBy': user.uid,
      'createdByName': user.displayName ?? user.email ?? 'Reader',
      'createdAt': FieldValue.serverTimestamp(),
    });
    batch.update(forumRef, {
      'postCount': FieldValue.increment(1),
      'lastPostAt': FieldValue.serverTimestamp(),
    });

    await batch.commit();
  }
}
