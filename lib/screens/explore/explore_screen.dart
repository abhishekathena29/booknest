import 'package:flutter/material.dart';
import '../../models/book.dart';
import '../../services/book_repository.dart';
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
        _displayedBooks = books.take(20).toList();
        _loading = false;
      });
    }
  }

  void _onSearchChanged() {
    _applyFilters();
  }

  void _applyFilters() {
    setState(() {
      List<Book> result = _allBooks;

      if (_selectedGenre != null) {
        result = _bookRepository.filterByGenre(_selectedGenre!, result);
      }

      if (_searchController.text.isNotEmpty) {
        result = _bookRepository.searchBooks(_searchController.text, result);
      }

      _displayedBooks = result.take(30).toList();
    });
  }

  void _selectGenre(String? genre) {
    setState(() {
      _selectedGenre = _selectedGenre == genre ? null : genre;
    });
    _applyFilters();
  }

  @override
  void dispose() {
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
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
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
                filled: true,
                fillColor: isDark ? const Color(0xFF2D3E4B) : Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),

          // Genre chips row
          SizedBox(
            height: 50,
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
                        ? const Color(0xFF2D3E4B)
                        : Colors.grey[100],
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

          // Results header
          if (!_loading)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Row(
                children: [
                  Text(
                    _selectedGenre != null
                        ? '$_selectedGenre Books'
                        : (_searchController.text.isNotEmpty
                              ? 'Search Results'
                              : 'Popular Books'),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${_displayedBooks.length} books',
                    style: TextStyle(color: Colors.grey[600], fontSize: 13),
                  ),
                ],
              ),
            ),

          const SizedBox(height: 4),

          // Book results
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
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF2D3E4B) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Book cover
            Container(
              width: 60,
              height: 85,
              decoration: BoxDecoration(
                color: book.displayColor,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: book.displayColor.withValues(alpha: 0.4),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: Text(
                    book.title,
                    textAlign: TextAlign.center,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Book info
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
                  const SizedBox(height: 2),
                  Text(
                    book.author,
                    style: TextStyle(color: Colors.grey[600], fontSize: 13),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(
                        Icons.star,
                        size: 14,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        book.rating.toStringAsFixed(1),
                        style: const TextStyle(fontSize: 12),
                      ),
                      const SizedBox(width: 12),
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
                            fontSize: 11,
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      if (book.subjects.isNotEmpty) ...[
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            book.subjects.take(2).join(', '),
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey[500],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
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
