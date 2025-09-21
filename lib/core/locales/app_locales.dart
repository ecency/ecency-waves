import 'dart:ui';

class AppLocales {
  static Locale fallbackLocale = const Locale('en');
  static List<Locale> supportedLocales = const [
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('de'),
    Locale('hi'),
    Locale('pt'),
  ];

  static const Map<String, String> _languageNames = {
    'en': 'English',
    'es': 'Español',
    'fr': 'Français',
    'de': 'Deutsch',
    'hi': 'हिन्दी',
    'pt': 'Português',
  };

  static String getLanguageName(Locale locale) {
    return _languageNames[locale.languageCode] ?? locale.languageCode;
  }

  static bool isLocaleAvailable(String languageCode) {
    for (var item in supportedLocales) {
      if (item.languageCode == languageCode) {
        return true;
      }
    }
    return false;
  }
}
