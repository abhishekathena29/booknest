import 'package:flutter/material.dart';
import '../main_navigation.dart';

class GenreSelectionScreen extends StatefulWidget {
  const GenreSelectionScreen({super.key});

  @override
  State<GenreSelectionScreen> createState() => _GenreSelectionScreenState();
}

class _GenreSelectionScreenState extends State<GenreSelectionScreen> {
  final Set<String> _selectedGenres = {};
  final List<String> _genres = const [
    'Fantasy',
    'Science Fiction',
    'Mystery',
    'Thriller',
    'Romance',
    'History',
    'Biography',
    'Self-Help',
    'Horror',
    'Comedy',
    'Adventure',
    'Non-Fiction',
    'Poetry',
    'Dystopian',
    'Philosophy',
  ];

  final TextEditingController _authorController = TextEditingController();
  final List<TextEditingController> _favoriteBookControllers =
      List.generate(3, (_) => TextEditingController());

  String? _selectedLength;
  String _genreQuery = '';
  bool _favoriteBooksSkipped = false;

  List<String> get _filteredGenres {
    if (_genreQuery.isEmpty) return _genres;
    final query = _genreQuery.toLowerCase();
    return _genres.where((g) => g.toLowerCase().contains(query)).toList();
  }

  @override
  void dispose() {
    _authorController.dispose();
    for (final controller in _favoriteBookControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final canContinue =
        _selectedGenres.length >= 3 && _selectedLength != null;

    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F0),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 80),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: Container(
                      height: 4,
                      decoration: BoxDecoration(
                        color: const Color(0xFFD2691E),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Container(
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            const Text(
              'Let\'s Personalize Your\nLibrary',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                height: 1.2,
                color: Color(0xFF2D2A32),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Tell us what you like so we can tailor\nrecommendations for you.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFF6B5B4B),
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SectionHeader(
                      title: 'Pick your favorite genres',
                      subtitle:
                          'Choose at least 3 genres to personalize your feed.',
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      onChanged: (value) {
                        setState(() {
                          _genreQuery = value;
                        });
                      },
                      decoration: InputDecoration(
                        hintText: 'Search for a genre',
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: const Color(0xFFF1E6D8),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      alignment: WrapAlignment.start,
                      children: _filteredGenres.map((genre) {
                        final isSelected = _selectedGenres.contains(genre);
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              if (isSelected) {
                                _selectedGenres.remove(genre);
                              } else {
                                _selectedGenres.add(genre);
                              }
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? const Color(0xFF2D7A7B)
                                  : const Color(0xFFE8DCC8),
                              borderRadius: BorderRadius.circular(24),
                            ),
                            child: Text(
                              genre,
                              style: TextStyle(
                                color:
                                    isSelected ? Colors.white : Colors.black87,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 28),
                    _SectionHeader(
                      title: 'Typical book length',
                      subtitle:
                          'Pick the range that matches what you usually read.',
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 12,
                      children: [
                        '<250 pages',
                        '250-500 pages',
                        '500+ pages',
                      ].map((length) {
                        final isSelected = _selectedLength == length;
                        return ChoiceChip(
                          label: Text(length),
                          selected: isSelected,
                          onSelected: (_) {
                            setState(() {
                              _selectedLength = length;
                            });
                          },
                          selectedColor: const Color(0xFF2D7A7B),
                          backgroundColor: const Color(0xFFE8DCC8),
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.white : Colors.black87,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 28),
                    _SectionHeader(
                      title: 'Favorite authors',
                      subtitle: 'Tell us who you love reading (optional).',
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _authorController,
                      decoration: InputDecoration(
                        hintText: 'e.g., Brandon Sanderson, Sally Rooney',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: const Color(0xFFFDF8F2),
                      ),
                    ),
                    const SizedBox(height: 28),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _SectionHeader(
                          title: 'Top 3 favorite books',
                          subtitle: 'Optional — skip if you prefer.',
                        ),
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _favoriteBooksSkipped = true;
                              for (final controller
                                  in _favoriteBookControllers) {
                                controller.clear();
                              }
                            });
                          },
                          child: const Text('Skip'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Column(
                      children: List.generate(3, (index) {
                        return Padding(
                          padding: EdgeInsets.only(top: index == 0 ? 0 : 12),
                          child: TextField(
                            controller: _favoriteBookControllers[index],
                            onChanged: (_) {
                              if (_favoriteBooksSkipped) {
                                setState(() {
                                  _favoriteBooksSkipped = false;
                                });
                              }
                            },
                            decoration: InputDecoration(
                              hintText: 'Book ${index + 1}',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              filled: true,
                              fillColor: const Color(0xFFFDF8F2),
                            ),
                          ),
                        );
                      }),
                    ),
                    if (_favoriteBooksSkipped)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Row(
                          children: const [
                            Icon(Icons.info_outline,
                                size: 16, color: Colors.grey),
                            SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                'Skipped favorite books for now.',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  ElevatedButton(
                    onPressed: canContinue
                        ? () {
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const MainNavigation(),
                              ),
                              (route) => false,
                            );
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2D7A7B),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      minimumSize: const Size(double.infinity, 56),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      disabledBackgroundColor: Colors.grey[300],
                    ),
                    child: Text(
                      'Continue${_selectedGenres.isEmpty ? '' : ' (${_selectedGenres.length})'}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const MainNavigation(),
                        ),
                        (route) => false,
                      );
                    },
                    child: const Text(
                      'Skip for Now',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String subtitle;

  const _SectionHeader({
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2D2A32),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFF6B5B4B),
          ),
        ),
      ],
    );
  }
}
