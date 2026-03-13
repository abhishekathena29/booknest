import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../models/book.dart';
import '../../services/book_repository.dart';
import '../../utils/reading_level.dart';
import '../../widgets/app_book_cover.dart';
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
    _booksFuture = _bookRepository.getBooks();
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
                  return const _HomeLoadingView();
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
                        padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Theme.of(
                                  context,
                                ).colorScheme.primary.withValues(alpha: 0.16),
                                Theme.of(
                                  context,
                                ).colorScheme.secondary.withValues(alpha: 0.09),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 28,
                                backgroundColor: Theme.of(
                                  context,
                                ).colorScheme.primary.withValues(alpha: 0.18),
                                child: Icon(
                                  Icons.auto_stories_rounded,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Welcome back, $username',
                                      style: Theme.of(context)
                                          .textTheme
                                          .headlineSmall
                                          ?.copyWith(
                                            fontWeight: FontWeight.w700,
                                          ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'A handpicked shelf for your $userKeyStage reading band${lexileBand == null ? '' : ' • $lexileBand'}',
                                      style: TextStyle(
                                        color: Colors.grey[700],
                                        fontSize: 15,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          children: [
                            Expanded(
                              child: _QuickStatCard(
                                title: 'Comfort picks',
                                value: recommendations.comfortReads.length
                                    .clamp(0, 999)
                                    .toString(),
                                icon: Icons.menu_book_rounded,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _QuickStatCard(
                                title: 'Stretch picks',
                                value: recommendations.stretchReads.length
                                    .clamp(0, 999)
                                    .toString(),
                                icon: Icons.trending_up_rounded,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
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
                      subtitle: 'Books that should feel fluent and rewarding.',
                      books: recommendations.comfortReads,
                      emptyLabel:
                          'Complete onboarding to unlock your comfort reads.',
                    ),
                    _buildBookSection(
                      context: context,
                      title: 'Stretch Reads',
                      subtitle:
                          'A little more ambitious without losing the plot.',
                      books: recommendations.stretchReads,
                      emptyLabel:
                          'Stretch reads appear after we are confident in your band.',
                    ),
                    _buildBookSection(
                      context: context,
                      title: 'Explore More Titles',
                      subtitle: 'Fresh covers from the wider BookNest catalog.',
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
    required String subtitle,
    required List<Book> books,
    required String emptyLabel,
  }) {
    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 300,
            child: books.isEmpty
                ? Center(
                    child: Text(
                      emptyLabel,
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  )
                : ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
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
        width: 172,
        margin: const EdgeInsets.only(right: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppBookCover(book: book, width: 172, height: 204),
            const SizedBox(height: 10),
            Text(
              book.title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              book.author,
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(999),
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
                const Spacer(),
                Icon(
                  Icons.star_rounded,
                  size: 16,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 4),
                Text(
                  book.rating.toStringAsFixed(1),
                  style: const TextStyle(fontWeight: FontWeight.w700),
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
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF2D3E4B), const Color(0xFF1F2C34)]
              : [
                  Theme.of(context).colorScheme.primary.withValues(alpha: 0.12),
                  Theme.of(context).colorScheme.primary.withValues(alpha: 0.04),
                ],
        ),
        borderRadius: BorderRadius.circular(24),
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
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    value: confidence,
                    backgroundColor: Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation(
                      Theme.of(context).colorScheme.primary,
                    ),
                    minHeight: 8,
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
          const SizedBox(height: 12),
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
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(14),
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

class _QuickStatCard extends StatelessWidget {
  const _QuickStatCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  final String title;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Theme.of(
                context,
              ).colorScheme.primary.withValues(alpha: 0.12),
            ),
            child: Icon(icon, color: Theme.of(context).colorScheme.primary),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(color: Colors.grey[600], fontSize: 13),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HomeLoadingView extends StatelessWidget {
  const _HomeLoadingView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 16),
          Text(
            'Preparing your library...',
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ],
      ),
    );
  }
}
