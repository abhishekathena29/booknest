import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../models/book.dart';
import '../../services/book_repository.dart';
import '../../utils/reading_level.dart';
import '../chatbot/chatbot_screen.dart';
import '../explore/book_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final BookRepository _bookRepository = BookRepository();
  late final Future<List<Book>> _booksFuture;

  @override
  void initState() {
    super.initState();
    _booksFuture = _bookRepository.loadBooksFromAssets(
      'assets/TRAIN_balanced.csv',
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final username = user?.displayName ?? 'Reader';

    return Scaffold(
      body: SafeArea(
        child: StreamBuilder<DocumentSnapshot>(
          stream: user == null
              ? Stream.empty()
              : FirebaseFirestore.instance
                    .collection('users')
                    .doc(user.uid)
                    .snapshots(),
          builder: (context, userSnapshot) {
            return FutureBuilder<List<Book>>(
              future: _booksFuture,
              builder: (context, booksSnapshot) {
                if (!booksSnapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final books = booksSnapshot.data ?? [];
                final userData =
                    userSnapshot.data?.data() as Map<String, dynamic>?;
                final readingLevel =
                    userData?['reading_level'] as Map<String, dynamic>?;
                final userKeyStage =
                    (readingLevel?['user_key_stage'] as String?) ?? 'KS3';
                final confidence =
                    (readingLevel?['confidence'] as num?)?.toDouble() ?? 0.5;
                final lexileBand =
                    readingLevel?['lexile_band_estimate'] as String?;
                final interests =
                    (userData?['favorite_genres'] as List<dynamic>?)
                        ?.map((genre) => genre.toString())
                        .toList() ??
                    [];

                final recommendations = _bookRepository.buildRecommendations(
                  books: books,
                  userKeyStage: userKeyStage,
                  confidence: confidence,
                  interests: interests,
                );

                return CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 24,
                              backgroundColor: Theme.of(
                                context,
                              ).colorScheme.primary.withValues(alpha: 0.2),
                              child: Icon(
                                Icons.person,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'For You, $username',
                                    style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    'Reading band $userKeyStage'
                                    '${lexileBand == null ? '' : ' ($lexileBand)'}',
                                    style: TextStyle(color: Colors.grey[600]),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.notifications_outlined),
                              onPressed: () {},
                            ),
                          ],
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: _BandSummaryCard(
                          keyStage: userKeyStage,
                          confidence: confidence,
                          comfortStage: confidence < 0.55
                              ? shiftKeyStage(userKeyStage, -1)
                              : userKeyStage,
                          stretchStage: confidence >= 0.6
                              ? shiftKeyStage(userKeyStage, 1)
                              : null,
                        ),
                      ),
                    ),
                    _buildBookSection(
                      context: context,
                      title: 'Comfort Reads',
                      books: recommendations.comfortReads,
                      emptyLabel:
                          'Complete onboarding to unlock your comfort reads.',
                    ),
                    _buildBookSection(
                      context: context,
                      title: 'Stretch Reads',
                      books: recommendations.stretchReads,
                      emptyLabel:
                          'Stretch reads appear after we are confident in your band.',
                    ),
                    _buildBookSection(
                      context: context,
                      title: 'Explore More Titles',
                      books: books.take(8).toList(),
                      emptyLabel: 'No books loaded yet.',
                    ),
                    const SliverToBoxAdapter(child: SizedBox(height: 20)),
                  ],
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ChatBotScreen()),
          );
        },
        backgroundColor: Theme.of(context).colorScheme.primary,
        child: const Icon(Icons.chat_bubble_outline, color: Colors.white),
      ),
    );
  }

  SliverToBoxAdapter _buildBookSection({
    required BuildContext context,
    required String title,
    required List<Book> books,
    required String emptyLabel,
  }) {
    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          SizedBox(
            height: 320,
            child: books.isEmpty
                ? Center(
                    child: Text(
                      emptyLabel,
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  )
                : ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: books.length.clamp(0, 12).toInt(),
                    itemBuilder: (context, index) {
                      return _buildBookCard(context, books[index]);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookCard(BuildContext context, Book book) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => BookDetailScreen(book: book)),
        );
      },
      child: Container(
        width: 160,
        margin: const EdgeInsets.only(right: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 200,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    book.displayColor,
                    book.displayColor.withValues(alpha: 0.7),
                  ],
                ),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: book.displayColor.withValues(alpha: 0.35),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  // Subtle pattern overlay
                  Positioned(
                    right: -20,
                    top: -20,
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.06),
                      ),
                    ),
                  ),
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Text(
                        book.title,
                        textAlign: TextAlign.center,
                        maxLines: 4,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          height: 1.3,
                        ),
                      ),
                    ),
                  ),
                  // Rating badge
                  Positioned(
                    bottom: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.25),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.star, size: 12, color: Colors.amber),
                          const SizedBox(width: 2),
                          Text(
                            book.rating.toStringAsFixed(1),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              book.title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              book.author,
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    book.keyStage,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _BandSummaryCard extends StatelessWidget {
  const _BandSummaryCard({
    required this.keyStage,
    required this.confidence,
    required this.comfortStage,
    required this.stretchStage,
  });

  final String keyStage;
  final double confidence;
  final String comfortStage;
  final String? stretchStage;

  @override
  Widget build(BuildContext context) {
    final confidenceLabel = (confidence * 100).toStringAsFixed(0);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF2D3E4B), const Color(0xFF1F2C34)]
              : [
                  Theme.of(context).colorScheme.primary.withValues(alpha: 0.12),
                  Theme.of(context).colorScheme.primary.withValues(alpha: 0.04),
                ],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.auto_stories,
                color: Theme.of(context).colorScheme.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Your reading band: $keyStage',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: confidence,
                    backgroundColor: Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation(
                      Theme.of(context).colorScheme.primary,
                    ),
                    minHeight: 6,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '$confidenceLabel%',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _buildBadge(context, 'Comfort', comfortStage, Icons.spa_outlined),
              const SizedBox(width: 12),
              _buildBadge(
                context,
                'Stretch',
                stretchStage ?? '—',
                Icons.trending_up,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBadge(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(icon, size: 16, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 6),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
