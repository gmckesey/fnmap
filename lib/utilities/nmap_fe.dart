import 'package:args/args.dart';
import 'package:fnmap/utilities/logger.dart';

// Class to convert nmap command line to and from
// flutter flags and options
class NFECommand {
  late  List<String> _arguments;
  late ArgParser _parser;
  late ArgResults _results;
  NLog log = NLog('NFECommand', package: 'NFECommand');
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

  // Flags are used to convert from options with no arguments
  // Here are the 'scan' flags
  final List<({String legacy, String flag})> _scanFlags = [
    (legacy: '-A', flag: 'aggressive'),
    (legacy: '-O', flag: 'os-detection'),
    (legacy: '-sV', flag: 'version-detection'),
    (legacy: '-n', flag: 'disable-rdns'),
    (legacy: '-6', flag: 'ipv6'),
    (legacy: '-F', flag: 'fast-scan'),
    (legacy: '-T0', flag: 'timing-paranoid'),
    (legacy: '-T1', flag: 'timing-sneaky'),
    (legacy: '-T2', flag: 'timing-polite'),
    (legacy: '-T3', flag: 'timing-normal'),
    (legacy: '-T4', flag: 'timing-aggressive'),
    (legacy: '-T5', flag: 'timing-insane'),
  ];

  // Here are the 'scan options'
  // a few of the arguments have a small set of allowable
  // options, so these are captured in the allowed field
  // an allowed field of null means that any value for argument is allowed
  final List<({String legacy, String option, List<String>? allowed})>
  _scanOptions = [
    (
    legacy: '-sT',
    option: 'tcp-scan',
    allowed: [
      'ack',
      'fin',
      'maimon',
      'null',
      'syn',
      'tcp-connect',
      'scan-window',
      'xmas-tree'
    ]
    ),
    (
    legacy: '-sU',
    option: 'other-scan',
    allowed: ['udp', 'ip', 'list', 'no-port', 'sctp-init', 'sctp-cookie-echo']
    ),
    (legacy: '-sl', option: 'idle-scan', allowed: null),
    (legacy: '-b', option: 'ftp-bounce-attack', allowed: null),
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
  ];

  // Here are additional flags
  final List<({String legacy, String flag})> _otherFlags = [
    (legacy: '-f', flag: 'fragment-ip-packets'),
    (legacy: '--packet-trace', flag: 'packet-trace'),
    (legacy: '-r', flag: 'randomize-scanned-ports'),
    (legacy: '--traceroute', flag: 'traceroute'),
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

  NFECommand({required List<String> arguments}) {
    _initializeVars();
    if (arguments.length> 1) {
      _arguments = arguments.sublist(1, arguments.length-1);
    } else {
      _arguments = [];
    }
    _results = _parser.parse(toModern(_arguments));
  }

  NFECommand.fromModern({required List<String> arguments}) {
    _initializeVars();
    _results = _parser.parse(_arguments);
    _arguments = toLegacy();
  }

  List<String>
  get arguments => _arguments;

  void _initializeVars() {
    _parser = ArgParser();
    _scanOptionConfig();
    _sourceOptionConfig();
    _pingOptionConfig();
    _targetOptionConfig();
    _otherOptionConfig();
  }

  void _pingOptionConfig() {
    for (var f in _pingFlags) {
      _parser.addFlag(f.flag);
    }

    for (var o in _pingOptions) {
      _parser.addOption(o.option);
    }
  }

  void _sourceOptionConfig() {
    for (var o in _sourceOptions) {
      _parser.addOption(o.option);
    }
  }

  void _scanOptionConfig() {
    // Configure 'scan' options
    for (var f in _scanFlags) {
      _parser.addFlag(f.flag);
    }

    for (var o in _scanOptions) {
      if (o.allowed != null) {
        _parser.addOption(o.option, allowed: o.allowed);
      } else {
        _parser.addOption(o.option);
      }
    }
  }

  void _targetOptionConfig() {
    for (var o in _targetOptions) {
      _parser.addOption(o.option);
    }
  }

  void _otherOptionConfig() {
    for (var f in _otherFlags) {
      _parser.addFlag(f.flag);
    }

    for (var o in _otherOptions) {
      _parser.addOption(o.option);
    }
  }

  get results => _results;

  String? _toModernFlag(String legacyFlag) {
    String? modernFlag;
    for (var f in _scanFlags + _pingFlags + _otherFlags) {
      if (f.legacy == legacyFlag) {
        modernFlag = f.flag;
        break;
      }
    }
    return modernFlag;
  }

  String? _toModernOption(String legacyOption) {
    String? modernOption;
    for (var f in _targetOptions +  _sourceOptions + _pingOptions + _otherOptions) {
      if (f.legacy == legacyOption) {
        modernOption = f.option;
        break;
      }
    }
    for (var f in _scanOptions) {
      if (f.legacy == legacyOption) {
        modernOption = f.option;
        break;
      }
    }
    return modernOption;
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
            modernOptions.add('verbosity-level');
            modernOptions.add('$level');
            optIndex += level + 1;
          } else {
            String? modernOption = _toModernOption(currentOpt);
            if (modernOption != null) {
              modernOptions.add(modernOption);
              if (optIndex + 1 <= legacyOptions.length) {
                modernOptions.add(legacyOptions[optIndex + 1]);
              }
            }
            optIndex += 2;
          }
        }
      }
    }

    return modernOptions;
  }

  List<String> toLegacy() {
    ArgResults results = _results;
    String? scanOption;
    List<String> legacyOptions = [];


    /// Check options
    // TARGET OPTIONS
    for (var o
    in _targetOptions + _pingOptions + _sourceOptions + _otherOptions) {
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
        trace.debug('(generic-one) ${o.option} = ${o.legacy} ${results[o.option]}');
        legacyOptions.add(o.legacy);
        legacyOptions.add(results[o.option]);
      }
    }

    // SCAN OPTIONS
    for (var o in _scanOptions) {
      // special handling for tcp-scan options
      if (o.option == 'tcp-scan' && results[o.option] != null) {
        switch (results[o.option]) {
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
      }  else if (results[o.option] != null) {
        trace.debug(
            '(generic-option) ${o.option} = ${o.legacy} ${results[o.option]}');
        legacyOptions.add(o.legacy);
        legacyOptions.add(results[o.option]);
      }
    }

    for (var f in _scanFlags + _pingFlags + _otherFlags) {
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

