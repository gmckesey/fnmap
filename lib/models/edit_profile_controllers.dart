import 'package:flutter/material.dart';
import 'package:args/args.dart';
import 'package:fnmap/models/nmap_command.dart';
import 'package:fnmap/widgets/dropdown_string.dart';

class EnabledTextField {
  TextEditingController controller = TextEditingController();
  bool? enabled;

  set text(String? txt) {
    if (txt != null) {
      controller.text = txt;
      enabled = true;
    } else {
      enabled = false;
    }
  }

  String? get text => (enabled == null || !enabled!) ? null : controller.text;
}

class EditScanControllers {
  late NMapCommand nMapCommand;
  late KriolDropdownController tcpScanController;
  late KriolDropdownController otherScanController;
  late KriolDropdownController timingTemplateController;

  // Scan Controllers, flags and option values
  EnabledTextField ftpBounce = EnabledTextField();
  EnabledTextField idleScan = EnabledTextField();

  TextEditingController targetController = TextEditingController();
  bool? enableAdvAgr;
  bool? osDetection;
  bool? versionDetection;
  bool? disableDNSDetection;
  bool? ipv6Support;

  String? tcpScanOption;
  String? otherScanOption;

  List<String> _timingFlags() {
      List<String> options = [];
    for (({String legacy, String flag}) opt in nMapCommand.timingFlags) {
      options.add(opt.flag);
    }
    options.add('Not Set');
    return options;
  }

  String? _findTimingFlag() {
    ArgResults results = nMapCommand.results;

    for (String opt in _timingFlags()) {
      if (opt == "Not Set") {
        break;
      }
      if (results[opt]) {
        return opt;
      }
    }
    return null;
  }

  EditScanControllers({required this.nMapCommand}) {
    ArgResults results = nMapCommand.results;
    String? timingTemplateFlag = _findTimingFlag();

    enableAdvAgr = results['scan-aggressive'];
    tcpScanOption = results['tcp-scan'];
    otherScanOption = results['other-scan'];
    osDetection = results['os-detection'];
    versionDetection = results['version-detection'];
    disableDNSDetection = results['disable-rdns'];
    ipv6Support = results['ipv6'];
    idleScan.text = results['idle-scan'];
    ftpBounce.text = results['ftp-bounce-attack'];
    targetController.text = nMapCommand.target;

    tcpScanController = KriolDropdownController(
        initialValue: tcpScanOption ?? 'Not Set',
        choices: nMapCommand.tcpScanOptions.followedBy(['Not Set']).toList());

    otherScanController = KriolDropdownController(
        initialValue: otherScanOption ?? 'Not Set',
        choices: nMapCommand.otherScanOptions.followedBy(['Not Set']).toList());

    timingTemplateController = KriolDropdownController(
        initialValue: timingTemplateFlag ?? 'Not Set', choices: _timingFlags());
  }
}

class PingScanControllers {
  late ArgResults results;
  // Ping Controllers, flags and option values
  EnabledTextField ackPing = EnabledTextField();
  EnabledTextField synPing = EnabledTextField();
  EnabledTextField udpPing = EnabledTextField();
  EnabledTextField ipProto = EnabledTextField();
  EnabledTextField sctpInitPing = EnabledTextField();

  bool? pingBeforeScan;
  bool? ICMPPing;
  bool? ICMPTimeStamp;
  bool? ICMPNetmask;

  PingScanControllers({required this.results}) {
    pingBeforeScan = results['no-ping-before-scan'];
    ICMPPing = results['icmp-ping'];
    ICMPTimeStamp = results['icmp-timestamp-request'];
    ICMPNetmask = results['icmp-netmask-request'];

    ackPing.text = results['ping-tcp-ack'];
    synPing.text = results['ping-tcp-syn'];
    udpPing.text = results['probe-udp'];
    ipProto.text = results['probe-ip-proto'];
    sctpInitPing.text = results['ping-sctp-init'];
  }
}

class SourceScanControllers {
  late ArgResults results;
  // Source Controllers
  EnabledTextField decoy = EnabledTextField();
  EnabledTextField sourceIP = EnabledTextField();
  EnabledTextField sourcePort = EnabledTextField();
  EnabledTextField networkIF = EnabledTextField();

  SourceScanControllers({required this.results}) {
    decoy.text = results['decoys'];
    sourceIP.text = results['source'];
    sourcePort.text = results['source-port'];
    networkIF.text = results['network-interface'];
  }
}

class TargetScanControllers {
  late ArgResults results;
  // Target Controllers
  EnabledTextField exclude = EnabledTextField();
  EnabledTextField excludeFile = EnabledTextField();
  EnabledTextField targetFile = EnabledTextField();
  EnabledTextField randomHost = EnabledTextField();
  EnabledTextField ports = EnabledTextField();

  bool? fastScan;
  TargetScanControllers({required this.results}) {
    // Flag Field
    fastScan = results['fast-scan'];

    // Options Fields
    exclude.text = results['exclude'];
    excludeFile.text = results['exclude-file'];
    targetFile.text = results['target-list-file'];
    randomHost.text = results['scan-random-hosts'];
    ports.text = results['ports'];
  }
}

class OtherScanControllers {
  EnabledTextField extraOptions = EnabledTextField();
  EnabledTextField ipV4ttl = EnabledTextField();
  EnabledTextField maxRetries = EnabledTextField();

  bool? fragmentIP;
  bool? packetTrace;
  bool? disableRandomPorts;
  bool? traceRoute;

  bool? enableVerbosityLevel;
  int? verbosityLevel;
  bool? enableDebugLevel;
  int? debugLevel;

  OtherScanControllers({required ArgResults results}) {
    // otherScanControllers.extraOptions
    ipV4ttl.text = results['ttl'];
    extraOptions.text = results['extra-options'];

    if (results['verbosity-level'] != null) {
      verbosityLevel =
          int.tryParse(results['verbosity-level']);
      enableVerbosityLevel = true;
    } else {
      enableVerbosityLevel = false;
      verbosityLevel = 0;
    }
    if (results['debug-level'] != null) {
      debugLevel = int.tryParse(results['debug-level']);
      enableDebugLevel = true;
    } else {
      enableDebugLevel = false;
      debugLevel = 0;
    }
    maxRetries.text = results['max-retries'];

    fragmentIP = results['fragment-ip-packets'];
    disableRandomPorts =
    results['randomize-scanned-ports'];
    traceRoute = results['traceroute'];
    packetTrace = results['packet-trace'];
  }
}

class TimingScanControllers {
  EnabledTextField hostTimeout = EnabledTextField();
  EnabledTextField maxRTTTimeout = EnabledTextField();
  EnabledTextField minRTTTimeout = EnabledTextField();
  EnabledTextField initialRTTTimeout = EnabledTextField();
  EnabledTextField maxHostGroup = EnabledTextField();
  EnabledTextField minHostGroup = EnabledTextField();
  EnabledTextField maxParallel = EnabledTextField();
  EnabledTextField minParallel = EnabledTextField();
  EnabledTextField maxScanDelay = EnabledTextField();
  EnabledTextField minScanDelay = EnabledTextField();

  TimingScanControllers({required ArgResults results}) {
    hostTimeout.text = results['host-timeout'];
    maxRTTTimeout.text = results['max-rtt-timeout'];
    minRTTTimeout.text = results['min-rtt-timeout'];
    initialRTTTimeout.text = results['initial-rtt-timeout'];
    maxHostGroup.text = results['max-hostgroup'];
    minHostGroup.text = results['min-hostgroup'];
    maxParallel.text = results['max-parallelism'];
    minParallel.text = results['min-parallelism'];
    maxScanDelay.text = results['max-scan-delay'];
    minScanDelay.text = results['min-scan-delay'];
  }
}

class EditProfileControllers {
  late NMapCommand nMapCommand;

  TextEditingController nameController = TextEditingController();
  TextEditingController cmdLineController = TextEditingController();
  TextEditingController descController = TextEditingController();

  TextEditingController controller = TextEditingController();

  late EditScanControllers scanControllers;
  late PingScanControllers pingControllers;
  late SourceScanControllers sourceScanControllers;
  late TargetScanControllers targetScanControllers;
  late OtherScanControllers otherScanControllers;
  late TimingScanControllers timingScanControllers;

  EditProfileControllers({required this.nMapCommand}) {
    ArgResults results = nMapCommand.results;

    scanControllers = EditScanControllers(nMapCommand: nMapCommand);
    pingControllers = PingScanControllers(results: results);
    sourceScanControllers = SourceScanControllers(results: results);
    targetScanControllers = TargetScanControllers(results: results);
    otherScanControllers = OtherScanControllers(results: results);
    timingScanControllers = TimingScanControllers(results: results);
  }
}
