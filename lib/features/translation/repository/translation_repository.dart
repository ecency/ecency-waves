import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:waves/features/translation/models/translation_language.dart';
import 'package:waves/features/translation/models/translation_result.dart';

class TranslationRepository {
  TranslationRepository({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  static const String _host = 'translate.ecency.com';

  static const Map<String, String> _defaultHeaders = {
    'Accept': 'application/json',
    'User-Agent': 'Mozilla/5.0 (WavesApp)',
  };

  static const Map<String, String> _jsonHeaders = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'User-Agent': 'Mozilla/5.0 (WavesApp)',
  };

  Future<List<TranslationLanguage>> fetchLanguages() async {
    final response = await _client.get(
      Uri.https(_host, '/languages'),
      headers: _defaultHeaders,
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to load languages (${response.statusCode})');
    }

    final body = jsonDecode(response.body);
    if (body is! List) {
      throw Exception('Unexpected languages response');
    }

    return body
        .map((dynamic item) =>
            TranslationLanguage.fromJson(Map<String, dynamic>.from(item as Map)))
        .toList(growable: false);
  }

  Future<TranslationResult> translate({
    required String text,
    required String source,
    required String target,
  }) async {
    final payload = jsonEncode({
      'q': text,
      'source': source,
      'target': target,
    });

    final response = await _client.post(
      Uri.https(_host, '/translate'),
      headers: _jsonHeaders,
      body: payload,
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to translate (${response.statusCode})');
    }

    final body = jsonDecode(response.body);
    if (body is! Map<String, dynamic>) {
      throw Exception('Unexpected translate response');
    }

    final detected = body['detectedLanguage'];
    String? detectedLanguage;
    double? detectedConfidence;
    if (detected is Map<String, dynamic>) {
      final language = detected['language'];
      final confidence = detected['confidence'];
      if (language is String) {
        detectedLanguage = language;
      }
      if (confidence is num) {
        detectedConfidence = confidence.toDouble();
      }
    }

    final translatedText = body['translatedText'];
    if (translatedText is! String) {
      throw Exception('Missing translated text');
    }

    return TranslationResult(
      translatedText: translatedText,
      detectedLanguage: detectedLanguage,
      detectedConfidence: detectedConfidence,
    );
  }
}
