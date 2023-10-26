import 'package:flutter/material.dart';
import 'package:args/args.dart';
import 'package:fnmap/models/nmap_command.dart';
import 'package:fnmap/utilities/logger.dart';
import 'package:fnmap/utilities/nmap_fe.dart';
import 'package:fnmap/utilities/ip_address_validator.dart';
import 'package:fnmap/widgets/dropdown_string.dart';
import 'package:fnmap/controllers/textfield_controller.dart';

List<String> textFieldAddArgument(
    KriolTextFieldController field, String? option) {
  List<String> arguments = [];
  if (field.text != null) {
    if (option != null) {
      arguments.add(option);
    }
    arguments.add(field.text!);
  }
  return arguments;
}

class EditScanControllers with ChangeNotifier {
  late NFECommand nfeCommand;
  late KriolDropdownController tcpScanController;
  late KriolDropdownController otherScanController;
  late KriolDropdownController timingTemplateController;

  // Scan Controllers, flags and option values
  KriolTextFieldController ftpBounce = KriolTextFieldController();
  KriolTextFieldController idleScan = KriolTextFieldController();
  KriolTextFieldController target = KriolTextFieldController();
  CmdBool? enableAdvAgr;
  CmdBool? osDetection;
  CmdBool? versionDetection;
  CmdBool? disableDNSDetection;
  CmdBool? ipv6Support;

  CmdString? tcpScanOption;
  CmdString? otherScanOption;
  CmdString? timingScanOption;

  NLog log = NLog('EditScanControllers');

  List<String> _timingFlags() {
    List<String> options = [];
    for (({String legacy, String flag}) opt in nfeCommand.timingFlags) {
      options.add(opt.flag);
    }
    options.add('Not Set');
    return options;
  }

  String? _findTimingFlag() {
    ArgResults? results = nfeCommand.results;
    if (results == null) {
      return null;
    }
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

  EditScanControllers({required this.nfeCommand}) {
    ArgResults? results = nfeCommand.results;
    String? timingTemplateFlag = _findTimingFlag();

    if (results != null) {
      enableAdvAgr = CmdBool(results['scan-aggressive']);
      enableAdvAgr!.addListener(notifyListeners);

      tcpScanOption = CmdString(results['tcp-scan']);
      tcpScanOption!.addListener(notifyListeners);

      otherScanOption = CmdString(results['other-scan']);
      otherScanOption!.addListener(notifyListeners);

      bool found = false;
      for (var f in nfeCommand.timingFlags) {
        if (results[f.flag]) {
          timingScanOption = CmdString(f.legacy);
          found = true;
          break;
        }
      }
      if (!found) {
        timingScanOption = CmdString('Not Set');
      }
      timingScanOption!.addListener(notifyListeners);

      osDetection = CmdBool(results['os-detection']);
      osDetection!.addListener(notifyListeners);

      versionDetection = CmdBool(results['version-detection']);
      versionDetection!.addListener(notifyListeners);

      disableDNSDetection = CmdBool(results['disable-rdns']);
      disableDNSDetection!.addListener(notifyListeners);

      ipv6Support = CmdBool(results['ipv6']);
      ipv6Support!.addListener(notifyListeners);

      idleScan.text = results['idle-scan'];
      idleScan.addListener(notifyListeners);

      ftpBounce.text = results['ftp-bounce-attack'];
      ftpBounce.addListener(notifyListeners);

      // target.text = nfeCommand.program;
      found = false;
      target.text = nfeCommand.target;
      /*    if (results.rest.isNotEmpty) {
        // Find a valid IP ignore anything else
        for (String str in results.rest) {
          if (isValidIPAddress(str)) {
            found = true;
            target.text = str;
          }
        }
      }
      if (!found) {
        target.text = null;
      }
*/
      target.addListener(notifyListeners);

      tcpScanController = KriolDropdownController(
          initialValue: tcpScanOption!.text ?? 'Not Set',
          choices: nfeCommand.tcpScanOptions.followedBy(['Not Set']).toList());
      tcpScanController.addListener(notifyListeners);

      otherScanController = KriolDropdownController(
          initialValue: otherScanOption!.text ?? 'Not Set',
          choices:
              nfeCommand.otherScanOptions.followedBy(['Not Set']).toList());
      otherScanController.addListener(notifyListeners);

      timingTemplateController = KriolDropdownController(
          initialValue: timingTemplateFlag ?? 'Not Set',
          choices: _timingFlags());
      timingTemplateController.addListener(notifyListeners);
    }
  }
  List<String> get arguments {
    List<String> args = [];

    if (enableAdvAgr!.isSet) {
      args.add('--scan-aggressive');
    }
    if (osDetection!.isSet) {
      args.add('--os-detection');
    }
    if (versionDetection!.isSet) {
      args.add('--version-detection');
    }
    if (disableDNSDetection!.isSet) {
      args.add('--disable-rdns');
    }
    if (ipv6Support!.isSet) {
      args.add('--ipv6');
    }

    args.addAll(textFieldAddArgument(ftpBounce, '--ftp-bounce-attack'));
    args.addAll(textFieldAddArgument(idleScan, '--idle-scan'));

    if (timingTemplateController.currentValue! != 'Not Set') {
      args.add('--${timingTemplateController.currentValue}');
    }

    if (tcpScanController.currentValue! != 'Not Set') {
      args.add('--tcp-scan');
      args.add(tcpScanController.currentValue!);
    }

    if (otherScanController.currentValue! != 'Not Set') {
      args.add('--other-scan');
      args.add(otherScanController.currentValue!);
    }

    args.addAll(textFieldAddArgument(target, null));

    return args;
  }
}

class PingScanControllers with ChangeNotifier {
  ArgResults? results;
  // Ping Controllers, flags and option values
  KriolTextFieldController ackPing = KriolTextFieldController();
  KriolTextFieldController synPing = KriolTextFieldController();
  KriolTextFieldController udpPing = KriolTextFieldController();
  KriolTextFieldController ipProto = KriolTextFieldController();
  KriolTextFieldController sctpInitPing = KriolTextFieldController();

  CmdBool? pingBeforeScan;
  CmdBool? vICMPPing;
  CmdBool? vICMPTimeStamp;
  CmdBool? vICMPNetmask;
  CmdBool? arpPing;
  CmdBool? noArpPing;
  CmdBool? noHostDiscovery;

  PingScanControllers({required this.results}) {
    if (results != null) {
      pingBeforeScan = CmdBool(results!['no-ping-before-scan']);
      pingBeforeScan!.addListener(notifyListeners);

      vICMPPing = CmdBool(results!['icmp-ping']);
      vICMPPing!.addListener(notifyListeners);

      vICMPTimeStamp = CmdBool(results!['icmp-timestamp-request']);
      vICMPTimeStamp!.addListener(notifyListeners);

      vICMPNetmask = CmdBool(results!['icmp-netmask-request']);
      vICMPNetmask!.addListener(notifyListeners);

      arpPing = CmdBool(results!['arp-ping']);
      arpPing!.addListener(notifyListeners);

      noArpPing = CmdBool(results!['disable-arp-ping']);
      noArpPing!.addListener(notifyListeners);

      noHostDiscovery = CmdBool(results!['skip-host-discovery']);
      noHostDiscovery!.addListener(notifyListeners);

      ackPing.text = results!['ping-tcp-ack'];
      ackPing.addListener(notifyListeners);

      synPing.text = results!['ping-tcp-syn'];
      synPing.addListener(notifyListeners);

      udpPing.text = results!['probe-udp'];
      udpPing.addListener(notifyListeners);

      ipProto.text = results!['probe-ip-proto'];
      ipProto.addListener(notifyListeners);

      sctpInitPing.text = results!['ping-sctp-init'];
      sctpInitPing.addListener(notifyListeners);
    }
  }

  List<String> get arguments {
    List<String> args = [];

    if (pingBeforeScan!.isSet) {
      args.add('--no-ping-before-scan');
    }
    if (vICMPPing!.isSet) {
      args.add('--icmp-ping');
    }
    if (vICMPTimeStamp!.isSet) {
      args.add('--icmp-timestamp-request');
    }
    if (vICMPNetmask!.isSet) {
      args.add('--icmp-netmask-request');
    }
    if (arpPing!.isSet) {
      args.add('--arp-ping');
    }
    if (noArpPing!.isSet) {
      args.add('--disable-arp-ping');
    }
    if (noHostDiscovery!.isSet) {
      args.add('--skip-host-discovery');
    }

    args.addAll(textFieldAddArgument(ackPing, '--ping-tcp-ack'));
    args.addAll(textFieldAddArgument(synPing, '--ping-tcp-syn'));
    args.addAll(textFieldAddArgument(udpPing, '--probe-udp'));
    args.addAll(textFieldAddArgument(ipProto, '--probe-ip-proto'));
    args.addAll(textFieldAddArgument(sctpInitPing, '--ping-sctp-init'));

    return args;
  }
}

class SourceScanControllers with ChangeNotifier {
  ArgResults? results;
  // Source Controllers
  KriolTextFieldController decoy = KriolTextFieldController();
  KriolTextFieldController sourceIP = KriolTextFieldController();
  KriolTextFieldController sourcePort = KriolTextFieldController();
  KriolTextFieldController networkIF = KriolTextFieldController();

  SourceScanControllers({required this.results}) {
    if (results != null) {
      decoy.text = results!['decoys'];
      decoy.addListener(notifyListeners);

      sourceIP.text = results!['source'];
      sourceIP.addListener(notifyListeners);

      sourcePort.text = results!['source-port'];
      sourcePort.addListener(notifyListeners);

      networkIF.text = results!['network-interface'];
      networkIF.addListener(notifyListeners);
    }
  }

  List<String> get arguments {
    List<String> args = [];
    args.addAll(textFieldAddArgument(decoy, '--decoys'));
    args.addAll(textFieldAddArgument(sourceIP, '--source'));
    args.addAll(textFieldAddArgument(sourcePort, '--source-port'));
    args.addAll(textFieldAddArgument(networkIF, '--network-interface'));

    return args;
  }
}

class TargetScanControllers with ChangeNotifier {
  ArgResults? results;
  // Target Controllers
  KriolTextFieldController exclude = KriolTextFieldController();
  KriolTextFieldController excludeFile = KriolTextFieldController();
  KriolTextFieldController targetFile = KriolTextFieldController();
  KriolTextFieldController randomHost = KriolTextFieldController();
  KriolTextFieldController ports = KriolTextFieldController();

  CmdBool? fastScan;
  TargetScanControllers({required this.results}) {
    // Flag Field
    if (results != null) {
      fastScan = CmdBool(results!['fast-scan']);
      fastScan!.addListener(notifyListeners);

      // Options Fields
      exclude.text = results!['exclude'];
      exclude.addListener(notifyListeners);

      excludeFile.text = results!['exclude-file'];
      excludeFile.addListener(notifyListeners);

      targetFile.text = results!['target-list-file'];
      targetFile.addListener(notifyListeners);

      randomHost.text = results!['scan-random-hosts'];
      randomHost.addListener(notifyListeners);

      ports.text = results!['ports'];
      ports.addListener(notifyListeners);
    }
  }

  List<String> get arguments {
    List<String> args = [];
    args.addAll(textFieldAddArgument(exclude, '--exclude'));
    args.addAll(textFieldAddArgument(excludeFile, '--exclude-file'));
    args.addAll(textFieldAddArgument(targetFile, '--target-list-file'));
    args.addAll(textFieldAddArgument(randomHost, '--scan-random-hosts'));
    args.addAll(textFieldAddArgument(ports, '--ports'));

    if (fastScan!.isSet) {
      args.add('--fast-scan');
    }
    return args;
  }
}

class OtherScanControllers with ChangeNotifier {
  KriolTextFieldController extraOptions = KriolTextFieldController();
  KriolTextFieldController ipV4ttl = KriolTextFieldController();
  KriolTextFieldController maxRetries = KriolTextFieldController();

  CmdBool? fragmentIP;
  CmdBool? packetTrace;
  CmdBool? disableRandomPorts;
  CmdBool? traceRoute;

  CmdBool? enableVerbosityLevel;
  CmdInt? verbosityLevel;
  CmdBool? enableDebugLevel;
  CmdInt? debugLevel;

  OtherScanControllers({required ArgResults? results}) {
    // otherScanControllers.extraOptions
    if (results != null) {
      ipV4ttl.text = results['ttl'];
      extraOptions.text = results['extra-options'];

      if (results['verbosity-level'] != null) {
        verbosityLevel = CmdInt.fromString(results['verbosity-level']);
        enableVerbosityLevel = CmdBool(true);
      } else {
        enableVerbosityLevel = CmdBool(false);
        verbosityLevel = CmdInt(0);
      }
      verbosityLevel!.addListener(notifyListeners);

      if (results['debug-level'] != null) {
        debugLevel = CmdInt.fromString(results['debug-level']);
        enableDebugLevel = CmdBool(true);
      } else {
        enableDebugLevel = CmdBool(false);
        debugLevel = CmdInt(0);
      }
      debugLevel!.addListener(notifyListeners);

      maxRetries.text = results['max-retries'];
      maxRetries.addListener(notifyListeners);

      fragmentIP = CmdBool(results['fragment-ip-packets']);
      fragmentIP!.addListener(notifyListeners);

      disableRandomPorts = CmdBool(results['randomize-scanned-ports']);
      disableRandomPorts!.addListener(notifyListeners);

      traceRoute = CmdBool(results['traceroute']);
      traceRoute!.addListener(notifyListeners);

      packetTrace = CmdBool(results['packet-trace']);
      packetTrace!.addListener(notifyListeners);
    }
  }
  List<String> get arguments {
    List<String> args = [];
    args.addAll(textFieldAddArgument(ipV4ttl, '--ttl'));
    args.addAll(textFieldAddArgument(maxRetries, '--max-retries'));

    if (fragmentIP!.isSet) {
      args.add('--fragment-ip-packets');
    }
    if (packetTrace!.isSet) {
      args.add('--packet-trace');
    }
    if (disableRandomPorts!.isSet) {
      args.add('--randomize-scanned-ports');
    }
    if (traceRoute!.isSet) {
      args.add('--traceroute');
    }

    if (enableVerbosityLevel!.isSet) {
      args.add('--verbosity-level');
      args.add('$verbosityLevel');
    }

    if (enableDebugLevel!.isSet) {
      args.add('--debug-level');
      args.add('$debugLevel');
    }

    return args;
  }
}

class TimingScanControllers with ChangeNotifier {
  KriolTextFieldController hostTimeout = KriolTextFieldController();
  KriolTextFieldController maxRTTTimeout = KriolTextFieldController();
  KriolTextFieldController minRTTTimeout = KriolTextFieldController();
  KriolTextFieldController initialRTTTimeout = KriolTextFieldController();
  KriolTextFieldController maxHostGroup = KriolTextFieldController();
  KriolTextFieldController minHostGroup = KriolTextFieldController();
  KriolTextFieldController maxParallel = KriolTextFieldController();
  KriolTextFieldController minParallel = KriolTextFieldController();
  KriolTextFieldController maxScanDelay = KriolTextFieldController();
  KriolTextFieldController minScanDelay = KriolTextFieldController();

  TimingScanControllers({required ArgResults? results}) {
    if (results != null) {
      hostTimeout.text = results['host-timeout'];
      hostTimeout.addListener(notifyListeners);

      maxRTTTimeout.text = results['max-rtt-timeout'];
      maxRTTTimeout.addListener(notifyListeners);

      minRTTTimeout.text = results['min-rtt-timeout'];
      minRTTTimeout.addListener(notifyListeners);

      initialRTTTimeout.text = results['initial-rtt-timeout'];
      initialRTTTimeout.addListener(notifyListeners);

      maxHostGroup.text = results['max-hostgroup'];
      maxHostGroup.addListener(notifyListeners);

      minHostGroup.text = results['min-hostgroup'];
      minHostGroup.addListener(notifyListeners);

      maxParallel.text = results['max-parallelism'];
      maxParallel.addListener(notifyListeners);

      minParallel.text = results['min-parallelism'];
      minParallel.addListener(notifyListeners);

      maxScanDelay.text = results['max-scan-delay'];
      maxScanDelay.addListener(notifyListeners);

      minScanDelay.text = results['min-scan-delay'];
      minScanDelay.addListener(notifyListeners);
    }
  }

  List<String> get arguments {
    List<String> args = [];

    args.addAll(textFieldAddArgument(hostTimeout, '--host-timeout'));
    args.addAll(textFieldAddArgument(maxRTTTimeout, '--max-rtt-timeout'));
    args.addAll(textFieldAddArgument(minRTTTimeout, '--min-rtt-timeout'));
    args.addAll(
        textFieldAddArgument(initialRTTTimeout, '--initial-rtt-timeout'));
    args.addAll(textFieldAddArgument(maxHostGroup, '--max-hostgroup'));
    args.addAll(textFieldAddArgument(minHostGroup, '--min-hostgroup'));
    args.addAll(textFieldAddArgument(maxParallel, '--max-parallelism'));
    args.addAll(textFieldAddArgument(minParallel, '--min-parallelism'));
    args.addAll(textFieldAddArgument(maxScanDelay, '--max-scan-delay'));
    args.addAll(textFieldAddArgument(minScanDelay, '--min-scan-delay'));

    return args;
  }
}

class EditProfileControllers with ChangeNotifier {
  late NFECommand nfeCommand;
  NLog log = NLog('EditProfileControllers:');

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

  EditProfileControllers({required this.nfeCommand}) {
    initState(nfeCommand);
  }

  void initState(NFECommand nfeCommand) {
    ArgResults? results = nfeCommand.results;

    if (results != null) {
      scanControllers = EditScanControllers(nfeCommand: nfeCommand);
      scanControllers.addListener(myListener);

      pingControllers = PingScanControllers(results: results);
      pingControllers.addListener(myListener);

      sourceScanControllers = SourceScanControllers(results: results);
      sourceScanControllers.addListener(myListener);

      targetScanControllers = TargetScanControllers(results: results);
      targetScanControllers.addListener(myListener);

      otherScanControllers = OtherScanControllers(results: results);
      otherScanControllers.addListener(myListener);

      timingScanControllers = TimingScanControllers(results: results);
      timingScanControllers.addListener(myListener);
    }
  }

  void myListener() {
    // Set command line field when any component changes
    nfeCommand = NFECommand.fromModern(arguments: arguments);
    cmdLineController.text = nfeCommand.cmdLine;
    log.debug(
        'myListener calling notify Listener with command ${cmdLineController.text}');
    notifyListeners();
  }

  void setCommand(NFECommand cmd, {bool notify = false}) {
    initState(cmd);
    if (notify && cmd.results != null) {
      notifyListeners();
    }
  }

  set command(NFECommand cmd) {
    setCommand(cmd, notify: true);
  }

  List<String> get arguments {
    // Get list of arguments from controllers
    List<String> args = ['nmap'];
    args.addAll(pingControllers.arguments);
    args.addAll(sourceScanControllers.arguments);
    args.addAll(targetScanControllers.arguments);
    args.addAll(otherScanControllers.arguments);
    args.addAll(timingScanControllers.arguments);
    // scanControllers arguments must be added last as the last argument
    // may contain the target
    args.addAll(scanControllers.arguments);
    log.debug('arguments returned $args');
    return args;
  }
}
