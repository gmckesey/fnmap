import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:ini/ini.dart';
import 'package:nmap_gui/constants.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:glog/glog.dart';

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

  HighLightConfig({
    required this.label,
    required this.regex,
    this.bold = false,
    this.italic = false,
    this.underline = false,
    this.highlightArray = const [0, 0, 0],
    this.textColorArray = const [0xffff, 0xffff, 0xffff],
  });

  @override
  String toString() {
    return 're: $regex, textStyle:${textStyle.toString()}';
  }

  TextStyle get  textStyle {
    // Convert 16 bit color from config file to 8 bit flutter color
    Color color = Color.fromRGBO(textColorArray[0]~/8, textColorArray[1]~/8, textColorArray[2]~/8, 1.0);
    Color hiliteColor = Color.fromRGBO(
        highlightArray[0]~/8, highlightArray[1]~/8, highlightArray[2]~/8, 1.0);

    return TextStyle(
      color: color,
      background: Paint()..color = hiliteColor,
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
  GLog log = GLog('FnMapConfig', properties: gLogPropTrace);

  FnMapConfig({this.fileName = kConfigFilename});

  Future<void> parse() async {
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
    for (String section in _config.sections()) {
      log.debug('parse: section is [$section].');
      if (_config.options(section) != null) {
        Iterable<String> options = _config.options(section)!;
        for (String option in options) {
          String? value = _config.get(section, option);
          log.debug('parse: option is $option = $value');
        }
      }
    }
  }

  Config get config => _config;

  bool get highlightsEnabled =>
      _strToBool(_config.get(outputHighlightSection, 'enable_highlight'));

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

  List<HighLightConfig> highlights() {
    List<HighLightConfig> values = [];
    RegExp reHighlight = RegExp(r'highlight$');
    for (String section in _config.sections()) {
      if (reHighlight.hasMatch(section)) {
        String label;
        String? rex;
        bool bold = false;
        bool italic = false;
        bool underline = false;
        List<int> textColor = [0xffff, 0xffff, 0xffff];
        List<int> highlightColor = [0, 0, 0];

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
        String? value = _config.get(section, textColorOption);

        try {
          textColor =
              _strToIntList(value, section: section, option: textColorOption);
        } catch(e) {
          log.warning('highlights: error $e parsing section $section, '
              '$textColorOption = $value');
        }
        try {
          highlightColor =
              _strToIntList(value, section: section, option: highlightOption);
        } catch(e) {
          log.warning('highlights: error $e parsing section $section, '
              'highlightOption = $value');
        }
        HighLightConfig hc = HighLightConfig(
          label: label,
          regex: rex,
          bold: bold,
          italic: italic,
          underline: underline,
          textColorArray: textColor,
          highlightArray: highlightColor,
        );
        values.add(hc);
      }
    }

    return values;
  }
}
