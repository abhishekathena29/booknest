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
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
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
                final lexileBand = readingLevel?['lexile_band_estimate'] as String?;
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
                              backgroundColor: Theme.of(context)
                                  .colorScheme
                                  .primary
                                  .withValues(alpha: 0.2),
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
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                    ),
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
                          stretchStage:
                              confidence >= 0.6 ? shiftKeyStage(userKeyStage, 1) : null,
                        ),
                      ),
                    ),
                    _buildBookSection(
                      context: context,
                      title: 'Comfort Reads',
                      books: recommendations.comfortReads,
                      emptyLabel: 'Complete onboarding to unlock your comfort reads.',
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
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
          SizedBox(
            height: 280,
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
          MaterialPageRoute(builder: (context) => const BookDetailScreen()),
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
                color: _stageColor(context, book.keyStage),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  book.title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
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
            ),
            Text(
              '${book.keyStage} band',
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _stageColor(BuildContext context, String keyStage) {
    switch (normalizeKeyStage(keyStage)) {
      case 'KS2':
        return const Color(0xFF5B8FA3);
      case 'KS3':
        return const Color(0xFF2D5F5D);
      case 'KS4':
        return const Color(0xFF6B9B9E);
      case 'KS5':
        return const Color(0xFF3A5F5C);
      default:
        return Theme.of(context).colorScheme.primary;
    }
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
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your reading band: $keyStage',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          Text('Confidence $confidenceLabel%'),
          const SizedBox(height: 6),
          Text('Comfort: $comfortStage'),
          Text('Stretch: ${stretchStage ?? 'Not ready yet'}'),
        ],
      ),
    );
  }
}
