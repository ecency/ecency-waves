import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';

class ThemeController extends ChangeNotifier {
  static const String _themeModeStorageKey = 'theme_mode';

  final GetStorage _storage;
  final Color _primaryThemeColor = const Color(0xFF357CE5);
  final Color _primaryColor = Colors.black;
  final Color _primaryColorTwo = const Color.fromARGB(255, 8, 8, 8);
  final Color _secondaryColor = Colors.white;
  final Color _secondaryColorTwo = const Color(0xFFf0f0f8);
  final Color _tertiaryColor = const Color(0xFFe7e7f1);
  final Color _errorColor = Colors.red;
  final Color _successColor = Colors.lightGreen;
  final Color _staticColor = Colors.white;
  final Color _lightGrey = const Color(0xFFf0f0f8);

  final String _fontFamily = 'Poppins';

  ThemeMode _themeMode = ThemeMode.dark;

  ThemeController({GetStorage? storage}) : _storage = storage ?? GetStorage() {
    _loadThemeMode();
  }

  ThemeMode get themeMode => _themeMode;

  void toggleTheme() {
    _themeMode = isLightTheme() ? ThemeMode.dark : ThemeMode.light;
    _storage.write(_themeModeStorageKey, _themeMode.name);
    notifyListeners();
  }

  bool isLightTheme() => _themeMode == ThemeMode.light;

  void _loadThemeMode() {
    final dynamic storedValue = _storage.read(_themeModeStorageKey);
    if (storedValue is! String) {
      return;
    }

    switch (storedValue) {
      case 'light':
        _themeMode = ThemeMode.light;
        break;
      case 'dark':
        _themeMode = ThemeMode.dark;
        break;
      default:
        break;
    }
  }

  ThemeData getLightTheme({double textScaleFactor = 1.0, double iconScaleFactor = 1.0}) {
    final appBarIconTheme = IconThemeData(
      color: _primaryColor,
      size: 24.0 * iconScaleFactor,
    );
    return ThemeData(
      primaryColorLight: _secondaryColor,
      primaryColorDark: _primaryColor,
      scaffoldBackgroundColor: _secondaryColor,
      primaryColor: _primaryThemeColor,
      brightness: Brightness.light,
      dividerColor: _primaryColor.withOpacity(0.2),
      focusColor: _primaryThemeColor,
      hintColor: Colors.black38,
      cardColor: _lightGrey,
      dividerTheme: DividerThemeData(color: _primaryColor.withOpacity(0.1)),
      appBarTheme: AppBarTheme(
        backgroundColor: _secondaryColor,
        foregroundColor: _primaryColor,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        titleTextStyle: TextStyle(
          fontFamily: _fontFamily,
          fontSize: 18 * textScaleFactor,
          fontWeight: FontWeight.w600,
          color: _primaryColor,
        ),
        iconTheme: appBarIconTheme,
      ),
      colorScheme: ColorScheme.light(
          onPrimary: _staticColor,
          onSecondary: _lightGrey,
          onTertiary: _successColor, // color used for success
          onTertiaryContainer: Colors.grey.shade700,
          primaryContainer: _primaryThemeColor,
          secondaryContainer: const Color.fromRGBO(5, 206, 179, 1),
          tertiaryContainer: _secondaryColorTwo,
          error: _errorColor,
          onError: Colors.redAccent,
          primary: _primaryColor,
          secondary: _secondaryColor,
          tertiary: _tertiaryColor),
      fontFamily: _fontFamily,
      iconTheme: IconThemeData(color: _primaryColor, size: 24.0 * iconScaleFactor),
      textTheme: _buildTextTheme(_primaryColor, textScaleFactor),
    );
  }

  ThemeData getDarkTheme({double textScaleFactor = 1.0, double iconScaleFactor = 1.0}) {
    final appBarIconTheme = IconThemeData(
      color: _secondaryColor,
      size: 24.0 * iconScaleFactor,
    );
    return ThemeData(
      primaryColorLight: _primaryColor,
      primaryColorDark: _secondaryColor,
      scaffoldBackgroundColor: _primaryColor,
      primaryColor: _primaryThemeColor,
      brightness: Brightness.dark,
      dividerColor: _secondaryColor.withOpacity(0.2),
      focusColor: _primaryThemeColor,
      hintColor: Colors.white38,
      dividerTheme: DividerThemeData(color: _secondaryColor.withOpacity(0.1)),
      appBarTheme: AppBarTheme(
        backgroundColor: _primaryColor,
        foregroundColor: _secondaryColor,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        titleTextStyle: TextStyle(
          fontFamily: _fontFamily,
          fontSize: 18 * textScaleFactor,
          fontWeight: FontWeight.w600,
          color: _secondaryColor,
        ),
        iconTheme: appBarIconTheme,
      ),
      colorScheme: ColorScheme.dark(
          onPrimary: _staticColor,
          onTertiary: _successColor, // color used for success
          onSecondary: Colors.grey.shade800,
          onTertiaryContainer: Colors.grey.shade700,
          primaryContainer: _primaryThemeColor,
          secondaryContainer: const Color.fromRGBO(5, 206, 179, 1),
          tertiaryContainer: _primaryColorTwo,
          error: _errorColor,
          onError: Colors.redAccent,
          primary: _secondaryColor,
          secondary: _primaryColor,
          tertiary: Colors.grey.shade900),
      fontFamily: _fontFamily,
      iconTheme: IconThemeData(color: _secondaryColor, size: 24.0 * iconScaleFactor),
      textTheme: _buildTextTheme(_secondaryColor, textScaleFactor),
    );
  }

  TextTheme _buildTextTheme(Color color, double textScaleFactor) {
    TextStyle buildStyle(double fontSize, FontWeight fontWeight) => TextStyle(
          fontSize: fontSize * textScaleFactor,
          fontWeight: fontWeight,
          color: color,
        );

    return TextTheme(
      labelSmall: buildStyle(10.0, FontWeight.w400),
      labelMedium: buildStyle(11.0, FontWeight.w400),
      labelLarge: buildStyle(12.0, FontWeight.w600),
      bodySmall: buildStyle(13.0, FontWeight.w400),
      bodyMedium: buildStyle(14.0, FontWeight.w400),
      bodyLarge: buildStyle(15.0, FontWeight.w400),
      displaySmall: buildStyle(16.0, FontWeight.w500),
      displayMedium: buildStyle(18.0, FontWeight.w500),
      displayLarge: buildStyle(20.0, FontWeight.bold),
    );
  }

  ThemeData get pollThemeData => isLightTheme()
      ? getLightTheme().copyWith(
          colorScheme: const ColorScheme.light(
              brightness: Brightness.light,
              primary: Color(0xFF90B5EB),
              secondary: Color(0xFFC0C5C7),
              surface: Color(0xFFF6F6F6)))
      : getDarkTheme().copyWith(
          colorScheme: const ColorScheme.dark(
              brightness: Brightness.light,
              primary: Color(0xff254C87),
              secondary: Color(0xff526D91),
              surface: Color(0xff2e3d51)));
}
