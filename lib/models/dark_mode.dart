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
    _mode = _mode == NMapThemeMode.light ? NMapThemeMode.dark : NMapThemeMode.light;
    log.debug('mode after toggle is $_mode');
    notifyListeners();
  }

  ThemeData get themeData {
    ThemeData rc;
    switch(_mode) {
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

  void initialize({required BuildContext rootContext}) {
    _theme = ThemeData(
      primarySwatch: Colors.indigo, //getMaterialColor(kDefaultColor),
    );

    _themeLight = ThemeData.light(useMaterial3: true).copyWith(
      scaffoldBackgroundColor: Colors.indigo.shade50,
      secondaryHeaderColor: Colors.black54,
    );
    _themeDark = ThemeData.dark(useMaterial3: true).copyWith(
      primaryColor: Colors.indigo.shade200,
      primaryColorLight: Colors.indigo.shade400,
      primaryColorDark: Colors.indigo.shade200,
      secondaryHeaderColor: Colors.white70,// Colors.black54,
      // canvasColor: Colors.indigo.shade800,
      // hintColor: Colors.grey.shade500,
      disabledColor: Colors.grey,
      scaffoldBackgroundColor: Colors.indigo.shade900,
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