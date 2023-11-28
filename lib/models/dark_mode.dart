import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fnmap/constants.dart';
import 'package:fnmap/utilities/logger.dart';

enum NMapThemeMode {
  light,
  dark,
  unknown,
}

class NMapDarkMode with ChangeNotifier {
  BuildContext? rootContext;
  ThemeData? _themeDark;
  ThemeData? _themeLight;
  ThemeData? _theme;
  late NMapThemeMode _mode;
  late bool initialized;
  NLog log = NLog('NMapDarkMode');

  NMapDarkMode({bool isDark = false}) {
    _mode = NMapThemeMode.unknown;
    initialized = false;
  }

  NMapThemeMode get mode => _mode;

  @override
  String toString() {
    if (_mode == NMapThemeMode.dark) {
      return 'dark';
    } else {
      return 'light';
    }
  }

  set mode(NMapThemeMode value) {
    _mode = value;
    notifyListeners();
  }

  void toggleMode() {
    log.debug('mode before toggle is $_mode');
    if (kDebugMode) {
      // Makes debugging themes easier by allowing for the change of
      // initialize function while the App is being debugged
      if (rootContext != null) {
        initialize(rootContext: rootContext!);
      }
    }
    _mode =
        _mode == NMapThemeMode.light ? NMapThemeMode.dark : NMapThemeMode.light;
    log.debug('mode after toggle is $_mode');
    notifyListeners();
  }

  ThemeData get themeData {
    ThemeData rc;
    switch (_mode) {
      case NMapThemeMode.light:
        rc = _themeLight!;
        break;
      case NMapThemeMode.dark:
        rc = _themeDark!;
        break;
      default:
        rc = _theme!;
        break;
    }
    return rc;
  }

  ThemeData get dark => _themeDark!;
  ThemeData get light => _themeLight!;

  void initialize({required BuildContext rootContext}) {
    _theme = ThemeData(
      primarySwatch: Colors.indigo, //getMaterialColor(kDefaultColor),
    );

    _themeLight = ThemeData.light(useMaterial3: true).copyWith(
      disabledColor: Colors.indigo.shade100,  // Confirmed Menu disabled color
      focusColor: Colors.red,  // Confirmed dropdown focus color
      hoverColor: Colors.indigo[200], // Confirmed menu hover color
      secondaryHeaderColor: Colors.indigo[900], // Confirmed - table title
      //focusColor: Colors.indigo[100],


      scaffoldBackgroundColor: Colors.indigo.shade50,
      primaryColor: Colors.indigo,
      splashColor: Colors.purple,
      highlightColor: Colors.indigo[900], // Confirmed (quick option background)
      primaryColorLight: Colors.indigo[200], // Confirmed (menu color)
      primaryColorDark: Colors.indigo[500], // Confirmed Selected Tab Menu foreground

      // canvasColor: Colors.indigo[100],
      dividerTheme: DividerThemeData(color: Colors.indigoAccent.shade700),
      textTheme: TextTheme(
        bodyMedium: TextStyle(color: Colors.indigoAccent.shade700),
        displayMedium: TextStyle(color: Colors.indigo.shade900),
        labelMedium: TextStyle(
            color: Colors.indigo.shade900, fontSize: kDefaultMenuFontSize),
      ),
      colorScheme: ColorScheme.fromSeed(
        primary: Colors.indigo,
        seedColor: Colors.indigo,
        brightness: Brightness.light,
      ),
      iconTheme: const IconThemeData(color: Colors.white, opacity: 1.0),
    );

    _themeDark = ThemeData.dark(useMaterial3: true).copyWith(
      hoverColor: kAccentColor,
      scaffoldBackgroundColor: Colors.indigo[900],
      primaryColor: Colors.indigo,
      disabledColor: Colors.indigo.shade100,
      primaryColorLight: Colors.indigo.shade900,
      primaryColorDark: Colors.indigo[300],
      // canvasColor: Colors.white,
      dividerTheme: const DividerThemeData(color: Colors.indigoAccent),
      textTheme: TextTheme(
        bodyMedium: const TextStyle(color: Colors.indigoAccent),
        displayMedium: TextStyle(color: Colors.indigoAccent.shade100),
        labelMedium: TextStyle(
            color: Colors.indigoAccent.shade100,
            fontSize: kDefaultMenuFontSize),
      ),
      colorScheme: ColorScheme.fromSeed(
        primary: Colors.indigo,
        seedColor: Colors.indigo,
        brightness: Brightness.dark,
      ),
      tabBarTheme: TabBarTheme(
        unselectedLabelColor: Colors.indigo.shade600,
        labelColor: Colors.indigoAccent,
      ),
      iconTheme: const IconThemeData(color: Colors.black, opacity: 1.0),
    );

    ThemeData light = ThemeData.light(useMaterial3: true).copyWith(
      scaffoldBackgroundColor: Colors.indigo.shade50,
      secondaryHeaderColor: Colors.black54,
      splashColor: Colors.purple,
      dividerColor: Colors.red,
      highlightColor: Colors.indigo[900],
      primaryColorLight: Colors.indigo[200],
      focusColor: Colors.indigo[100],
      canvasColor: Colors.indigo[100],
      iconTheme: const IconThemeData(color: Colors.white, opacity: 1.0),
    );

    ThemeData dark = ThemeData.dark(useMaterial3: true).copyWith(
      primaryColor: Colors.indigo.shade200,
      primaryColorLight: Colors.indigo.shade400,
      primaryColorDark: Colors.indigo.shade200,
      secondaryHeaderColor: Colors.white54, // Colors.black54,
      // canvasColor: Colors.indigo.shade800,
      // hintColor: Colors.grey.shade500,
      dividerColor: Colors.red,
      highlightColor: Colors.indigo[100],
      disabledColor: Colors.grey,
      splashColor: Colors.purple,
      scaffoldBackgroundColor: Colors.indigo.shade900,
      focusColor: Colors.indigo[800],
      canvasColor: Colors.indigo.shade600,
      iconTheme: const IconThemeData(color: Colors.black, opacity: 1.0),
    );

/*    _themeLight = ThemeData.light(useMaterial3: true).copyWith(
      primaryColor: kDefaultColor,
      secondaryHeaderColor: Colors.black,
      primaryColorLight: Colors.indigo.shade100,
      primaryColorDark: Colors.indigo.shade800,
      focusColor: Colors.indigoAccent.shade400,
      canvasColor: Colors.indigo.shade400,
      disabledColor: Colors.red,
      scaffoldBackgroundColor: Colors.white70,
      // textTheme: defaultMenuTheme,
    );
    _themeDark = ThemeData.dark(useMaterial3: true).copyWith(
      primaryColor: Colors.indigo.shade200,
      primaryColorLight: Colors.indigo.shade400,
      primaryColorDark: Colors.indigo.shade200,
      focusColor: Colors.indigoAccent.shade100,
      secondaryHeaderColor: Colors.black,
      canvasColor: Colors.indigo.shade800,
      hintColor: Colors.grey.shade500,
      disabledColor: Colors.grey,
      scaffoldBackgroundColor: Colors.black87,
    );*/
    initialized = true;
    _mode = NMapThemeMode.dark;
  }
}
