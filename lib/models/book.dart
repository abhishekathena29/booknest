class Book {
  const Book({
    required this.id,
    required this.title,
    required this.author,
    required this.subjects,
    required this.description,
    required this.keyStage,
    required this.lexileBandMin,
    required this.lexileBandMax,
    required this.rating,
    required this.popularity,
  });

  final String id;
  final String title;
  final String author;
  final List<String> subjects;
  final String description;
  final String keyStage;
  final int lexileBandMin;
  final int lexileBandMax;
  final double rating;
  final int popularity;
}
