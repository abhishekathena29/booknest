import 'dart:async';

import 'package:flutter/material.dart';

import '../../models/book.dart';
import '../../services/book_repository.dart';
import '../../widgets/app_book_cover.dart';
import 'book_detail_screen.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  final BookRepository _bookRepository = BookRepository();
  final TextEditingController _searchController = TextEditingController();
  List<Book> _allBooks = [];
  List<Book> _displayedBooks = [];
  String? _selectedGenre;
  bool _loading = true;
  Timer? _searchDebounce;

  static const List<Map<String, dynamic>> _genres = [
    {
      'name': 'Fantasy',
      'icon': Icons.auto_fix_high,
      'color': Color(0xFF6B4E7B),
    },
    {
      'name': 'Science Fiction',
      'icon': Icons.rocket_launch,
      'color': Color(0xFF2D7A7B),
    },
    {'name': 'Mystery', 'icon': Icons.search, 'color': Color(0xFF5B3A29)},
    {'name': 'Adventure', 'icon': Icons.explore, 'color': Color(0xFF3A6B5C)},
    {'name': 'History', 'icon': Icons.museum, 'color': Color(0xFF7B6B4B)},
    {'name': 'Horror', 'icon': Icons.dark_mode, 'color': Color(0xFF4A2C2A)},
    {'name': 'Poetry', 'icon': Icons.format_quote, 'color': Color(0xFF8B5E3C)},
    {
      'name': 'Dystopian',
      'icon': Icons.location_city,
      'color': Color(0xFF5B6B7B),
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadBooks();
    _searchController.addListener(_onSearchChanged);
  }

  Future<void> _loadBooks() async {
    final books = await _bookRepository.getBooks();
    if (mounted) {
      setState(() {
        _allBooks = books;
        _displayedBooks = books.take(24).toList();
        _loading = false;
      });
    }
  }

  void _onSearchChanged() {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 180), _applyFilters);
  }

  void _applyFilters() {
    if (!mounted) return;
    setState(() {
      List<Book> result = _allBooks;

      if (_selectedGenre != null) {
        result = _bookRepository.filterByGenre(_selectedGenre!, result);
      }

      if (_searchController.text.isNotEmpty) {
        result = _bookRepository.searchBooks(_searchController.text, result);
      }

      _displayedBooks = result.take(40).toList();
    });
  }

  void _selectGenre(String genre) {
    setState(() {
      _selectedGenre = _selectedGenre == genre ? null : genre;
    });
    _applyFilters();
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Explore',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
        ),
        centerTitle: false,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Theme.of(
                      context,
                    ).colorScheme.primary.withValues(alpha: 0.14),
                    Theme.of(
                      context,
                    ).colorScheme.secondary.withValues(alpha: 0.08),
                  ],
                ),
                borderRadius: BorderRadius.circular(26),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Search 10,000+ titles',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Find books by title, author, stage, or genre without waiting on the full catalog.',
                    style: TextStyle(color: Colors.grey[700], fontSize: 14),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search by title, author, or genre...',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                                _applyFilters();
                              },
                            )
                          : null,
                      fillColor: isDark
                          ? const Color(0xFF21303D)
                          : Colors.white.withValues(alpha: 0.92),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(
            height: 52,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: _genres.length,
              itemBuilder: (context, index) {
                final genre = _genres[index];
                final isSelected = _selectedGenre == genre['name'];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: FilterChip(
                    selected: isSelected,
                    label: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          genre['icon'] as IconData,
                          size: 16,
                          color: isSelected
                              ? Colors.white
                              : (genre['color'] as Color),
                        ),
                        const SizedBox(width: 6),
                        Text(genre['name'] as String),
                      ],
                    ),
                    labelStyle: TextStyle(
                      color: isSelected
                          ? Colors.white
                          : (isDark ? Colors.white70 : Colors.black87),
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                    backgroundColor: isDark
                        ? const Color(0xFF21303D)
                        : Colors.white.withValues(alpha: 0.8),
                    selectedColor: genre['color'] as Color,
                    onSelected: (_) => _selectGenre(genre['name'] as String),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    side: BorderSide.none,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 8,
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          if (!_loading)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Row(
                children: [
                  Text(
                    _selectedGenre != null
                        ? '$_selectedGenre picks'
                        : (_searchController.text.isNotEmpty
                              ? 'Search results'
                              : 'Trending shelves'),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${_displayedBooks.length} shown',
                    style: TextStyle(color: Colors.grey[600], fontSize: 13),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 4),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _displayedBooks.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No books found',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Try a different search or genre',
                          style: TextStyle(color: Colors.grey[500]),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _displayedBooks.length,
                    itemBuilder: (context, index) {
                      return _buildBookCard(_displayedBooks[index], isDark);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookCard(Book book, bool isDark) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => BookDetailScreen(book: book)),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1B2833) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            AppBookCover(
              book: book,
              width: 68,
              height: 96,
              borderRadius: 12,
              compact: true,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    book.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    book.author,
                    style: TextStyle(color: Colors.grey[600], fontSize: 13),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      _MetaPill(
                        icon: Icons.star_rounded,
                        label: book.rating.toStringAsFixed(1),
                      ),
                      _MetaPill(
                        icon: Icons.school_outlined,
                        label: book.keyStage,
                      ),
                      if (book.subjects.isNotEmpty)
                        _MetaPill(
                          icon: Icons.sell_outlined,
                          label: book.subjects.first,
                        ),
                    ],
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }
}

class _MetaPill extends StatelessWidget {
  const _MetaPill({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
