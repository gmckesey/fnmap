import 'package:args/args.dart';
import 'package:fnmap/utilities/logger.dart';

// Class to convert nmap command line to and from
// flutter flags and options
class NFECommand {
  late List<String> _arguments;
  late ArgParser _parser;
  late ArgResults _results;

  late NLog log = NLog('NFECommand', package: 'NFECommand');
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
    (legacy: '-PM', flag: 'icmp-netmask-request')
  ];

  // Here are additional options
  final List<({String legacy, String option})> _otherOptions = [
    (legacy: '--ttl', option: 'ttl'),
    (legacy: '-d', option: 'debug-level'),
    (legacy: '-v', option: 'verbosity-level'),
    (legacy: '--max-retries', option: 'max-retries'),
    (legacy: '-sl', option: 'idle-scan'),
    (legacy: '-b', option: 'ftp-bounce-attack'),
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

  NFECommand({required List<String> arguments}) {
    _initializeVars();
    if (arguments.length > 1) {
      _arguments = arguments.sublist(1);
    } else {
      _arguments = [];
    }
    List<String> modern = toModern(_arguments);
    _results = _parser.parse(modern);
  }

  NFECommand.fromModern({required List<String> arguments}) {
    _initializeVars();
    _results = _parser.parse(_arguments);
    _arguments = toLegacy();
  }

  List<String> get arguments => _arguments;
  List<({String legacy, String flag})> get timingFlags => _timingFlags;

  void _initializeVars() {
    _parser = ArgParser();
    _scanOptionConfig();
    _sourceOptionConfig();
    _pingOptionConfig();
    _targetOptionConfig();
    _otherOptionConfig();
    _timingOptionConfig();
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

    /// TODO: Check here
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

  get results => _results;
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
  ({String option, String? argument})? _toModernOption(String legacyOption) {
    String? modernOption;
    String? modernArgument;

    bool found = false;
    trace.debug('_toModernOption: processing option $legacyOption');
    for (var f in _targetOptions +
        _sourceOptions +
        _pingOptions +
        _otherOptions +
        _timingOptions) {
      if (f.legacy == legacyOption) {
        modernOption = '--${f.option}';
        found = true;
        break;
      }
    }
    if (!found) {
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
      return (option: modernOption, argument: modernArgument);
    } else {
      return (option: "", argument: "");
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
            optIndex += level; // TODO: (2022-09-19) was level + 1
          } else {
            ({String option, String? argument})? modernOption =
                _toModernOption(currentOpt);
            if (modernOption != null) {
              modernOptions.add(modernOption.option);
              optIndex++;
              if (modernOption.argument != null) {
                modernOptions.add(modernOption.argument!);
              } else {
                modernOptions.add(legacyOptions[optIndex]);
              }
/*              if (optIndex + 1 <= legacyOptions.length) {
                modernOptions.add(legacyOptions[optIndex + 1]);
              }*/
            }
            optIndex++;
          }
        }
      }
    }

    trace.debug('toModern: legacy = $legacyOptions => $modernOptions');
    return modernOptions;
  }

  List<String> toLegacy() {
    ArgResults results = _results;
    String? scanOption;
    List<String> legacyOptions = [];

    /// Check options
    // TARGET OPTIONS
    for (var o in _targetOptions +
        _pingOptions +
        _sourceOptions +
        _otherOptions +
        _timingOptions) {
      if (o.option == 'verbosity-level' && results[o.option] != null) {
        int level = int.tryParse(results[o.option]) ?? 0;
        // For verbosity level you repeat the option # of level times
        String output = '';
        for (int i = 0; i < level; i++) {
          legacyOptions.add(o.legacy);
          output += '-v ';
        }
        if (level > 0) {
          trace.debug('{$o.option} $level = $output');
        }
        // Most options can be handled with this code.
      } else if (results[o.option] != null) {
        trace.debug(
            '(generic-one) ${o.option} = ${o.legacy} ${results[o.option]}');
        legacyOptions.add(o.legacy);
        legacyOptions.add(results[o.option]);
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
            trace.debug('scanOption = $scanOption');
            legacyOptions.add(scanOption);
          } // special handling for other-scan options
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
            trace.debug('adding $scanOption/legacy flag');
            legacyOptions.add(scanOption);
          }
        } else if (results[sOptions.option] != null) {
          trace.debug(
              '(generic-option) ${sOptions.option} = ${o.legacy} ${results[sOptions.option]}');
          legacyOptions.add(o.legacy);
          legacyOptions.add(results[sOptions.option]);
        }
      }
    }

    for (var f in _scanFlags + _timingFlags + _pingFlags + _otherFlags) {
      trace.debug('(generic-flag) ${f.flag} = ${f.legacy}');
      legacyOptions.add(f.legacy);
    }

    // PING OPTIONS
    void processPingOptions() {
      // Create a list of records of all legacy and internal command line
      // flags

      for (var f in _pingFlags) {
        if (results[f.flag]) {
          trace.debug('${f.flag} = ${f.legacy}');
          legacyOptions.add(f.legacy);
        }
      }

      for (var f in _pingOptions) {
        if (results[f.option] != null) {
          trace.debug('${f.option} = ${f.legacy} ${results[f.option]}');
          legacyOptions.add(f.legacy);
          legacyOptions.add(results[f.option]);
        }
      }
    }

    processPingOptions();
    return legacyOptions;
  }
}
