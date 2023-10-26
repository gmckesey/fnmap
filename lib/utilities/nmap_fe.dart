import 'package:args/args.dart';
import 'package:fnmap/utilities/ip_address_validator.dart';
import 'package:fnmap/utilities/logger.dart';

// Class to convert nmap command line to and from
// flutter flags and options
class NFECommand {
  //TODO: (2023-10-12) Consider explicitly adding a target field rather than relying on it being
  // the last String in the _argument List.
  late List<String> _arguments;
  late String _program;
  late ArgParser _parser;
  ArgResults? _results;
  bool _isValid = true;

  late NLog log = NLog('NFECommand'); // package: 'NFECommand');
  NLog trace = NLog('NFECommand', flag: nLogTRACE, package: 'NFECommand');

  // We are using Records to capture the conversions
  // where option contains the options and legacy contains
  // the nmap options that have arguments
  // here are the 'target' options
  final List<({String legacy, String option})> _targetOptions = [
    (legacy: '--exclude', option: 'exclude'),
    (legacy: '--excludefile', option: 'exclude-file'),
    (legacy: '-iL', option: 'target-list-file'),
    (legacy: '-iR', option: 'scan-random-hosts'),
    (legacy: '-p', option: 'ports'),
  ];

  final List<({String legacy, String flag})> _timingFlags = [
    (legacy: '-T0', flag: 'timing-paranoid'),
    (legacy: '-T1', flag: 'timing-sneaky'),
    (legacy: '-T2', flag: 'timing-polite'),
    (legacy: '-T3', flag: 'timing-normal'),
    (legacy: '-T4', flag: 'timing-aggressive'),
    (legacy: '-T5', flag: 'timing-insane'),
  ];
  // Flags are used to convert from options with no arguments
  // Here are the 'scan' flags
  final List<({String legacy, String flag})> _scanFlags = [
    (legacy: '-A', flag: 'scan-aggressive'),
    (legacy: '-O', flag: 'os-detection'),
    (legacy: '-n', flag: 'disable-rdns'),
    (legacy: '-6', flag: 'ipv6'),
    (legacy: '-F', flag: 'fast-scan'),
  ];

  // Here are the 'scan options'
  // a few of the arguments have a small set of allowable
  // options, so these are captured in the allowed field
  // an allowed field of null means that any value for argument is allowed
  final List<
          ({String option, List<({String argument, String legacy})> allowed})>
      _scanOptions = [
    (
      option: 'tcp-scan',
      allowed: [
        (argument: 'ack', legacy: '-sA'),
        (argument: 'fin', legacy: '-sF'),
        (argument: 'maimon', legacy: '-sM'),
        (argument: 'null', legacy: '-sN'),
        (argument: 'syn', legacy: '-sS'),
        (argument: 'tcp-connect', legacy: '-sT'),
        (argument: 'scan-window', legacy: '-sW'),
        (argument: 'xmas-tree', legacy: '-sX'),
      ]
    ),
    (
      option: 'other-scan',
      allowed: [
        (argument: 'udp', legacy: '-sU'),
        (argument: 'ip', legacy: '-sO'),
        (argument: 'list', legacy: '-sL'),
        (argument: 'no-port', legacy: '-sn'),
        (argument: 'sctp-init', legacy: '-sY'),
        (argument: 'sctp-cookie-echo', legacy: '-sZ')
      ]
    ),
    (
      option: 'version',
      allowed: [
        (argument: 'light', legacy: '--version-light'),
        (argument: 'all', legacy: '--version-all')
      ]
    )
  ];

  // These are the flags related to ping
  final List<({String legacy, String flag})> _pingFlags = [
    (legacy: '-Pn', flag: 'no-ping-before-scan'),
    (legacy: '-PE', flag: 'icmp-ping'),
    (legacy: '-PP', flag: 'icmp-timestamp-request'),
    (legacy: '-PM', flag: 'icmp-netmask-request'),
    (legacy: '-Pn', flag: 'skip-host-discovery'),
    (legacy: '-PR', flag: 'arp-ping'),
    (legacy: '--disable-arp-ping', flag: 'disable-arp-ping'),
  ];

  // Here are additional options
  final List<({String legacy, String option})> _otherOptions = [
    (legacy: '--ttl', option: 'ttl'),
    (legacy: '-d', option: 'debug-level'),
    (legacy: '-v', option: 'verbosity-level'),
    (legacy: '--max-retries', option: 'max-retries'),
    (legacy: '-sI', option: 'idle-scan'),
    (legacy: '-b', option: 'ftp-bounce-attack'), // TODO: Support optional arguments
    (legacy: '--version-intensity', option: 'version-intensity'),
    (legacy: '--extra-options', option: 'extra-options'),
  ];

  // Here are additional flags
  final List<({String legacy, String flag})> _otherFlags = [
    (legacy: '-f', flag: 'fragment-ip-packets'),
    (legacy: '--packet-trace', flag: 'packet-trace'),
    (legacy: '-r', flag: 'randomize-scanned-ports'),
    (legacy: '--traceroute', flag: 'traceroute'),
    (legacy: '-sV', flag: 'version-detection'),
    (legacy: '--version-trace', flag: 'version-trace'),
    (legacy: '--allports', flag: 'allports'),
/*
    (legacy: '-v1', flag: 'verbosity-level-1'),
    (legacy: '-v2', flag: 'verbosity-level-2'),
    (legacy: '-v3', flag: 'verbosity-level-3'),
    (legacy: '-v4', flag: 'verbosity-level-4'),
*/

  ];

  final List<({String legacy, String option})> _pingOptions = [
    (legacy: '-PA', option: 'ping-tcp-ack'),
    (legacy: '-PS', option: 'ping-tcp-syn'),
    (legacy: '-PU', option: 'probe-udp'),
    (legacy: '-PO', option: 'probe-ip-proto'),
    (legacy: '-PY', option: 'ping-sctp-init'),
  ];

  // Here are the source options
  final List<({String legacy, String option})> _sourceOptions = [
    (legacy: '-D', option: 'decoys'),
    (legacy: '-S', option: 'source'),
    (legacy: '--source-port', option: 'source-port'),
    (legacy: '-e', option: 'network-interface'),
  ];

  final List<({String legacy, String option})> _timingOptions = [
    (legacy: '--host-timeout', option: 'host-timeout'),
    (legacy: '--max-rtt-timeout', option: 'max-rtt-timeout'),
    (legacy: '--min-rtt-timeout', option: 'min-rtt-timeout'),
    (legacy: '--initial-rtt-timeout', option: 'initial-rtt-timeout'),
    (legacy: '--max-hostgroup', option: 'max-hostgroup'),
    (legacy: '--min-hostgroup', option: 'min-hostgroup'),
    (legacy: '--max-parallelism', option: 'max-parallelism'),
    (legacy: '--min-parallelism', option: 'min-parallelism'),
    (legacy: '--max-scan-delay', option: 'max-scan-delay'),
    (legacy: '--scan-delay', option: 'min-scan-delay'),
  ];

  NFECommand({List<String>? arguments}) {
    _initializeVars();
    if (arguments == null || arguments.isEmpty) {
      _arguments = [];
      _program = 'nmap';
    } else {
      _arguments = arguments.sublist(1);
      _program = arguments[0];
    }

    List<String> modern = toModern(_arguments);
    ArgResults? oldResults = _results;
    try {
      _results = _parser.parse(modern);
      _isValid = true;
    } catch (parserException) {
      log.debug(
          'NFECommand:Constructor - exception $parserException parsing $modern');
      _results = oldResults;
      _isValid = false;
    }
  }

  NFECommand.fromString(String cmd) {
    List<String> arguments;

    _initializeVars();
    // This RegExp finds quoted arguments in the command line
    if (cmd.isNotEmpty) {
      RegExp re = RegExp(r'([XYZ])(.*)\1'
          .replaceAll("X", r'"')
          .replaceAll('Y', r"`")
          .replaceAll('Z', r"'"));
      Iterable<Match> matches = re.allMatches(cmd);

      // Replace all of the quoted arguments with a placeholder
      // We need to do this so that we can parse the arguments
      int n = 1;
      for (var m in matches) {
        String strMatch = m[0]!;
        cmd = cmd.replaceFirst(strMatch, 'place_holder_$n');
        n++;
      }

      // With the placeholders we can now split the command line using whitespace as
      // a separator between arguments.
      arguments = cmd.split(RegExp(r'\s'));

      // Now that we have the arguments as a list of strings we can
      // replace the placeholders with the strings that they replaced.
      int l = 1;
      for (var m in matches) {
        String placeHolder = 'place_holder_$l';
        for (int index = 0; index < arguments.length; index++) {
          if (arguments[index] == placeHolder) {
            arguments[index] = m[0]!;
            break;
          }
        }
        n++;
      }
      _arguments = arguments.sublist(1);
      _program = arguments[0];
    } else {
      _arguments = [];
      _program = 'nmap';
    }

    List<String> modern = toModern(_arguments);
    ArgResults? oldResults = _results;
    try {
      _results = _parser.parse(modern);
      String? ip = target;
      if (ip == null) {
        _isValid = true;
      } else if (isValidIPAddress(ip)) {
        _isValid = true;
      } else {
        _isValid = false;
      }
    } catch (parserException) {
      log.debug('fromString - parser exception $parserException parsing $modern');
      _results = oldResults;
      _isValid = false;
    }
  }

  NFECommand.fromModern({required List<String> arguments, String? program}) {
    _initializeVars();
    if (program != null) {
      _program = program;
      _results = _parser.parse(arguments);
    } else {
      _program = arguments[0];
      _results = _parser.parse(arguments.sublist(1));
    }
    if (_results != null) {
      _arguments = toLegacy(_results!);
    }
  }


  void _initializeVars() {
    _parser = ArgParser();
    _scanOptionConfig();
    _sourceOptionConfig();
    _pingOptionConfig();
    _targetOptionConfig();
    _otherOptionConfig();
    _timingOptionConfig();
  }

  List<String> get arguments => _arguments;

  String get cmdLine => _results != null
      ? '$_program ${arguments.join(" ")} ${_results!.rest.join(" ")}'
      : '$_program ${arguments.join(" ")}';

  bool get isValid => _isValid;

  List<({String legacy, String flag})> get timingFlags => _timingFlags;

  String get program => _program;
  ArgResults? get results => _results;

  // Target is the last argument that is not parsed
  String? get target {
    String? value; // Will return null, if there is no target
    ArgResults? results = _results;
    if (results != null && results.rest.isNotEmpty) {
        // will return anything at the end of the parsed options
        value = results.rest.join(" ").trim();
        if (value.isEmpty) {
          value = null;
        }
    }
    return value;
  }

  List<String>
  get tcpScanOptions {
    List<String> rc = [];
    for (var o in _scanOptions) {
      if (o.option == 'tcp-scan') {
        for (var arg in o.allowed) {
          rc.add(arg.argument);
        }
      }
    }
    return rc;
  }

  List<String>
  get otherScanOptions {
    List<String> rc = [];
    for (var o in _scanOptions) {
      if (o.option == 'other-scan') {
        for (var arg in o.allowed) {
          rc.add(arg.argument);
        }
      }
    }
    return rc;
  }


  void _pingOptionConfig() {
    for (var f in _pingFlags) {
      _parser.addFlag(f.flag);
      trace.debug('_pingOptionConfig adding flag ${f.flag}');
    }

    for (var o in _pingOptions) {
      _parser.addOption(o.option);
      trace.debug('_pingOptionConfig adding option ${o.option}');
    }
  }

  void _sourceOptionConfig() {
    for (var o in _sourceOptions) {
      _parser.addOption(o.option);
      trace.debug('_sourceOptionConfig adding option ${o.option}');
    }
  }

  void _scanOptionConfig() {
    List<String> toAllowed(
        List<({String argument, String legacy})> allowedList) {
      List<String> list = [];
      for (var rec in allowedList) {
        list.add(rec.argument);
      }
      return list;
    }

    // Configure 'scan' options
    for (var f in _scanFlags + _timingFlags) {
      _parser.addFlag(f.flag);
      trace.debug('_scanOptionConfig adding flag ${f.flag}');
    }

    for (var o in _scanOptions) {
      _parser.addOption(o.option, allowed: toAllowed((o.allowed)));
      trace.debug('_scanOptionConfig adding option ${o.option} '
          'with allowed = ${toAllowed(o.allowed)}');
    }
  }

  void _targetOptionConfig() {
    for (var o in _targetOptions) {
      _parser.addOption(o.option);
      trace.debug('_targetOptionConfig adding option ${o.option}');
    }
  }

  void _otherOptionConfig() {
    for (var f in _otherFlags) {
      _parser.addFlag(f.flag);
      trace.debug('_otherOptionConfig adding flag ${f.flag}');
    }

    for (var o in _otherOptions) {
      _parser.addOption(o.option);
      trace.debug('_otherOptionConfig adding option ${o.option}');
    }
  }

  void _timingOptionConfig() {
    for (var o in _timingOptions) {
      _parser.addOption(o.option);
      trace.debug('_timingOptionConfig adding option ${o.option}');
    }
  }



  String? _toModernFlag(String legacyFlag) {
    String? modernFlag;
    for (var f in _scanFlags + _timingFlags + _pingFlags + _otherFlags) {
      if (f.legacy == legacyFlag) {
        modernFlag = '--${f.flag}';
        break;
      }
    }

    trace.debug('_toModernFlag: processing flag $legacyFlag '
        '${modernFlag != null ? 'found' : 'not found'}');
    return modernFlag;
  }

  // Take a legacy option and convert it modern option that may also
  // have an argument
  ({String option, String? argument, bool skipArg})? _toModernOption(
      String legacyOption) {
    String? modernOption;
    String? modernArgument;
    bool skip = false;
    bool found = false;

    trace.debug('_toModernOption: processing option $legacyOption');
    // These are normal looking options
    for (var f
        in _targetOptions + _sourceOptions + _otherOptions + _timingOptions) {
      if (f.legacy == legacyOption) {
        modernOption = '--${f.option}';
        found = true;
        break;
      }
    }
    if (!found) {
      // Need to treat ping Options as flags as there is no space between the
      // option and the arguments
      for (var f in _pingOptions) {
        if (legacyOption.startsWith(f.legacy)) {
          modernOption = '--${f.option}';
          String argument = legacyOption.substring(f.legacy.length);
          modernArgument = argument.isNotEmpty ? argument : null;
          skip = true;
          found = true;
          break;
        }
      }
    }
    if (!found) {
      // Some scan options have specific allowable values for the arguments
      for (var f in _scanOptions) {
        for (var a in f.allowed) {
          if (a.legacy == legacyOption) {
            modernOption = '--${f.option}';
            modernArgument = a.argument;
            found = true;
            break;
          }
        }
        if (found) {
          break;
        }
      }
    }
    trace.debug('_toModernOption: processing flag $legacyOption '
        '${modernOption != null ? 'found' : 'not found'}');
    if (modernOption != null) {
      return (option: modernOption, argument: modernArgument, skipArg: skip);
    } else {
      //return (option: "", argument: "", skipArg: false);
      return null;
    }
  }

  List<String> toModern(List<String> legacyOptions) {
    List<String> modernOptions = [];
    bool finished = false;
    int optIndex = 0;

    String currentOpt;
    while (!finished) {
      if (optIndex >= legacyOptions.length) {
        finished = true;
      } else {
        currentOpt = legacyOptions[optIndex];
        String? modernFlag = _toModernFlag(currentOpt);
        if (modernFlag != null) {
          modernOptions.add(modernFlag);
          optIndex++;
        } else {
          if (currentOpt == '-v') {
            int level = 1;
            int i = optIndex + 1;
            while (i < legacyOptions.length && legacyOptions[i] == '-v') {
              level++;
              i++;
            }
            modernOptions.add('--verbosity-level');
            modernOptions.add('$level');
            optIndex += level;
          } else {
            ({String option, String? argument, bool skipArg})? modernOption =
                _toModernOption(currentOpt);
            if (modernOption != null) {
              modernOptions.add(modernOption.option);
              // Ugly, but ping options don't have spaces so
              // there is no argument to skip while parsing
              if (!modernOption.skipArg) {
                optIndex++;
              }
              if (modernOption.argument != null) {
                modernOptions.add(modernOption.argument!);
              } else {
                modernOptions.add(legacyOptions[optIndex]);
              }
/*              if (optIndex + 1 <= legacyOptions.length) {
                modernOptions.add(legacyOptions[optIndex + 1]);
              }*/
            } else {
              // The option doesn't fit any option or flag so just pass through
              modernOptions.add(currentOpt);
            }
            optIndex++;
          }
        }
      }
    }

    trace.debug('toModern: legacy = $legacyOptions => $modernOptions');
    return modernOptions;
  }

  List<String> toLegacy(ArgResults results) {
    String? scanOption;
    List<String> legacyOptions = [];

    /// Check options
    // TARGET OPTIONS
    for (var o
        in _targetOptions + _sourceOptions + _otherOptions + _timingOptions) {
      if (o.option == 'verbosity-level' && results[o.option] != null) {
        int level = int.tryParse(results[o.option]) ?? 0;
        // For verbosity level you repeat the option # of level times
        // TODO: add support for -vn as well as -vv...
        // legacyOptions.add('${o.legacy}$level');
        String output = '';
        for (int i = 0; i < level; i++) {
          legacyOptions.add(o.legacy);
          output += '-v ';
        }
        if (level > 0) {
          trace.debug('toLegacy: {$o.option} $level = $level');
        }
        // Most options can be handled with this code.
      } else if (results[o.option] != null) {
        switch (o.option) {
          case 'ping-tcp-ack':
          case 'ping-tcp-syn':
          case 'probe-udp':
          case 'probe-ip-proto':
          case 'ping-sctop-init':
            legacyOptions.add('${o.legacy}${results[o.option]}');
            trace.debug(
                '(generic-one) ${o.option} = ${o.legacy}${results[o.option]}');
            break;
          default:
            trace.debug(
                '(generic-one) ${o.option} = ${o.legacy} ${results[o.option]}');
            legacyOptions.add(o.legacy);
            legacyOptions.add(results[o.option]);
            break;
        }
      }
    }

    // SCAN OPTIONS
    for (var sOptions in _scanOptions) {
      for (var o in sOptions.allowed) {
        // special handling for tcp-scan options
        if (sOptions.option == 'tcp-scan' && results[sOptions.option] != null) {
          switch (results[sOptions.option]) {
            case 'ack':
              scanOption = '-sA';
              break;
            case 'fin':
              scanOption = '-sF';
              break;
            case 'maimon':
              scanOption = '-sM';
              break;
            case 'null':
              scanOption = '-sN';
              break;
            case 'syn':
              scanOption = '-sS';
              break;
            case 'tcp-connect':
              scanOption = '-sT';
              break;
            case 'scan-window':
              scanOption = '-sW';
              break;
            case 'xmas-tree':
              scanOption = '-sX';
              break;
            default:
              break;
          }
          if (scanOption != null) {
            trace.debug('toLegacy: scanOption = $scanOption');
            legacyOptions.add(scanOption);
            // Break out of loop
            break;
          } // special handling for other-scan options
        } else if (sOptions.option == 'other-scan' && results[sOptions.option] != null) {
          switch (results[sOptions.option]) {
            case 'udp':
              scanOption = '-sU';
              break;
            case 'ip':
              scanOption = '-sO';
              break;
            case 'list':
              scanOption = '-sL';
              break;
            case 'no-port':
              scanOption = '-sn';
              break;
            case 'sctp-init':
              scanOption = '-sY';
              break;
            case 'sctp-cookie-echo':
              scanOption = '-sZ';
              break;
            default:
              break;
          }
          if (scanOption != null) {
            trace.debug('toLegacy: scanOption = $scanOption');
            legacyOptions.add(scanOption);
            break;
          }
        } else if (sOptions.option == 'version' &&
            results[sOptions.option] != null) {
          switch (results[sOptions.option]) {
            case 'light':
              scanOption = '--version-light';
              break;
            case 'all':
              scanOption = '--version-all';
              break;
            default:
              break;
          }
          if (scanOption != null) {
            // trace.debug('adding $scanOption/legacy flag');
            legacyOptions.add(scanOption);
            // Break out of loop
            break;
          }
        } else if (results[sOptions.option] != null) {
          // trace.debug(
          //    '(generic-option) ${sOptions.option} = ${o.legacy} ${results[sOptions.option]}');
          legacyOptions.add(o.legacy);
          legacyOptions.add(results[sOptions.option]);
          // Break out of loop
          break;
        }
      }
    }

    for (var f in _scanFlags + _timingFlags + _otherFlags) {
      // trace.debug('(generic-flag) ${f.flag} = ${f.legacy}');
      if (results[f.flag]) {
        trace.debug('toLegacy: found ${f.flag} adding ${f.legacy}');
        legacyOptions.add(f.legacy);
      }
    }

    // PING OPTIONS
    void processPingOptions() {
      // Create a list of records of all legacy and internal command line
      // flags

      for (var f in _pingFlags) {
        if (results[f.flag]) {
          trace.debug(''
              'processPingOptions: ${f.flag} = ${f.legacy}');
          legacyOptions.add(f.legacy);
        }
      }

      for (var f in _pingOptions) {
        if (results[f.option] != null) {
          trace.debug('${f.option} = ${f.legacy} ${results[f.option]}');
          // legacyOptions.add(f.legacy);
          legacyOptions.add(f.legacy + results[f.option]);
          // legacyOptions.add(results[f.option]);
        }
      }
    }

    processPingOptions();
    return legacyOptions;
  }
}
