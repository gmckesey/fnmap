import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:ini/ini.dart';
import 'package:nmap_gui/constants.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:glog/glog.dart';

const String kTemporaryPath = 'temporaryPath';
const String kApplicationSupportPath = 'applicationSupportPath';
const String kDownloadsPath = 'downloadsPath';
const String kLibraryPath = 'libraryPath';
const String kApplicationDocumentsPath = 'applicationDocumentsPath';
const String kExternalCachePath = 'externalCachePath';
const String kExternalStoragePath = 'externalStoragePath';


class ScanProfile with ChangeNotifier {
  late String fileName;
  late Directory? _appSupportDirectory;
  late Config _config;
  GLog log = GLog('ScanProfile',
    /*flag: gLogALL*/
    package: kPackageName,
  );

  ScanProfile({this.fileName = 'scan_profile.usp'}) {
    _config = Config();
  }

  Future<void> parse() async {
    String scanFile;

    _appSupportDirectory = await getApplicationSupportDirectory();
    scanFile = path.join(_appSupportDirectory!.path, fileName);
    List<String> lines;
    try {
      lines = await File(scanFile).readAsLines();
    } on PathNotFoundException catch(_)  {
      log.warning('The file [$scanFile] cannot be found, '
          'defaulting to default profiles');
      lines = kDefaultProfiles;
      try {
        File(scanFile).writeAsString(Config.fromStrings(lines).toString());
      } catch (e) {
        log.error('Error $e writing to profile file $e');
      }
    } catch (e) {
      log.warning('Error $e parsing file [$scanFile]');
      lines = kDefaultProfiles;
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
    notifyListeners();
  }

  Config get config => _config;
}
