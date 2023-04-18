import 'package:flutter/material.dart';
import 'package:nmap_gui/constants.dart';
import 'package:glog/glog.dart';

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
  GLog log = GLog('NMapDarkMode',
      flag: gLogTRACE, package: kPackageName);


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
    log.debug('mode before toggle is $_mode', flag: gLogTRACE);
    _mode = _mode == NMapThemeMode.light ? NMapThemeMode.dark : NMapThemeMode.light;
    log.debug('mode after toggle is $_mode', flag: gLogTRACE);
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

    TextStyle? defaultMenuTextStyle = Theme.of(rootContext).textTheme.bodyMedium?.copyWith(backgroundColor: Colors.white);
    TextTheme defaultMenuTheme;
    if (defaultMenuTextStyle != null) {
      defaultMenuTheme = Theme
          .of(rootContext)
          .textTheme
          .copyWith(bodyMedium: defaultMenuTextStyle);
    } else {
      TextStyle textStyle = TextStyle(
        inherit: false,
        color: Colors.black,
        backgroundColor: Colors.indigo.shade100,
        fontSize: 11,
      );
      defaultMenuTheme = Theme
          .of(rootContext)
          .textTheme
          .copyWith(bodyMedium: textStyle);
    }
    _themeLight = ThemeData.light(useMaterial3: true).copyWith(
      primaryColor: kDefaultColor,
      secondaryHeaderColor: Colors.black,
      primaryColorLight: Colors.indigo.shade100,
      primaryColorDark: Colors.indigo.shade800,
      focusColor: Colors.indigo.shade50,
      canvasColor: Colors.indigo.shade800,
      disabledColor: Colors.red,
      // textTheme: defaultMenuTheme,
    );
    _themeDark = ThemeData.dark(useMaterial3: true).copyWith(
      primaryColor: Colors.indigo.shade200,
      primaryColorLight: Colors.indigo.shade800,
      primaryColorDark: Colors.indigo.shade200,
      focusColor: Colors.indigo.shade50,
      secondaryHeaderColor: Colors.black,
      canvasColor: Colors.indigo.shade400,
      hintColor: Colors.grey.shade500,
      disabledColor: Colors.grey,
    );
    initialized = true;
    _mode = NMapThemeMode.light;
  }
}