import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../main_navigation.dart';
import 'provider/onboarding_provider.dart';
import '../../utils/reading_level.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => OnboardingProvider(),
      child: const _OnboardingBody(),
    );
  }
}

class _OnboardingBody extends StatefulWidget {
  const _OnboardingBody();

  @override
  State<_OnboardingBody> createState() => _OnboardingBodyState();
}

class _OnboardingBodyState extends State<_OnboardingBody> {
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goToMainNavigation() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const MainNavigation()),
      (route) => false,
    );
  }

  void _animateToPage(int page) {
    _pageController.animateToPage(
      page,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<OnboardingProvider>(
      builder: (context, provider, _) {
        final totalPages = provider.totalSteps;
        final currentPage = provider.currentStep;
        final isLastPage = currentPage == totalPages - 1;

        return Scaffold(
          backgroundColor: const Color(0xFFFFF8F0),
          body: SafeArea(
            child: Column(
              children: [
                // ─── Progress bar ────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                  child: Row(
                    children: [
                      if (currentPage > 0)
                        GestureDetector(
                          onTap: () {
                            provider.previousStep();
                            _animateToPage(currentPage - 1);
                          },
                          child: const Icon(
                            Icons.arrow_back_ios,
                            size: 20,
                            color: Color(0xFF2D2A32),
                          ),
                        ),
                      if (currentPage > 0) const SizedBox(width: 12),
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: (currentPage + 1) / totalPages,
                            backgroundColor: const Color(0xFFE8DCC8),
                            valueColor: const AlwaysStoppedAnimation(
                              Color(0xFF2D7A7B),
                            ),
                            minHeight: 6,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '${currentPage + 1}/$totalPages',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF6B5B4B),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // ─── Page content ────────────────────
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    onPageChanged: (page) {
                      provider.setCurrentStep(page);
                    },
                    children: [
                      _GenrePage(provider: provider),
                      _LengthPage(provider: provider),
                      _AuthorPage(provider: provider),
                      _PreferencesPage(provider: provider),
                      ...List.generate(
                        provider.passages.length,
                        (i) => _PassagePage(provider: provider, index: i),
                      ),
                      _ResultsPage(provider: provider),
                    ],
                  ),
                ),

                // ─── Bottom buttons ──────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
                  child: Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: provider.canProceed
                              ? () async {
                                  if (isLastPage) {
                                    try {
                                      await provider.saveOnboarding();
                                      if (context.mounted) {
                                        _goToMainNavigation();
                                      }
                                    } catch (_) {
                                      if (context.mounted &&
                                          provider.saveError != null) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text(provider.saveError!),
                                            behavior: SnackBarBehavior.floating,
                                          ),
                                        );
                                      }
                                    }
                                  } else {
                                    provider.nextStep();
                                    _animateToPage(currentPage + 1);
                                  }
                                }
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2D7A7B),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            disabledBackgroundColor: Colors.grey[300],
                            elevation: 0,
                          ),
                          child: provider.saving && isLastPage
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation(
                                      Colors.white,
                                    ),
                                  ),
                                )
                              : Text(
                                  isLastPage ? 'Finish' : 'Continue',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                      if (!isLastPage)
                        TextButton(
                          onPressed: () {
                            // Skip advances to next page only
                            provider.nextStep();
                            _animateToPage(currentPage + 1);
                          },
                          child: const Text(
                            'Skip for now',
                            style: TextStyle(
                              color: Color(0xFF6B5B4B),
                              fontSize: 14,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ─── Page 1: Genres ─────────────────────────────────
class _GenrePage extends StatelessWidget {
  const _GenrePage({required this.provider});
  final OnboardingProvider provider;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          const Center(child: Text('📚', style: TextStyle(fontSize: 48))),
          const SizedBox(height: 16),
          const Center(
            child: Text(
              'Pick your favorite genres',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D2A32),
              ),
            ),
          ),
          const SizedBox(height: 8),
          const Center(
            child: Text(
              'Choose at least 3 to personalize your recommendations.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 15, color: Color(0xFF6B5B4B)),
            ),
          ),
          const SizedBox(height: 20),
          TextField(
            onChanged: provider.updateGenreQuery,
            decoration: InputDecoration(
              hintText: 'Search genres...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: const Color(0xFFF1E6D8),
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: provider.filteredGenres.map((genre) {
              final isSelected = provider.selectedGenres.contains(genre);
              return GestureDetector(
                onTap: () => provider.toggleGenre(genre),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 11,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFF2D7A7B)
                        : const Color(0xFFE8DCC8),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: const Color(
                                0xFF2D7A7B,
                              ).withValues(alpha: 0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  child: Text(
                    genre,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.black87,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          Center(
            child: Text(
              '${provider.selectedGenres.length} selected',
              style: TextStyle(
                color: provider.selectedGenres.length >= 3
                    ? const Color(0xFF2D7A7B)
                    : const Color(0xFF6B5B4B),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

// ─── Page 2: Book Length ─────────────────────────────
class _LengthPage extends StatelessWidget {
  const _LengthPage({required this.provider});
  final OnboardingProvider provider;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          const SizedBox(height: 24),
          const Text('📖', style: TextStyle(fontSize: 48)),
          const SizedBox(height: 16),
          const Text(
            'Typical book length',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D2A32),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Pick the range that matches your usual reads.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 15, color: Color(0xFF6B5B4B)),
          ),
          const SizedBox(height: 40),
          ...['<250 pages', '250-500 pages', '500+ pages'].map((length) {
            final isSelected = provider.selectedLength == length;
            return Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: GestureDetector(
                onTap: () => provider.selectLength(length),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                    vertical: 18,
                    horizontal: 20,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFF2D7A7B)
                        : const Color(0xFFF5EDE0),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFF2D7A7B)
                          : const Color(0xFFE8DCC8),
                      width: 2,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: const Color(
                                0xFF2D7A7B,
                              ).withValues(alpha: 0.25),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ]
                        : null,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isSelected
                            ? Icons.check_circle
                            : Icons.radio_button_unchecked,
                        color: isSelected ? Colors.white : Colors.grey[400],
                      ),
                      const SizedBox(width: 14),
                      Text(
                        length,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: isSelected ? Colors.white : Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

// ─── Page 3: Authors ────────────────────────────────
class _AuthorPage extends StatelessWidget {
  const _AuthorPage({required this.provider});
  final OnboardingProvider provider;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          const Center(child: Text('✍️', style: TextStyle(fontSize: 48))),
          const SizedBox(height: 16),
          const Center(
            child: Text(
              'Favorite authors',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D2A32),
              ),
            ),
          ),
          const SizedBox(height: 8),
          const Center(
            child: Text(
              'Select authors you love reading (optional).',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 15, color: Color(0xFF6B5B4B)),
            ),
          ),
          const SizedBox(height: 20),
          TextField(
            onChanged: provider.updateAuthorQuery,
            decoration: InputDecoration(
              hintText: 'Search authors...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: const Color(0xFFF1E6D8),
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: provider.filteredAuthors.map((author) {
              final isSelected = provider.selectedAuthors.contains(author);
              return GestureDetector(
                onTap: () => provider.toggleAuthor(author),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFF2D7A7B)
                        : const Color(0xFFE8DCC8),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: const Color(
                                0xFF2D7A7B,
                              ).withValues(alpha: 0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isSelected)
                        const Padding(
                          padding: EdgeInsets.only(right: 6),
                          child: Icon(
                            Icons.check,
                            size: 16,
                            color: Colors.white,
                          ),
                        ),
                      Text(
                        author,
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.black87,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          if (provider.selectedAuthors.isNotEmpty) ...[
            const SizedBox(height: 16),
            Center(
              child: Text(
                '${provider.selectedAuthors.length} selected',
                style: const TextStyle(
                  color: Color(0xFF2D7A7B),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

// ─── Page 4: Reading Preferences ────────────────────
class _PreferencesPage extends StatelessWidget {
  const _PreferencesPage({required this.provider});
  final OnboardingProvider provider;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          const Center(child: Text('⚙️', style: TextStyle(fontSize: 48))),
          const SizedBox(height: 16),
          const Center(
            child: Text(
              'Reading preferences',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D2A32),
              ),
            ),
          ),
          const SizedBox(height: 8),
          const Center(
            child: Text(
              'Help us understand your reading comfort.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 15, color: Color(0xFF6B5B4B)),
            ),
          ),
          const SizedBox(height: 30),
          TextField(
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: 'Your age (optional)',
              prefixIcon: const Icon(Icons.cake_outlined),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: const Color(0xFFF1E6D8),
            ),
            onChanged: provider.updateAge,
          ),
          const SizedBox(height: 24),
          const Text(
            'What type of books do you prefer?',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Color(0xFF2D2A32),
            ),
          ),
          const SizedBox(height: 14),
          ...['Easy reads', 'Just right', 'Challenging'].map((option) {
            final isSelected = provider.comfortPreference == option;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: GestureDetector(
                onTap: () => provider.setComfortPreference(option),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 18,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFF2D7A7B)
                        : const Color(0xFFF5EDE0),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFF2D7A7B)
                          : const Color(0xFFE8DCC8),
                      width: 2,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isSelected
                            ? Icons.check_circle
                            : Icons.radio_button_unchecked,
                        color: isSelected ? Colors.white : Colors.grey[400],
                      ),
                      const SizedBox(width: 12),
                      Text(
                        option,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: isSelected ? Colors.white : Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

// ─── Pages 5-8: Reading Passages ────────────────────
class _PassagePage extends StatelessWidget {
  const _PassagePage({required this.provider, required this.index});
  final OnboardingProvider provider;
  final int index;

  @override
  Widget build(BuildContext context) {
    final passage = provider.passages[index];
    final response = provider.responses[index];

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          Center(
            child: Text(
              'Reading Passage ${index + 1}',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D2A32),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF2D7A7B).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                passage.keyStage,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2D7A7B),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Passage text
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFFDF8F2),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE8DCC8)),
            ),
            child: Text(
              passage.text,
              style: const TextStyle(height: 1.5, fontSize: 15),
            ),
          ),
          const SizedBox(height: 20),
          // Difficulty
          const Text(
            'How easy was this to read?',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
              color: Color(0xFF2D2A32),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: ['Easy', 'OK', 'Hard'].map((option) {
              final isSelected = response.difficulty == option;
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: GestureDetector(
                    onTap: () => provider.setPassageDifficulty(index, option),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFF2D7A7B)
                            : const Color(0xFFF5EDE0),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? const Color(0xFF2D7A7B)
                              : const Color(0xFFE8DCC8),
                        ),
                      ),
                      child: Center(
                        child: Text(
                          option,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: isSelected ? Colors.white : Colors.black87,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
          // Question
          Text(
            passage.question,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
              color: Color(0xFF2D2A32),
            ),
          ),
          const SizedBox(height: 10),
          ...List.generate(passage.options.length, (optionIndex) {
            final isSelected = response.selectedOption == optionIndex;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: GestureDetector(
                onTap: () => provider.setPassageAnswer(index, optionIndex),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 14,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFF2D7A7B).withValues(alpha: 0.1)
                        : const Color(0xFFF5EDE0),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFF2D7A7B)
                          : const Color(0xFFE8DCC8),
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isSelected
                              ? const Color(0xFF2D7A7B)
                              : Colors.transparent,
                          border: Border.all(
                            color: isSelected
                                ? const Color(0xFF2D7A7B)
                                : Colors.grey[400]!,
                            width: 2,
                          ),
                        ),
                        child: isSelected
                            ? const Icon(
                                Icons.check,
                                size: 14,
                                color: Colors.white,
                              )
                            : null,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          passage.options[optionIndex],
                          style: TextStyle(
                            fontSize: 14,
                            color: isSelected
                                ? const Color(0xFF2D7A7B)
                                : Colors.black87,
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.timer_outlined, size: 14, color: Colors.grey[400]),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'We track timing to fine-tune your reading band.',
                  style: TextStyle(color: Colors.grey[500], fontSize: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

// ─── Page 9: Results Summary ────────────────────────
class _ResultsPage extends StatelessWidget {
  const _ResultsPage({required this.provider});
  final OnboardingProvider provider;

  @override
  Widget build(BuildContext context) {
    final stage = provider.userKeyStage ?? 'KS3';
    final lexile = provider.lexileBandEstimate ?? lexileBandForStage(stage);
    final confidence = (provider.confidence * 100).toStringAsFixed(0);
    final comfort = provider.comfortLevel ?? stage;
    final stretch = provider.stretchLevel;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          const SizedBox(height: 24),
          const Text('🎉', style: TextStyle(fontSize: 56)),
          const SizedBox(height: 16),
          const Text(
            'Your Reading Profile',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D2A32),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Here\'s your personalized reading band.',
            style: TextStyle(fontSize: 15, color: Color(0xFF6B5B4B)),
          ),
          const SizedBox(height: 30),
          // Main band card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF2D7A7B), Color(0xFF3BA1A3)],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF2D7A7B).withValues(alpha: 0.3),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              children: [
                const Text(
                  'Reading Band',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
                const SizedBox(height: 4),
                Text(
                  stage,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Lexile: $lexile',
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // Stats
          Row(
            children: [
              _buildStatCard('Confidence', '$confidence%'),
              const SizedBox(width: 12),
              _buildStatCard('Comfort', comfort),
              const SizedBox(width: 12),
              _buildStatCard('Stretch', stretch ?? '—'),
            ],
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFF1E6D8),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Row(
              children: [
                Icon(Icons.auto_stories, color: Color(0xFF2D7A7B)),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'We\'ll use this band to filter and rank your book recommendations.',
                    style: TextStyle(color: Color(0xFF6B5B4B), fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFFF5EDE0),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 12, color: Color(0xFF6B5B4B)),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D2A32),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
