import 'dart:ui';

class AppLocales {
  static Locale fallbackLocale = const Locale('en');
  static List<Locale> supportedLocales = const [
    Locale('en'),
  ];

  static bool isLocaleAvailable(String languageCode) {
    for (var item in supportedLocales) {
      if (item.languageCode == languageCode) {
        return true;
      }
    }
    return false;
  }
}
