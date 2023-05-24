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

  set mode(NMapThemeMode value) {
    _mode = value;
    notifyListeners();
  }

  void toggleMode() {
    log.debug('mode before toggle is $_mode');
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
    );
    initialized = true;
    _mode = NMapThemeMode.light;
  }
}