const List<String> keyStageOrder = ['KS2', 'KS3', 'KS4', 'KS5'];

int? keyStageIndex(String stage) {
  final normalized = normalizeKeyStage(stage);
  final index = keyStageOrder.indexOf(normalized);
  return index == -1 ? null : index;
}

String normalizeKeyStage(String raw) {
  final upper = raw.toUpperCase();
  if (upper.contains('KS2')) return 'KS2';
  if (upper.contains('KS3')) return 'KS3';
  if (upper.contains('KS4')) return 'KS4';
  if (upper.contains('KS5')) return 'KS5';
  return raw;
}

String lexileBandForStage(String stage) {
  switch (normalizeKeyStage(stage)) {
    case 'KS2':
      return '400-800';
    case 'KS3':
      return '801-1000';
    case 'KS4':
      return '1001-1200';
    case 'KS5':
      return '1201+';
    default:
      return '801-1000';
  }
}

String shiftKeyStage(String stage, int delta) {
  final index = keyStageIndex(stage) ?? 1;
  final next = (index + delta).clamp(0, keyStageOrder.length - 1);
  return keyStageOrder[next];
}

int? ageToKeyStageIndex(int? age) {
  if (age == null) return null;
  if (age <= 11) return 0;
  if (age <= 14) return 1;
  if (age <= 16) return 2;
  return 3;
}
