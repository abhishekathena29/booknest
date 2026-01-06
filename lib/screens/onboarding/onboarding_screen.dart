import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../main_navigation.dart';
import 'provider/onboarding_provider.dart';
import '../../utils/reading_level.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  void _goToMainNavigation(BuildContext context) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const MainNavigation()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => OnboardingProvider(),
      child: Builder(
        builder: (context) {
          return Scaffold(
            backgroundColor: const Color(0xFFFFF8F0),
            body: SafeArea(
              child: Column(
                children: [
                  const SizedBox(height: 20),
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
                    style: TextStyle(fontSize: 16, color: Color(0xFF6B5B4B)),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: Consumer<OnboardingProvider>(
                      builder: (context, provider, _) {
                        final isLastStep =
                            provider.currentStep == provider.totalSteps - 1;
                        return Stepper(
                          type: StepperType.vertical,
                          currentStep: provider.currentStep,
                          onStepTapped: (step) {
                            if (step <= provider.currentStep) {
                              provider.setCurrentStep(step);
                            }
                          },
                          controlsBuilder: (context, details) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 12),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: ElevatedButton(
                                          onPressed: provider.canProceed
                                              ? () async {
                                                  if (isLastStep) {
                                                    await provider
                                                        .saveOnboarding();
                                                    if (context.mounted) {
                                                      _goToMainNavigation(
                                                        context,
                                                      );
                                                    }
                                                  } else {
                                                    provider.nextStep();
                                                  }
                                                }
                                              : null,
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: const Color(
                                              0xFF2D7A7B,
                                            ),
                                            foregroundColor: Colors.white,
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 14,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            disabledBackgroundColor:
                                                Colors.grey[300],
                                          ),
                                          child: provider.saving && isLastStep
                                              ? const SizedBox(
                                                  height: 20,
                                                  width: 20,
                                                  child: CircularProgressIndicator(
                                                    strokeWidth: 2,
                                                    valueColor:
                                                        AlwaysStoppedAnimation(
                                                          Colors.white,
                                                        ),
                                                  ),
                                                )
                                              : Text(
                                                  isLastStep
                                                      ? 'Finish'
                                                      : 'Next',
                                                  style: const TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                        ),
                                      ),
                                      if (provider.currentStep > 0) ...[
                                        const SizedBox(width: 12),
                                        TextButton(
                                          onPressed: provider.previousStep,
                                          child: const Text('Back'),
                                        ),
                                      ],
                                    ],
                                  ),
                                  TextButton(
                                    onPressed: () =>
                                        _goToMainNavigation(context),
                                    child: const Text(
                                      'Skip for Now',
                                      style: TextStyle(color: Colors.grey),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                          steps: [
                            Step(
                              title: const Text('Pick your favorite genres'),
                              subtitle: const Text(
                                'Choose at least 3 genres to personalize.',
                              ),
                              isActive: provider.currentStep >= 0,
                              state: provider.selectedGenres.length >= 3
                                  ? StepState.complete
                                  : StepState.indexed,
                              content: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  TextField(
                                    onChanged: provider.updateGenreQuery,
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
                                    children: provider.filteredGenres.map((
                                      genre,
                                    ) {
                                      final isSelected = provider.selectedGenres
                                          .contains(genre);
                                      return GestureDetector(
                                        onTap: () =>
                                            provider.toggleGenre(genre),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 20,
                                            vertical: 12,
                                          ),
                                          decoration: BoxDecoration(
                                            color: isSelected
                                                ? const Color(0xFF2D7A7B)
                                                : const Color(0xFFE8DCC8),
                                            borderRadius: BorderRadius.circular(
                                              24,
                                            ),
                                          ),
                                          child: Text(
                                            genre,
                                            style: TextStyle(
                                              color: isSelected
                                                  ? Colors.white
                                                  : Colors.black87,
                                              fontWeight: isSelected
                                                  ? FontWeight.bold
                                                  : FontWeight.normal,
                                            ),
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ],
                              ),
                            ),
                            Step(
                              title: const Text('Typical book length'),
                              subtitle: const Text(
                                'Pick the range that matches your reads.',
                              ),
                              isActive: provider.currentStep >= 1,
                              state: provider.selectedLength != null
                                  ? StepState.complete
                                  : StepState.indexed,
                              content: Wrap(
                                spacing: 12,
                                children:
                                    [
                                      '<250 pages',
                                      '250-500 pages',
                                      '500+ pages',
                                    ].map((length) {
                                      final isSelected =
                                          provider.selectedLength == length;
                                      return ChoiceChip(
                                        label: Text(length),
                                        selected: isSelected,
                                        onSelected: (_) =>
                                            provider.selectLength(length),
                                        selectedColor: const Color(0xFF2D7A7B),
                                        backgroundColor: const Color(
                                          0xFFE8DCC8,
                                        ),
                                        labelStyle: TextStyle(
                                          color: isSelected
                                              ? Colors.white
                                              : Colors.black87,
                                          fontWeight: isSelected
                                              ? FontWeight.bold
                                              : FontWeight.normal,
                                        ),
                                      );
                                    }).toList(),
                              ),
                            ),
                            Step(
                              title: const Text('Favorite authors'),
                              subtitle: const Text(
                                'Tell us who you love reading (optional).',
                              ),
                              isActive: provider.currentStep >= 2,
                              state: StepState.indexed,
                              content: TextField(
                                controller: provider.authorController,
                                decoration: InputDecoration(
                                  hintText:
                                      'e.g., Brandon Sanderson, Sally Rooney',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  filled: true,
                                  fillColor: const Color(0xFFFDF8F2),
                                ),
                              ),
                            ),
                            Step(
                              title: const Text('Top 3 favorite books'),
                              subtitle: const Text(
                                'Optional - skip if you prefer.',
                              ),
                              isActive: provider.currentStep >= 3,
                              state: StepState.indexed,
                              content: Column(
                                children: [
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: TextButton(
                                      onPressed: provider.skipFavoriteBooks,
                                      child: const Text('Skip'),
                                    ),
                                  ),
                                  Column(
                                    children: List.generate(3, (index) {
                                      return Padding(
                                        padding: EdgeInsets.only(
                                          top: index == 0 ? 0 : 12,
                                        ),
                                        child: TextField(
                                          controller: provider
                                              .favoriteBookControllers[index],
                                          onChanged: (_) =>
                                              provider.favoriteBookEdited(),
                                          decoration: InputDecoration(
                                            hintText: 'Book ${index + 1}',
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            filled: true,
                                            fillColor: const Color(0xFFFDF8F2),
                                          ),
                                        ),
                                      );
                                    }),
                                  ),
                                  if (provider.favoriteBooksSkipped)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 8),
                                      child: Row(
                                        children: const [
                                          Icon(
                                            Icons.info_outline,
                                            size: 16,
                                            color: Colors.grey,
                                          ),
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
                                ],
                              ),
                            ),
                            Step(
                              title: const Text('Reading preferences'),
                              subtitle: const Text(
                                'Tell us how you like to read.',
                              ),
                              isActive: provider.currentStep >= 4,
                              state: provider.comfortPreference != null
                                  ? StepState.complete
                                  : StepState.indexed,
                              content: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  TextField(
                                    keyboardType: TextInputType.number,
                                    decoration: InputDecoration(
                                      hintText: 'Age (optional)',
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      filled: true,
                                      fillColor: const Color(0xFFFDF8F2),
                                    ),
                                    onChanged: provider.updateAge,
                                  ),
                                  const SizedBox(height: 16),
                                  const Text(
                                    'Comfort preference',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Wrap(
                                    spacing: 12,
                                    children:
                                        [
                                          'Easy',
                                          'Just right',
                                          'Challenging',
                                        ].map((option) {
                                          final isSelected =
                                              provider.comfortPreference ==
                                              option;
                                          return ChoiceChip(
                                            label: Text(option),
                                            selected: isSelected,
                                            onSelected: (_) => provider
                                                .setComfortPreference(option),
                                            selectedColor: const Color(
                                              0xFF2D7A7B,
                                            ),
                                            backgroundColor: const Color(
                                              0xFFE8DCC8,
                                            ),
                                            labelStyle: TextStyle(
                                              color: isSelected
                                                  ? Colors.white
                                                  : Colors.black87,
                                              fontWeight: isSelected
                                                  ? FontWeight.bold
                                                  : FontWeight.normal,
                                            ),
                                          );
                                        }).toList(),
                                  ),
                                ],
                              ),
                            ),
                            ..._buildPassageSteps(provider),
                            Step(
                              title: const Text('Your reading band'),
                              subtitle: const Text(
                                'Here is your current level estimate.',
                              ),
                              isActive:
                                  provider.currentStep >=
                                  provider.resultsStepIndex,
                              state: StepState.complete,
                              content: _ReadingSummary(provider: provider),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  List<Step> _buildPassageSteps(OnboardingProvider provider) {
    return List.generate(provider.passages.length, (index) {
      final passage = provider.passages[index];
      final response = provider.responses[index];
      final stepIndex = provider.passageStepStart + index;
      return Step(
        title: Text('Reading passage ${index + 1}'),
        subtitle: Text('Labeled ${passage.keyStage}'),
        isActive: provider.currentStep >= stepIndex,
        state: response.isComplete() ? StepState.complete : StepState.indexed,
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFFDF8F2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE8DCC8)),
              ),
              child: Text(passage.text, style: const TextStyle(height: 1.4)),
            ),
            const SizedBox(height: 12),
            const Text(
              'How easy was this to read?',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 12,
              children: ['Easy', 'OK', 'Hard'].map((option) {
                final isSelected = response.difficulty == option;
                return ChoiceChip(
                  label: Text(option),
                  selected: isSelected,
                  onSelected: (_) =>
                      provider.setPassageDifficulty(index, option),
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
            const SizedBox(height: 16),
            Text(
              passage.question,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Column(
              children: List.generate(passage.options.length, (optionIndex) {
                return RadioListTile<int>(
                  value: optionIndex,
                  groupValue: response.selectedOption,
                  onChanged: (value) {
                    if (value != null) {
                      provider.setPassageAnswer(index, value);
                    }
                  },
                  title: Text(passage.options[optionIndex]),
                  dense: true,
                );
              }),
            ),
            const SizedBox(height: 8),
            Row(
              children: const [
                Icon(Icons.timer_outlined, size: 16, color: Colors.grey),
                SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'We track how long each passage takes to fine-tune your band.',
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }
}

class _ReadingSummary extends StatelessWidget {
  const _ReadingSummary({required this.provider});

  final OnboardingProvider provider;

  @override
  Widget build(BuildContext context) {
    final stage = provider.userKeyStage ?? 'KS3';
    final lexile = provider.lexileBandEstimate ?? lexileBandForStage(stage);
    final confidence = (provider.confidence * 100).toStringAsFixed(0);
    final comfort = provider.comfortLevel ?? stage;
    final stretch = provider.stretchLevel;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SummaryRow(label: 'User key stage', value: stage),
        _SummaryRow(label: 'Lexile band estimate', value: lexile),
        _SummaryRow(label: 'Confidence', value: '$confidence%'),
        _SummaryRow(label: 'Comfort level', value: comfort),
        _SummaryRow(label: 'Stretch level', value: stretch ?? 'Not ready yet'),
        const SizedBox(height: 12),
        const Text(
          'We will use this band to filter and rank your book recommendations.',
          style: TextStyle(color: Color(0xFF6B5B4B)),
        ),
      ],
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Text(value),
        ],
      ),
    );
  }
}
