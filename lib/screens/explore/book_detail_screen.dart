import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/book.dart';
import '../../services/library_service.dart';

class BookDetailScreen extends StatefulWidget {
  const BookDetailScreen({super.key, required this.book});

  final Book book;

  @override
  State<BookDetailScreen> createState() => _BookDetailScreenState();
}

class _BookDetailScreenState extends State<BookDetailScreen> {
  int _selectedTab = 0;
  BookShelf? _currentShelf;
  bool _loadingShelf = true;

  @override
  void initState() {
    super.initState();
    _loadCurrentShelf();
  }

  Future<void> _loadCurrentShelf() async {
    final libraryService = context.read<LibraryService>();
    final shelf = await libraryService.getBookShelf(widget.book.id);
    if (mounted) {
      setState(() {
        _currentShelf = shelf;
        _loadingShelf = false;
      });
    }
  }

  Future<void> _addToShelf(BookShelf shelf) async {
    final libraryService = context.read<LibraryService>();
    await libraryService.addToLibrary(widget.book, shelf);
    if (mounted) {
      setState(() => _currentShelf = shelf);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Added to ${shelf.label}'),
          backgroundColor: Theme.of(context).colorScheme.primary,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final book = widget.book;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            actions: [
              IconButton(icon: const Icon(Icons.share), onPressed: () {}),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      book.displayColor,
                      book.displayColor.withValues(alpha: 0.7),
                    ],
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 40),
                    Container(
                      width: 150,
                      height: 220,
                      decoration: BoxDecoration(
                        color: book.displayColor.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.4),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              book.title,
                              textAlign: TextAlign.center,
                              maxLines: 4,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                height: 1.2,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              book.author,
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.8),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    book.title,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'by ${book.author}',
                    style: TextStyle(color: Colors.grey[600], fontSize: 16),
                  ),
                  const SizedBox(height: 12),
                  // Rating stars
                  Row(
                    children: [
                      ...List.generate(5, (i) {
                        final fullStars = book.rating.floor();
                        final hasHalf = (book.rating - fullStars) >= 0.3;
                        if (i < fullStars) {
                          return Icon(
                            Icons.star,
                            color: Theme.of(context).colorScheme.primary,
                            size: 20,
                          );
                        } else if (i == fullStars && hasHalf) {
                          return Icon(
                            Icons.star_half,
                            color: Theme.of(context).colorScheme.primary,
                            size: 20,
                          );
                        } else {
                          return Icon(
                            Icons.star_border,
                            color: Colors.grey[400],
                            size: 20,
                          );
                        }
                      }),
                      const SizedBox(width: 8),
                      Text(
                        book.rating.toStringAsFixed(1),
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Subject chips
                  if (book.subjects.isNotEmpty)
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        ...book.subjects.take(4).map((s) => _buildGenreChip(s)),
                        _buildGenreChip(book.keyStage),
                      ],
                    ),
                  const SizedBox(height: 16),
                  // Reading band info
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.auto_stories_outlined,
                          color: Theme.of(context).colorScheme.primary,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Reading band: ${book.keyStage}  •  Lexile: ${book.lexileBandMin}–${book.lexileBandMax}L',
                            style: TextStyle(
                              fontSize: 13,
                              color: isDark ? Colors.white70 : Colors.grey[700],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Action buttons
                  if (_loadingShelf)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  else
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _currentShelf == BookShelf.wantToRead
                                ? null
                                : () => _addToShelf(BookShelf.wantToRead),
                            icon: Icon(
                              _currentShelf == BookShelf.wantToRead
                                  ? Icons.bookmark
                                  : Icons.bookmark_border,
                              size: 18,
                            ),
                            label: Text(
                              _currentShelf == BookShelf.wantToRead
                                  ? 'On Shelf'
                                  : 'Add to Shelf',
                            ),
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _currentShelf == BookShelf.finished
                                ? null
                                : () => _addToShelf(BookShelf.finished),
                            icon: Icon(
                              _currentShelf == BookShelf.finished
                                  ? Icons.check_circle
                                  : Icons.check_circle_outline,
                              size: 18,
                            ),
                            label: Text(
                              _currentShelf == BookShelf.finished
                                  ? 'Finished'
                                  : 'Mark as Read',
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(
                                context,
                              ).colorScheme.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  if (_currentShelf != null &&
                      _currentShelf != BookShelf.currentlyReading)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Center(
                        child: TextButton.icon(
                          onPressed: () =>
                              _addToShelf(BookShelf.currentlyReading),
                          icon: const Icon(Icons.menu_book, size: 16),
                          label: const Text('Start Reading'),
                        ),
                      ),
                    ),
                  const SizedBox(height: 24),
                  // Tabs
                  Row(
                    children: [
                      _buildTabButton('About', 0),
                      _buildTabButton('Reviews', 1),
                      _buildTabButton('Similar', 2),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
          if (_selectedTab == 0) ..._buildAboutContent(book, isDark),
          if (_selectedTab == 1) ..._buildReviewsContent(),
          if (_selectedTab == 2) ..._buildSimilarContent(),
        ],
      ),
    );
  }

  Widget _buildGenreChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }

  Widget _buildTabButton(String label, int index) {
    final isSelected = _selectedTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTab = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Colors.transparent,
                width: 2,
              ),
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected
                  ? Theme.of(context).colorScheme.primary
                  : Colors.grey[600],
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildAboutContent(Book book, bool isDark) {
    return [
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (book.description.isNotEmpty) ...[
                Text(
                  book.description.length > 400
                      ? '${book.description.substring(0, 400)}...'
                      : book.description,
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? Colors.white70 : Colors.grey[700],
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: 16),
              ],
              // Book stats
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.primary.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStat('Rating', book.rating.toStringAsFixed(1)),
                    Container(width: 1, height: 30, color: Colors.grey[300]),
                    _buildStat('Band', book.keyStage),
                    Container(width: 1, height: 30, color: Colors.grey[300]),
                    _buildStat(
                      'Lexile',
                      '${book.lexileBandMin}–${book.lexileBandMax}',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    ];
  }

  Widget _buildStat(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
      ],
    );
  }

  List<Widget> _buildReviewsContent() {
    return [
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Icon(
                Icons.rate_review_outlined,
                size: 48,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 12),
              Text(
                'No reviews yet',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Be the first to share your thoughts on this book!',
                style: TextStyle(color: Colors.grey[500], fontSize: 14),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.edit, size: 18),
                label: const Text('Write a Review'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ];
  }

  List<Widget> _buildSimilarContent() {
    return [
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Icon(Icons.explore_outlined, size: 48, color: Colors.grey[400]),
              const SizedBox(height: 12),
              Text(
                'Similar books coming soon',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'We\'re working on finding books similar to "${widget.book.title}"',
                style: TextStyle(color: Colors.grey[500], fontSize: 14),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    ];
  }
}
