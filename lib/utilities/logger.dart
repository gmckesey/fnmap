import 'dart:convert';
import 'dart:collection';
import 'package:logger/logger.dart';

const String nLogALL = 'ALL';
const String nLogTRACE = 'TRACE';
const String nLogDEFAULT = 'default';

class DefaultPrinter extends LogPrinter {
  static final levelPrefixes = {
    Level.verbose: '[VERBOSE]',
    Level.debug: '[DEBUG]',
    Level.info: '[INFO]',
    Level.warning: '[WARNING]',
    Level.error: '[ERROR]',
    Level.wtf: '[FATAL]',
  };

  static final levelColors = {
    Level.verbose: AnsiColor.fg(AnsiColor.grey(0.5)),
    Level.debug: AnsiColor.none(),
    Level.info: AnsiColor.fg(12),
    Level.warning: AnsiColor.fg(208),
    Level.error: AnsiColor.fg(196),
    Level.wtf: AnsiColor.fg(199),
  };

  final bool printTime;
  final bool colors;

  DefaultPrinter({this.printTime = false, this.colors = true});

  @override
  List<String> log(LogEvent event) {
    var messageStr = _stringifyMessage(event.message);
    var errorStr = event.error != null ? '  ERROR: ${event.error}' : '';
    var timeStr = printTime ? event.time.toIso8601String() : '';
    return ['${_labelFor(event.level)} $timeStr $messageStr$errorStr'];
  }

  String _labelFor(Level level) {
    var prefix = levelPrefixes[level]!;
    var color = levelColors[level]!;

    return colors ? color(prefix) : prefix;
  }

  String _stringifyMessage(dynamic message) {
    final finalMessage = message is Function ? message() : message;
    if (finalMessage is Map || finalMessage is Iterable) {
      var encoder = const JsonEncoder.withIndent(null);
      return encoder.convert(finalMessage);
    } else {
      return finalMessage.toString();
    }
  }
}


enum NLogType  { simple, pretty, prettier }

class LevelFilter extends LogFilter {
  @override
  bool shouldLog(LogEvent event) {
    if (event.level.index >= NLog._outputLevel.index) {
      return true;
    } else {
      return false;
    }
  }


}

class NLog {
  static final Map<String, bool> _gLogPackageMap = {nLogDEFAULT: true};
  static final Map<String, bool> _gLogFlags = {nLogDEFAULT: true};
  late NLogType _type;
  static Level _outputLevel = Level.info;
  late String _className;
  late String _package;
  late String _flag;

  // Sets the level at which logs will be output
  static setLevel(Level level) {
    _outputLevel = level;
  }

  // Set a package flag to allow log messages to be filtered by package name
  static void setPackage({required String packageName, bool enabled = true}) {
    if (!_gLogPackageMap.containsKey(packageName)) {
      _gLogPackageMap.addAll({packageName: enabled});
    } else {
      _gLogPackageMap[packageName] = enabled;
    }
  }

  // Return the list of packages such they can be inspected
  // TODO:  Where should a library define its package?
  UnmodifiableMapView<String, bool> get packageMap =>
      UnmodifiableMapView<String, bool>(_gLogPackageMap);

  // Set the log flag allowing a class of log messages to be filtered based
  // on program or library developer defined flags and controlled by the user
  // of the library.
  static void setLogFlag({required String flag, bool enabled = true}) {
    if (!_gLogFlags.containsKey(flag)) {
      _gLogFlags.addAll({flag: enabled});
    } else {
      _gLogFlags[flag] = enabled;
    }
  }

  NLog(String className, {NLogType type = NLogType.simple,
    String? package, String? flag}) {
    _type = type;
    _className = className;
    if (package == null) {
       _package = nLogDEFAULT;
    } else {
       _package = package;
    }
    if (flag == null) {
      _flag = nLogDEFAULT;
    } else {
      _flag = flag;
    }
  }

  final Logger _simpleLog = Logger(
    printer: DefaultPrinter(printTime: true, colors: true),
    filter: LevelFilter(),
  );

  final Logger _prettyLog = Logger(
    printer: PrettyPrinter(
      printTime: true,
      methodCount: 0,
      noBoxingByDefault: true, ),
    filter: LevelFilter(),
  );

  final Logger _prettierLog = Logger(
    printer: PrettyPrinter(methodCount: 8, printTime: true),
    filter: LevelFilter(),
  );

  String _formatMessage(String input) {
    String rc = '$_className: $input';
    return rc;
  }
  Logger _getLogger(NLogType type) {
    Logger log;
    switch(type) {
      case NLogType.simple:
        log = _simpleLog;
        break;
      case NLogType.pretty:
        log = _prettyLog;
        break;
      case NLogType.prettier:
        log = _prettierLog;
        break;
    }
    return log;
  }

  // Check if package was enabled for logging
  // this allows libraries to have logging enabled or enabled
  // based on their package name.  Packages enabled for logging
  // have to be set in the calling program, typically in main
  bool _packageEnabled(String package) {
    bool rc = false;
    if (NLog._gLogPackageMap.containsKey(package)) {
      rc = NLog._gLogPackageMap[package]!;
    }
    return rc;
  }

  // Check if logging flag set
  // the flag allows a user to set classes of log messages to
  // be emitted only when the static flag was set
  // typically in the main function
  bool _isFlagSet(String? flag) {
    String? f = flag ?? _flag;
    if (f == 'ALL') {
      return true;
    }
    bool rc = _gLogFlags[f] != null ? _gLogFlags[f]! : false;
    return rc;
  }

  void verbose(dynamic msg, {String? flag}) {
    if (_isFlagSet(flag) && _packageEnabled(_package)) {
      _getLogger(_type).v(_formatMessage(msg));
    }
  }

  void debug (dynamic msg, {String? flag}) {
    if (_isFlagSet(flag) && _packageEnabled(_package)) {
      _getLogger(_type).d(_formatMessage(msg));
    }
  }

  void info(dynamic msg, {String? flag}) {
    if (_isFlagSet(flag) && _packageEnabled(_package)) {
      _getLogger(_type).i(_formatMessage(msg));
    }
  }

  void warning(dynamic msg, {String? flag}) {
    if (_isFlagSet(flag) && _packageEnabled(_package)) {
      _getLogger(_type).w(_formatMessage(msg));
    }
  }

  void error(dynamic msg, {String? flag}) {
    if (_isFlagSet(flag) && _packageEnabled(_package)) {
      _getLogger(_type).e(_formatMessage(msg));
    }
  }

  void fatal(dynamic msg, {String? flag}) {
    if (_isFlagSet(flag) && _packageEnabled(_package)) {
      _getLogger(_type).wtf(_formatMessage(msg));
    }
  }


}

