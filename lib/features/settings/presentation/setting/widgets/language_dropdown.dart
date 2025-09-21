import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:waves/core/locales/app_locales.dart';

class LanguageDropdown extends StatefulWidget {
  const LanguageDropdown({super.key});

  @override
  State<LanguageDropdown> createState() => _LanguageDropdownState();
}

class _LanguageDropdownState extends State<LanguageDropdown> {
  late Locale _selectedLocale;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _selectedLocale = context.locale;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final locales = AppLocales.supportedLocales;

    return DropdownButtonHideUnderline(
      child: DropdownButton<Locale>(
        value: _selectedLocale,
        style: theme.textTheme.bodyMedium,
        items: locales
            .map(
              (locale) => DropdownMenuItem<Locale>(
                value: locale,
                child: Text(AppLocales.getLanguageName(locale)),
              ),
            )
            .toList(),
        onChanged: (Locale? locale) {
          if (locale == null || _selectedLocale == locale) {
            return;
          }
          setState(() {
            _selectedLocale = locale;
          });
          context.setLocale(locale);
        },
      ),
    );
  }
}

