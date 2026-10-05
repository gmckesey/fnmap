import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:ini/ini.dart';
import 'package:fnmap/constants.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:fnmap/utilities/logger.dart';
import 'package:fnmap/utilities/contrast.dart';
import 'package:fnmap/models/dark_mode.dart';

String regexOption = 'regex';
String boldOption = 'bold';
String textColorOption = 'text';
String italicOption = 'italic';
String highlightOption = 'highlight';
String underlineOption = 'underline';
String outputHighlightSection = 'output_highlight';

class HighLightConfig {
  String label;
  String regex;
  bool bold;
  bool italic;
  bool underline;
  List<int> highlightArray;
  List<int> textColorArray;
  Color? overrideTextColor;
  Color? overrideHighlightColor;

  HighLightConfig({
    required this.label,
    required this.regex,
    this.bold = false,
    this.italic = false,
    this.underline = false,
    this.highlightArray = const [0, 0, 0],
    this.textColorArray = const [0xffff, 0xffff, 0xffff],
    this.overrideTextColor,
    this.overrideHighlightColor,
  });

  @override
  String toString() {
    return 're: $regex, textStyle:${textStyle.toString()}';
  }

  TextStyle get textStyle {
    // Convert 16 bit color from config file to 8 bit flutter color
    Color color = overrideTextColor ??
        Color.fromRGBO(textColorArray[0] ~/ 256, textColorArray[1] ~/ 256,
            textColorArray[2] ~/ 256, 1.0);
    Color highlightColor = overrideHighlightColor ??
        Color.fromRGBO(highlightArray[0] ~/ 256, highlightArray[1] ~/ 256,
            highlightArray[2] ~/ 256, 1.0);

    return TextStyle(
      color: color,
      background: highlightColor == Colors.transparent
          ? null
          : (Paint()..color = highlightColor),
      fontWeight: bold ? FontWeight.bold : FontWeight.normal,
      fontStyle: italic ? FontStyle.italic : FontStyle.normal,
      decoration: underline ? TextDecoration.underline : TextDecoration.none,
    );
  }
}

class FnMapConfig with ChangeNotifier {
  late String fileName;
  late Directory? _appSupportDirectory;
  late Config _config;
  NLog log = NLog('FnMapConfig', flag: nLogTRACE, package: kPackageName);
  NMapThemeMode darkMode;
  ThemeMode themeMode = ThemeMode.dark;
  FlexScheme themeScheme = FlexScheme.indigo;

  FnMapConfig(
      {this.fileName = kConfigFilename, this.darkMode = NMapThemeMode.unknown});

  void processConfig() {
    for (String section in _config.sections()) {
      log.debug('parse: section is [$section].');
      if (section == 'window') {
        Iterable<String> options = _config.options(section)!;
        for (String option in options) {
          String? value = _config.get(section, option);
          log.debug('parse: option is $option = $value');
          if (option == 'theme_mode') {
            switch (value) {
              case 'light':
                themeMode = ThemeMode.light;
                darkMode = NMapThemeMode.light;
                break;
              case 'dark':
                themeMode = ThemeMode.dark;
                darkMode = NMapThemeMode.dark;
                break;
              case 'system':
                themeMode = ThemeMode.system;
                darkMode = NMapThemeMode.unknown;
                break;
            }
          }
          if (option == 'theme_scheme') {
            themeScheme = FlexScheme.values.firstWhere(
              (e) => e.name == value,
              orElse: () => FlexScheme.indigo,
            );
          }
          if (option == 'theme' && _config.get(section, 'theme_mode') == null) {
            if (value == 'dark') {
              darkMode = NMapThemeMode.dark;
              themeMode = ThemeMode.dark;
            } else if (value == 'light') {
              darkMode = NMapThemeMode.light;
              themeMode = ThemeMode.light;
            }
          }
        }
      }
      if (_config.options(section) != null) {
        Iterable<String> options = _config.options(section)!;
        for (String option in options) {
          String? value = _config.get(section, option);
          log.debug('parse: option is $option = $value');
        }
      }
    }
    _syncPortListHighlightConfig(themeScheme);
  }

  Future<void> defaultOverwrite() async {
    String configFile = path.join(_appSupportDirectory!.path, fileName);
    try {
      File(configFile)
          .writeAsString(Config.fromStrings(kDefaultConfigs).toString());
    } catch (e) {
      log.error('Error $e writing to profile file $e');
      return;
    }
    processConfig();
    notifyListeners();
  }

  Future<void> parse(
      {void Function(int version, bool overwrite)? overwriteCallback}) async {
    String configFile;
    String zenMapFile;

    _appSupportDirectory = await getApplicationSupportDirectory();
    configFile = path.join(_appSupportDirectory!.path, fileName);
    List<String> lines;
    try {
      lines = await File(configFile).readAsLines();
    } on PathNotFoundException catch (_) {
      try {
        zenMapFile = path.join(_appSupportDirectory!.path, kZenmapConfFilename);
        lines = await File(zenMapFile).readAsLines();
      } on PathNotFoundException catch (_) {
        log.warning('Neither file [$fileName] nor [$kZenmapConfFilename] '
            'could be found in directory ${_appSupportDirectory!.path} '
            'defaulting to default configuration');
        lines = kDefaultConfigs;
      }
      try {
        File(configFile).writeAsString(Config.fromStrings(lines).toString());
      } catch (e) {
        log.error('Error $e writing to profile file $e');
      }
    } catch (e) {
      log.warning('Error $e parsing file [$configFile]');
      lines = kDefaultConfigs;
    }

    _config = Config.fromStrings(lines);

    int major = 0;
    int minor = 0;
    int patch = 0;
    int build = 0;

    try {
      major = int.parse(_config.get('version', 'major') ?? '0');
      minor = int.parse(_config.get('version', 'minor') ?? '0');
      patch = int.parse(_config.get('version', 'patch') ?? '0');
      build = int.parse(_config.get('version', 'build') ?? '0');
    } catch (e) {
      log.warning('Error $e parsing version information, defaulting to 0.0.0');
    }

    int configVersion = major * 10000 + minor * 1000 + patch * 100 + build;
    bool overwrite = configVersion < kConfigVersion;

    log.info('Configuration Version = $configVersion');
    if (overwriteCallback != null) {
      overwriteCallback(configVersion, overwrite);
    }
    if (!overwrite) {
      processConfig();
    }
  }

  Config get config => _config;

  bool get highlightsEnabled =>
      _strToBool(_config.get(outputHighlightSection, 'enable_highlight'));

  NMapThemeMode get mode => darkMode;

  bool isDark() {
    if (themeMode == ThemeMode.dark) return true;
    if (themeMode == ThemeMode.light) return false;
    return darkMode == NMapThemeMode.dark;
  }

  void setMode(NMapThemeMode mode) {
    darkMode = mode;
    if (mode == NMapThemeMode.dark) {
      themeMode = ThemeMode.dark;
    } else if (mode == NMapThemeMode.light) {
      themeMode = ThemeMode.light;
    } else {
      themeMode = ThemeMode.system;
    }
    updateTheme(themeMode: themeMode);
  }

  Future<void> saveConfig() async {
    if (_appSupportDirectory == null) return;
    String configFile = path.join(_appSupportDirectory!.path, fileName);
    try {
      await File(configFile).writeAsString(_config.toString());
    } catch (e) {
      log.error('Error $e saving configuration to $configFile');
    }
  }

  Future<void> updateTheme({ThemeMode? themeMode, FlexScheme? scheme}) async {
    if (!_config.hasSection('window')) {
      _config.addSection('window');
    }
    if (themeMode != null) {
      this.themeMode = themeMode;
      _config.set('window', 'theme_mode', themeMode.name);
      if (themeMode == ThemeMode.dark) {
        _config.set('window', 'theme', 'dark');
        darkMode = NMapThemeMode.dark;
      } else if (themeMode == ThemeMode.light) {
        _config.set('window', 'theme', 'light');
        darkMode = NMapThemeMode.light;
      } else {
        _config.set('window', 'theme', 'system');
        darkMode = NMapThemeMode.unknown;
      }
    }
    if (scheme != null) {
      themeScheme = scheme;
      _config.set('window', 'theme_scheme', scheme.name);
      _syncPortListHighlightConfig(scheme);
    }
    await saveConfig();
    notifyListeners();
  }

  void _syncPortListHighlightConfig(FlexScheme scheme) {
    if (!_config.hasSection('port_list_highlight')) {
      _config.addSection('port_list_highlight');
    }
    Color primary = scheme.data.light.primary;
    int r16 = (primary.r * 65535.0).round().clamp(0, 65535);
    int g16 = (primary.g * 65535.0).round().clamp(0, 65535);
    int b16 = (primary.b * 65535.0).round().clamp(0, 65535);
    _config.set('port_list_highlight', 'text', '[$r16, $g16, $b16]');
  }

  bool _strToBool(String? value) {
    bool response = false;
    switch (value) {
      case '1':
      case 'true':
      case 'TRUE':
      case 'True':
      case 'Y':
      case 'y':
        response = true;
        break;
    }
    return response;
  }

  List<int> _strToIntList(
    String? value, {
    required String section,
    required String option,
  }) {
    List<int> list = [];
    String? value = _config.get(section, option);
    String text;

    Map<String, dynamic> color = {};
    if (value != null) {
      text = '{ "$option": $value }';
      color = jsonDecode(text);
      list = (color[option] as List<dynamic>).map((element) {
        return element as int;
      }).toList();
    }

    return list;
  }

  List<HighLightConfig> highlights({Color? colorSchemeColor}) {
    List<HighLightConfig> values = [];
    RegExp reHighlight = RegExp(r'highlight$');
    NMapThemeMode themeMode = darkMode;
    final Color activeSchemeColor = colorSchemeColor ??
        (isDark() ? themeScheme.data.dark.primary : themeScheme.data.light.primary);

    for (String section in _config.sections()) {
      if (reHighlight.hasMatch(section)) {
        String label;
        String? rex;
        bool bold = false;
        bool italic = false;
        bool underline = false;
        List<int> highlightColor = [0xffff, 0xffff, 0xffff];
        List<int> textColor = [0, 0, 0];

        rex = _config.get(section, regexOption);
        // The outputHighlightSection is a special section that
        // enables or disables highlighting in general
        // If there is no regex, in a highlight section
        // quit and move on to the next section
        if (section == outputHighlightSection || rex == null) {
          continue;
        }
        label = section;
        bold = _strToBool(_config.get(section, boldOption));
        italic = _strToBool(_config.get(section, italicOption));
        underline = _strToBool(_config.get(section, underlineOption));
        String? textValue = _config.get(section, textColorOption);
        String? highlightValue = _config.get(section, highlightOption);
        FnColor background = FnColor.fromIntList(highlightColor);
        try {
          textColor = _strToIntList(textValue,
              section: section, option: textColorOption);
        } catch (e) {
          log.warning('highlights: error $e parsing section $section, '
              '$textColorOption = $textValue');
        }
        try {
          highlightColor = _strToIntList(highlightValue,
              section: section, option: highlightOption);
        } catch (e) {
          log.warning('highlights: error $e parsing section $section, '
              'highlightOption = $highlightValue');
        }

        Color? overrideTextColor;
        Color? overrideHighlightColor;

        if (section == 'port_list_highlight') {
          overrideTextColor = activeSchemeColor;
          overrideHighlightColor = Colors.transparent;
        } else if (themeMode == NMapThemeMode.dark) {
          // Use colors as is for light mode, but reverse the rgb background color
          // if in dark mode
          FnColor foreground = FnColor.fromIntList(textColor);
          background = FnColor.fromIntList(highlightColor).reverse();
          highlightColor = background.toIntList();

          //FnColor reverseFg = foreground.reverse();
          FnColor tintedFg = foreground.tint(0.8);
          // If the reverse foreground is more contrast than the foreground
          double fgRatio = background.getContrastRatio(foreground);
          double tintedRatio = background.getContrastRatio(tintedFg);
          if (fgRatio != 1.0 && fgRatio < tintedRatio) {
            if (tintedRatio < 4.5) {
              foreground = tintedFg.reverse();
            } else {
              foreground = tintedFg;
            }
            textColor = foreground.toIntList();
          } else if (fgRatio < 4.5) {
            foreground = foreground.reverse();
            textColor = foreground.toIntList();
          }
        }

        HighLightConfig hc = HighLightConfig(
          label: label,
          regex: rex,
          bold: bold,
          italic: italic,
          underline: underline,
          textColorArray: textColor,
          highlightArray: highlightColor,
          overrideTextColor: overrideTextColor,
          overrideHighlightColor: overrideHighlightColor,
        );
        values.add(hc);
      }
    }

    return values;
  }
}
