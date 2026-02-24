import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/book.dart';

/// Shelf categories for user library.
enum BookShelf {
  currentlyReading('currently_reading', 'Currently Reading'),
  wantToRead('want_to_read', 'Want to Read'),
  finished('finished', 'Finished');

  const BookShelf(this.value, this.label);

  final String value;
  final String label;

  static BookShelf fromString(String value) {
    return BookShelf.values.firstWhere(
      (s) => s.value == value,
      orElse: () => BookShelf.wantToRead,
    );
  }
}

/// Represents a book entry in the user's library.
class LibraryEntry {
  const LibraryEntry({
    required this.book,
    required this.shelf,
    required this.addedAt,
  });

  final Book book;
  final BookShelf shelf;
  final DateTime addedAt;

  factory LibraryEntry.fromMap(Map<String, dynamic> data, {String? docId}) {
    return LibraryEntry(
      book: Book.fromMap(
        data['book'] as Map<String, dynamic>? ?? {},
        docId: docId,
      ),
      shelf: BookShelf.fromString((data['shelf'] as String?) ?? 'want_to_read'),
      addedAt: (data['addedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'book': book.toMap(),
      'shelf': shelf.value,
      'addedAt': FieldValue.serverTimestamp(),
    };
  }
}

class LibraryService extends ChangeNotifier {
  LibraryService({FirebaseFirestore? firestore, FirebaseAuth? auth})
    : _firestore = firestore ?? FirebaseFirestore.instance,
      _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  String? get _uid => _auth.currentUser?.uid;

  CollectionReference<Map<String, dynamic>>? get _libraryRef {
    final uid = _uid;
    if (uid == null) return null;
    return _firestore.collection('users').doc(uid).collection('library');
  }

  /// Stream all library entries for the current user.
  Stream<List<LibraryEntry>> libraryStream() {
    final ref = _libraryRef;
    if (ref == null) return Stream.value([]);
    return ref
        .orderBy('addedAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => LibraryEntry.fromMap(doc.data(), docId: doc.id))
              .toList(),
        );
  }

  /// Stream entries for a specific shelf.
  Stream<List<LibraryEntry>> shelfStream(BookShelf shelf) {
    final ref = _libraryRef;
    if (ref == null) return Stream.value([]);
    return ref
        .where('shelf', isEqualTo: shelf.value)
        .orderBy('addedAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => LibraryEntry.fromMap(doc.data(), docId: doc.id))
              .toList(),
        );
  }

  /// Add a book to the user's library on a given shelf.
  Future<void> addToLibrary(Book book, BookShelf shelf) async {
    final ref = _libraryRef;
    if (ref == null) return;

    final entry = LibraryEntry(
      book: book,
      shelf: shelf,
      addedAt: DateTime.now(),
    );

    // Use the book's ID as the document ID to prevent duplicates.
    await ref.doc(book.id).set(entry.toMap());
    notifyListeners();
  }

  /// Remove a book from the user's library.
  Future<void> removeFromLibrary(String bookId) async {
    final ref = _libraryRef;
    if (ref == null) return;
    await ref.doc(bookId).delete();
    notifyListeners();
  }

  /// Move a book to a different shelf.
  Future<void> updateShelf(String bookId, BookShelf newShelf) async {
    final ref = _libraryRef;
    if (ref == null) return;
    await ref.doc(bookId).update({'shelf': newShelf.value});
    notifyListeners();
  }

  /// Check if a book is in the user's library.
  Future<bool> isInLibrary(String bookId) async {
    final ref = _libraryRef;
    if (ref == null) return false;
    final doc = await ref.doc(bookId).get();
    return doc.exists;
  }

  /// Get the shelf a book is on (null if not in library).
  Future<BookShelf?> getBookShelf(String bookId) async {
    final ref = _libraryRef;
    if (ref == null) return null;
    final doc = await ref.doc(bookId).get();
    if (!doc.exists) return null;
    return BookShelf.fromString(
      (doc.data()?['shelf'] as String?) ?? 'want_to_read',
    );
  }

  /// Get total count of finished books.
  Future<int> finishedCount() async {
    final ref = _libraryRef;
    if (ref == null) return 0;
    final snapshot = await ref
        .where('shelf', isEqualTo: BookShelf.finished.value)
        .get();
    return snapshot.docs.length;
  }
}
