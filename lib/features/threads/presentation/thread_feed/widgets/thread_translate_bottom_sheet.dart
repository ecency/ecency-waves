import 'package:collection/collection.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:waves/core/dependency_injection/dependency_injection.dart';
import 'package:waves/core/locales/locale_text.dart';
import 'package:waves/core/utilities/parser.dart';
import 'package:waves/features/threads/models/thread_feeds/thread_feed_model.dart';
import 'package:waves/features/translation/models/translation_language.dart';
import 'package:waves/features/translation/repository/translation_repository.dart';

class ThreadTranslateBottomSheet extends StatefulWidget {
  const ThreadTranslateBottomSheet({super.key, required this.item});

  final ThreadFeedModel item;

  @override
  State<ThreadTranslateBottomSheet> createState() =>
      _ThreadTranslateBottomSheetState();
}

class _ThreadTranslateBottomSheetState
    extends State<ThreadTranslateBottomSheet> {
  final TranslationRepository _repository = getIt<TranslationRepository>();

  final String _autoSourceCode = 'auto';
  late final String _originalText;
  List<TranslationLanguage> _languages = const [];
  String _sourceCode = 'auto';
  String _targetCode = 'en';
  String? _detectedLanguage;
  double? _detectedConfidence;
  String? _translatedText;
  bool _isLoadingLanguages = true;
  bool _isTranslating = false;
  bool _initialized = false;
  String? _languageError;
  String? _translationError;

  @override
  void initState() {
    super.initState();
    _originalText = Parser.removeAllHtmlTags(widget.item.body).trim();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    _initialized = true;
    final localeCode = context.locale.languageCode;
    if (localeCode.isNotEmpty) {
      _targetCode = localeCode;
    }
    _loadLanguages();
  }

  Future<void> _loadLanguages() async {
    setState(() {
      _isLoadingLanguages = true;
      _languageError = null;
      _translationError = null;
    });

    try {
      final languages = await _repository.fetchLanguages();
      if (!mounted) return;
      final fallbackTarget = languages.firstWhereOrNull(
            (language) => language.code == _targetCode,
          ) ??
          languages.firstWhereOrNull((language) => language.code == 'en') ??
          languages.first;

      setState(() {
        _languages = languages;
        _targetCode = fallbackTarget.code;
        _isLoadingLanguages = false;
        _languageError = null;
      });

      if (_originalText.isNotEmpty) {
        await _translate();
      }
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isLoadingLanguages = false;
        _languageError = LocaleText.somethingWentWrong;
      });
    }
  }

  Future<void> _translate() async {
    if (_originalText.isEmpty) {
      setState(() {
        _translatedText = '';
        _detectedLanguage = null;
        _detectedConfidence = null;
      });
      return;
    }

    setState(() {
      _isTranslating = true;
      _translationError = null;
    });

    try {
      final result = await _repository.translate(
        text: _originalText,
        source: _sourceCode,
        target: _targetCode,
      );
      if (!mounted) return;
      setState(() {
        _translatedText = result.translatedText;
        if (_sourceCode == _autoSourceCode) {
          _detectedLanguage = result.detectedLanguage;
          _detectedConfidence = result.detectedConfidence;
        } else {
          _detectedLanguage = null;
          _detectedConfidence = null;
        }
        _isTranslating = false;
        _translationError = null;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isTranslating = false;
        _translationError = LocaleText.translationError;
      });
    }
  }

  void _onSourceChanged(String? value) {
    if (value == null) return;
    setState(() {
      _sourceCode = value;
      if (value != _autoSourceCode) {
        _detectedLanguage = null;
        _detectedConfidence = null;
      }
    });
    _translate();
  }

  void _onTargetChanged(String? value) {
    if (value == null) return;
    setState(() {
      _targetCode = value;
    });
    _translate();
  }

  String _languageName(String code) {
    return _languages.firstWhereOrNull((language) => language.code == code)?.name ??
        code.toUpperCase();
  }

  String _confidenceText() {
    if (_detectedConfidence == null) {
      return '';
    }
    final value = _detectedConfidence!.clamp(0, 100).round();
    return ' ($value%)';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mediaQuery = MediaQuery.of(context);
    return SafeArea(
      child: Container(
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: mediaQuery.size.height * 0.9,
          ),
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 16,
                bottom: mediaQuery.viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.outlineVariant,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                const SizedBox(height: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        LocaleText.translate,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      icon: const Icon(Icons.close),
                      tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
                      onPressed: () => Navigator.of(context).maybePop(),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                  if (_isLoadingLanguages)
                    const Center(child: CircularProgressIndicator())
                  else if (_languageError != null)
                    _ErrorState(
                      message: _languageError!,
                      onRetry: _loadLanguages,
                    )
                  else if (_originalText.isEmpty)
                    Text(
                      LocaleText.translationUnavailable,
                      style: theme.textTheme.bodyMedium,
                    )
                  else ...[
                    _LanguageDropdown(
                      label: LocaleText.sourceLanguage,
                      value: _sourceCode,
                      onChanged: _onSourceChanged,
                      items: [
                        DropdownMenuItem(
                          value: _autoSourceCode,
                          child: Text(LocaleText.autoDetectLanguage),
                        ),
                        ..._languages.map(
                          (language) => DropdownMenuItem(
                            value: language.code,
                            child: Text(language.name),
                          ),
                        ),
                      ],
                    ),
                    if (_sourceCode == _autoSourceCode &&
                        _detectedLanguage != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          LocaleText.detectedLanguage(
                            _languageName(_detectedLanguage!),
                            _confidenceText(),
                          ),
                          style: theme.textTheme.bodySmall,
                        ),
                      ),
                    const SizedBox(height: 16),
                    _LanguageDropdown(
                      label: LocaleText.targetLanguage,
                      value: _targetCode,
                      onChanged: _onTargetChanged,
                      items: _languages
                          .map(
                            (language) => DropdownMenuItem(
                              value: language.code,
                              child: Text(language.name),
                            ),
                          )
                          .toList(),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      LocaleText.originalText,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _TranslationTextContainer(text: _originalText),
                    const SizedBox(height: 20),
                    Text(
                      LocaleText.translatedText,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (_isTranslating)
                      const Center(child: CircularProgressIndicator())
                    else if (_translationError != null)
                      _ErrorState(
                        message: _translationError!,
                        onRetry: _translate,
                      )
                    else if (_translatedText != null)
                      _TranslationTextContainer(text: _translatedText!)
                    else
                      _TranslationTextContainer(
                        text: LocaleText.translationUnavailable,
                      ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _LanguageDropdown extends StatelessWidget {
  const _LanguageDropdown({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  final String label;
  final String value;
  final List<DropdownMenuItem<String>> items;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: value,
          items: items,
          onChanged: onChanged,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          ),
        ),
      ],
    );
  }
}

class _TranslationTextContainer extends StatelessWidget {
  const _TranslationTextContainer({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
      ),
      child: SelectableText(
        text,
        style: theme.textTheme.bodyMedium,
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          message,
          style: theme.textTheme.bodyMedium,
        ),
        TextButton(
          onPressed: onRetry,
          child: Text(LocaleText.tryAgain),
        ),
      ],
    );
  }
}
