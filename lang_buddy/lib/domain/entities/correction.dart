class Correction {
  final String originalText;
  final String correctedText;
  final List<CorrectionDetail> details;

  const Correction({
    required this.originalText,
    required this.correctedText,
    required this.details,
  });
}

class CorrectionDetail {
  final String incorrect;
  final String correct;
  final String explanationZh;
  final String explanationEn;
  final String? example;

  const CorrectionDetail({
    required this.incorrect,
    required this.correct,
    required this.explanationZh,
    required this.explanationEn,
    this.example,
  });
}
