import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../../utils/reading_level.dart';

class ReadingPassage {
  const ReadingPassage({
    required this.keyStage,
    required this.text,
    required this.question,
    required this.options,
    required this.correctIndex,
  });

  final String keyStage;
  final String text;
  final String question;
  final List<String> options;
  final int correctIndex;
}

class PassageResponse {
  String? difficulty;
  int? selectedOption;
  int? responseTimeMs;

  bool isComplete() => difficulty != null && selectedOption != null;
}

class OnboardingProvider extends ChangeNotifier {
  OnboardingProvider() {
    _responses = List.generate(_passages.length, (_) => PassageResponse());
    _passageStartTimes = List.filled(_passages.length, null);
  }

  // ─── Genres ─────────────────────────────────────
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
  String _genreQuery = '';

  // ─── Book Length ────────────────────────────────
  String? _selectedLength;

  // ─── Authors (selectable chips) ─────────────────
  final Set<String> _selectedAuthors = {};
  String _authorQuery = '';
  final List<String> _popularAuthors = const [
    'Roald Dahl',
    'J.K. Rowling',
    'Rick Riordan',
    'Jeff Kinney',
    'David Walliams',
    'Jacqueline Wilson',
    'Enid Blyton',
    'C.S. Lewis',
    'J.R.R. Tolkien',
    'Michael Morpurgo',
    'Julia Donaldson',
    'Anthony Horowitz',
    'Philip Pullman',
    'Suzanne Collins',
    'John Green',
    'Sally Rooney',
    'Brandon Sanderson',
    'Agatha Christie',
    'Stephen King',
    'George Orwell',
    'Jane Austen',
    'Charles Dickens',
    'Shakespeare',
    'R.L. Stine',
  ];

  // ─── Reading Preferences ────────────────────────
  int? _age;
  String? _comfortPreference;

  // ─── Navigation ─────────────────────────────────
  int _currentStep = 0;
  bool _saving = false;

  // ─── Reading Profile ────────────────────────────
  Map<String, double> _stageProbabilities = {};
  String? _userKeyStage;
  String? _lexileBandEstimate;
  double _confidence = 0.0;
  String? _comfortLevel;
  String? _stretchLevel;

  // ─── Passages ───────────────────────────────────
  final List<ReadingPassage> _passages = const [
    ReadingPassage(
      keyStage: 'KS2',
      text:
          'On Saturday, Maya went to the park to practice her skipping routine. '
          'She counted every jump, trying to beat her record from the week before. '
          'A friendly dog ran past, and Maya laughed when it tried to chase her rope. '
          'She stopped to help the dog\'s owner, who had dropped a set of keys in the '
          'grass. Together they searched around the bench and finally spotted the keys '
          'glinting near the swing. Maya felt proud that she helped and still had time '
          'to finish her practice before lunch.',
      question: 'What did Maya find in the grass?',
      options: [
        'A skipping rope',
        'A set of keys',
        'A lost lunchbox',
        'A toy ball',
      ],
      correctIndex: 1,
    ),
    ReadingPassage(
      keyStage: 'KS3',
      text:
          'When the bus finally pulled away from the station, Leo noticed the city '
          'changing outside his window. Tall glass towers gave way to smaller shops, '
          'then to quiet streets lined with trees. He had always thought of his town '
          'as crowded, but the open fields beyond the last stop looked endless. '
          'As the bus climbed a hill, he could see his school in the distance and '
          'the river that cut through the center like a ribbon. The view made him '
          'realize how quickly places could shift without him noticing.',
      question: 'What change does Leo notice during the bus ride?',
      options: [
        'The bus becomes quieter and emptier.',
        'The city shifts from tall buildings to open fields.',
        'It starts raining near his school.',
        'He sees a new bridge being built.',
      ],
      correctIndex: 1,
    ),
    ReadingPassage(
      keyStage: 'KS4',
      text:
          'A local council recently debated whether to limit car access to the town '
          'center. Supporters argued that cleaner air and safer streets would encourage '
          'more people to walk or cycle, helping small businesses along the main road. '
          'Others worried that shoppers would stay away if they could not park nearby. '
          'During the meeting, a shop owner explained that deliveries were scheduled '
          'early in the morning, and foot traffic actually increased on the days when '
          'the street was closed for events. The council postponed its decision to '
          'gather more data.',
      question: 'Why did some people oppose the car limits?',
      options: [
        'They feared fewer shoppers would visit.',
        'They wanted the council to cancel events.',
        'They thought cycling would be unsafe.',
        'They planned to expand the town center.',
      ],
      correctIndex: 0,
    ),
    ReadingPassage(
      keyStage: 'KS5',
      text:
          'In a seminar on economic history, the group examined how industrial growth '
          'reshaped coastal cities. Shipping firms invested in faster vessels, which '
          'reduced travel times and shifted trade routes. The lecturer emphasized that '
          'these changes were not simply technological; they altered migration patterns '
          'and even the language used in port districts. One student pointed out that '
          'government policy often lagged behind industry, forcing communities to adapt '
          'without clear guidance. The discussion ended with the idea that progress '
          'creates winners and losers in unexpected ways.',
      question: 'What did faster vessels influence besides travel time?',
      options: [
        'The color of port buildings',
        'Trade routes and migration patterns',
        'The size of seminar groups',
        'The weather along the coast',
      ],
      correctIndex: 1,
    ),
  ];

  late final List<PassageResponse> _responses;
  late final List<DateTime?> _passageStartTimes;

  // ─── Getters ────────────────────────────────────
  Set<String> get selectedGenres => _selectedGenres;
  List<String> get genres => _genres;
  String? get selectedLength => _selectedLength;
  String get genreQuery => _genreQuery;
  int get currentStep => _currentStep;
  int? get age => _age;
  String? get comfortPreference => _comfortPreference;
  bool get saving => _saving;
  List<ReadingPassage> get passages => _passages;
  List<PassageResponse> get responses => _responses;
  Set<String> get selectedAuthors => _selectedAuthors;
  String get authorQuery => _authorQuery;
  List<String> get popularAuthors => _popularAuthors;

  Map<String, double> get stageProbabilities => _stageProbabilities;
  String? get userKeyStage => _userKeyStage;
  String? get lexileBandEstimate => _lexileBandEstimate;
  double get confidence => _confidence;
  String? get comfortLevel => _comfortLevel;
  String? get stretchLevel => _stretchLevel;

  // Steps: 0=genres, 1=length, 2=authors, 3=reading prefs, 4-7=passages, 8=results
  int get passageStepStart => 4;
  int get resultsStepIndex => passageStepStart + _passages.length;
  int get totalSteps => resultsStepIndex + 1;

  List<String> get filteredGenres {
    if (_genreQuery.isEmpty) return _genres;
    final query = _genreQuery.toLowerCase();
    return _genres.where((g) => g.toLowerCase().contains(query)).toList();
  }

  List<String> get filteredAuthors {
    if (_authorQuery.isEmpty) return _popularAuthors;
    final query = _authorQuery.toLowerCase();
    return _popularAuthors
        .where((a) => a.toLowerCase().contains(query))
        .toList();
  }

  bool get canProceed {
    switch (_currentStep) {
      case 0:
        return _selectedGenres.length >= 3;
      case 1:
        return _selectedLength != null;
      case 2:
        return true; // authors optional
      case 3:
        return _comfortPreference != null;
      default:
        final passageIndex = _passageIndexForStep(_currentStep);
        if (passageIndex != null) {
          return _responses[passageIndex].isComplete();
        }
        return true;
    }
  }

  // ─── Actions ────────────────────────────────────
  void updateGenreQuery(String value) {
    _genreQuery = value;
    notifyListeners();
  }

  void toggleGenre(String genre) {
    if (_selectedGenres.contains(genre)) {
      _selectedGenres.remove(genre);
    } else {
      _selectedGenres.add(genre);
    }
    notifyListeners();
  }

  void selectLength(String length) {
    _selectedLength = length;
    notifyListeners();
  }

  void updateAuthorQuery(String value) {
    _authorQuery = value;
    notifyListeners();
  }

  void toggleAuthor(String author) {
    if (_selectedAuthors.contains(author)) {
      _selectedAuthors.remove(author);
    } else {
      _selectedAuthors.add(author);
    }
    notifyListeners();
  }

  void updateAge(String value) {
    _age = int.tryParse(value);
    notifyListeners();
  }

  void setComfortPreference(String value) {
    _comfortPreference = value;
    notifyListeners();
  }

  void setPassageDifficulty(int index, String value) {
    _responses[index].difficulty = value;
    notifyListeners();
  }

  void setPassageAnswer(int index, int selectedOption) {
    _responses[index].selectedOption = selectedOption;
    notifyListeners();
  }

  // ─── Navigation ─────────────────────────────────
  void setCurrentStep(int step) {
    _handleStepExit(_currentStep);
    _currentStep = step;
    _handleStepEnter(step);
    notifyListeners();
  }

  void nextStep() {
    if (_currentStep < totalSteps - 1) {
      setCurrentStep(_currentStep + 1);
    }
  }

  void previousStep() {
    if (_currentStep > 0) {
      setCurrentStep(_currentStep - 1);
    }
  }

  void _handleStepEnter(int step) {
    final passageIndex = _passageIndexForStep(step);
    if (passageIndex != null && _passageStartTimes[passageIndex] == null) {
      _passageStartTimes[passageIndex] = DateTime.now();
    }
    if (step == resultsStepIndex) {
      _computeReadingProfile();
    }
  }

  void _handleStepExit(int step) {
    final passageIndex = _passageIndexForStep(step);
    if (passageIndex != null &&
        _passageStartTimes[passageIndex] != null &&
        _responses[passageIndex].responseTimeMs == null) {
      final duration = DateTime.now().difference(
        _passageStartTimes[passageIndex]!,
      );
      _responses[passageIndex].responseTimeMs = duration.inMilliseconds;
    }
  }

  int? _passageIndexForStep(int step) {
    final index = step - passageStepStart;
    if (index >= 0 && index < _passages.length) {
      return index;
    }
    return null;
  }

  // ─── Reading Profile ────────────────────────────
  void _computeReadingProfile() {
    if (_responses.any((response) => !response.isComplete())) {
      return;
    }
    final stageOrder = keyStageOrder;
    final scores = List<double>.filled(stageOrder.length, 1.0);

    final ageIndex = ageToKeyStageIndex(_age);
    if (ageIndex != null) {
      scores[ageIndex] += 2.0;
      if (ageIndex > 0) scores[ageIndex - 1] += 0.5;
      if (ageIndex < scores.length - 1) scores[ageIndex + 1] += 0.5;
    }

    for (var i = 0; i < _passages.length; i++) {
      final passage = _passages[i];
      final response = _responses[i];
      final stageIndex = keyStageIndex(passage.keyStage);
      if (stageIndex == null) continue;
      final difficulty = response.difficulty ?? 'OK';

      if (difficulty == 'Easy') {
        scores[stageIndex] += 0.6;
        if (stageIndex < scores.length - 1) scores[stageIndex + 1] += 1.2;
      } else if (difficulty == 'Hard') {
        scores[stageIndex] += 0.6;
        if (stageIndex > 0) scores[stageIndex - 1] += 1.2;
      } else {
        scores[stageIndex] += 1.0;
      }

      final isCorrect = response.selectedOption == passage.correctIndex;
      if (isCorrect) {
        scores[stageIndex] += 1.2;
      } else {
        if (stageIndex > 0) {
          scores[stageIndex - 1] += 0.6;
        } else {
          scores[stageIndex] += 0.2;
        }
      }

      final responseTimeMs = response.responseTimeMs;
      if (responseTimeMs != null) {
        if (responseTimeMs <= 25000 && stageIndex < scores.length - 1) {
          scores[stageIndex + 1] += 0.4;
        } else if (responseTimeMs >= 60000 && stageIndex > 0) {
          scores[stageIndex - 1] += 0.4;
        } else {
          scores[stageIndex] += 0.2;
        }
      }
    }

    final currentTopIndex = _maxIndex(scores);
    if (_comfortPreference == 'Easy' && currentTopIndex > 0) {
      scores[currentTopIndex - 1] += 0.6;
    } else if (_comfortPreference == 'Challenging' &&
        currentTopIndex < scores.length - 1) {
      scores[currentTopIndex + 1] += 0.6;
    }

    final total = scores.fold<double>(0.0, (prev, value) => prev + value);
    final probabilities = <String, double>{};
    for (var i = 0; i < stageOrder.length; i++) {
      probabilities[stageOrder[i]] = total == 0 ? 0 : scores[i] / total;
    }

    final maxIndex = _maxIndex(scores);
    _userKeyStage = stageOrder[maxIndex];
    _confidence = total == 0 ? 0 : scores[maxIndex] / total;
    _lexileBandEstimate = _userKeyStage == null
        ? null
        : lexileBandForStage(_userKeyStage!);

    final comfortStage = _confidence < 0.55
        ? shiftKeyStage(_userKeyStage!, -1)
        : _userKeyStage;
    final stretchStage = _confidence >= 0.6
        ? shiftKeyStage(_userKeyStage!, 1)
        : null;

    _comfortLevel = comfortStage;
    _stretchLevel = stretchStage;
    _stageProbabilities = probabilities;
  }

  int _maxIndex(List<double> values) {
    var maxValue = values.first;
    var maxIndex = 0;
    for (var i = 1; i < values.length; i++) {
      if (values[i] > maxValue) {
        maxValue = values[i];
        maxIndex = i;
      }
    }
    return maxIndex;
  }

  // ─── Save ───────────────────────────────────────
  Future<void> saveOnboarding() async {
    if (_saving) return;
    _saving = true;
    notifyListeners();

    _computeReadingProfile();

    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final payload = {
        'favorite_genres': _selectedGenres.toList(),
        'preferred_length': _selectedLength,
        'favorite_authors': _selectedAuthors.toList(),
        'reading_level': {
          'user_key_stage': _userKeyStage,
          'lexile_band_estimate': _lexileBandEstimate,
          'confidence': _confidence,
          'comfort_level': _comfortLevel,
          'stretch_level': _stretchLevel,
          'probabilities': _stageProbabilities,
        },
        'reading_preferences': {
          'age': _age,
          'comfort_preference': _comfortPreference,
        },
        'onboarding_completed': true,
        'updated_at': Timestamp.now(),
      };

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .set(payload, SetOptions(merge: true));
    }

    _saving = false;
    notifyListeners();
  }
}
