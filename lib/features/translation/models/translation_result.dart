class TranslationResult {
  const TranslationResult({
    required this.translatedText,
    this.detectedLanguage,
    this.detectedConfidence,
  });

  final String translatedText;
  final String? detectedLanguage;
  final double? detectedConfidence;
}
