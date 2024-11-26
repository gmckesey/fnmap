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
      secondaryHeaderColor: Colors.black87,
      splashColor: const Color(0xff412791),
    );
    _themeDark = ThemeData.dark(useMaterial3: true).copyWith(
      primaryColor: const Color(0xffdbb9eb), // Colors.white60,
      primaryColorLight: Colors.black,
      primaryColorDark: const Color(0xffb8cbeb), //Colors.indigo, //Colors.white70,
      secondaryHeaderColor: Colors.white70,
      focusColor: Colors.white12,
      splashColor: const Color(0xffcbb6ec),
    );

/*
    _themeLight = ThemeData.light(useMaterial3: true).copyWith(
      primaryColor: Colors.indigo.shade400,
      primaryColorLight: Colors.indigo[200], // Confirmed (menu color)
      primaryColorDark:
          Colors.indigo[500], // Confirmed Selected Tab Menu foreground
      scaffoldBackgroundColor: Colors.indigo.shade100,
      splashColor: Colors.purple,
      highlightColor: Colors.indigo[900], // Confirmed (quick option background)
      disabledColor: Colors.indigo.shade200, // Confirmed Menu disabled color
      focusColor: Colors.indigo.shade300, // Confirmed dropdown focus color
      hoverColor: Colors.indigo[500], // Confirmed menu hover color
      secondaryHeaderColor: Colors.indigo[300], // Confirmed - table title
      canvasColor: Colors.indigo.shade100, // Confirmed - table out of bounds background
      dialogTheme: DialogTheme(
        contentTextStyle: TextStyle(color: Colors.indigo.shade800),
        titleTextStyle: TextStyle(fontSize: 18, color: Colors.indigo.shade900),
        shape: const BeveledRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(2.0))),
      ),
      inputDecorationTheme: InputDecorationTheme(
          hintStyle: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade500,
              fontStyle: FontStyle.italic)),
      dividerTheme: DividerThemeData(color: Colors.indigoAccent.shade700),
      textTheme: TextTheme(
        bodyMedium: TextStyle(color: Colors.indigoAccent.shade700),
        bodySmall: TextStyle(color: Colors.indigo.shade800),
        displayMedium: TextStyle(color: Colors.indigo.shade900),
        headlineSmall: TextStyle(color: Colors.indigo.shade800),
        labelMedium: TextStyle(
            color: Colors.indigo.shade900, fontSize: kDefaultMenuFontSize),
      ),
      colorScheme: ColorScheme.fromSeed(
        primary: Colors.indigo,
        seedColor: Colors.indigo,
        brightness: Brightness.light,
      ),
      iconTheme: const IconThemeData(color: Colors.indigo, opacity: 1.0),
      primaryIconTheme: const IconThemeData(color: Colors.red),
    );
*/
/*
    _themeDark = ThemeData.dark(useMaterial3: true).copyWith(
        primaryColor: Colors.indigo,
        primaryColorLight: Colors.indigo.shade200, // Main menu text color
        primaryColorDark: Colors.indigo[800],
        secondaryHeaderColor: Colors.white38,
        scaffoldBackgroundColor: Colors.indigo[900],
        splashColor: Colors.indigoAccent,
        highlightColor: Colors.indigoAccent,
        disabledColor: Colors.indigo.shade700,
        dialogBackgroundColor: Colors.indigo.shade800,
        focusColor: Colors.indigoAccent.shade700,
        hoverColor: Colors.indigo.shade700,
        canvasColor: Colors.indigo.shade800,
        inputDecorationTheme: InputDecorationTheme(
            hintStyle: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade500,
                fontStyle: FontStyle.italic)),
        dialogTheme: DialogTheme(
          contentTextStyle: TextStyle(color: Colors.indigo.shade200),
          titleTextStyle: TextStyle(fontSize: 18, color: Colors.indigo.shade50),
          shape: const BeveledRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(2.0))),
        ),

        // canvasColor: Colors.white,
        dividerTheme: const DividerThemeData(color: Colors.indigoAccent),
        textTheme: TextTheme(
          bodyMedium: TextStyle(color: Colors.indigoAccent.shade200),
          bodySmall: TextStyle(color: Colors.indigo.shade100),
          displayMedium: TextStyle(color: Colors.indigoAccent.shade100),
          headlineSmall: TextStyle(color: Colors.indigo.shade200),
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
          // unselectedLabelStyle: TextStyle(color: Colors.red)
        ),
        iconTheme: const IconThemeData(color: Colors.indigo, opacity: 1.0),
        textButtonTheme: TextButtonThemeData(
            style: ButtonStyle(
          // Dialog buttons background and foreground colors
          backgroundColor:
              MaterialStateProperty.all<Color>(Colors.indigo.shade800),
          foregroundColor:
              MaterialStateProperty.all<Color>(Colors.indigo.shade400),
        )));
*/

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

    initialized = true;
    _mode = NMapThemeMode.dark;
  }
}
