import 'dart:io';
import 'dart:convert';
import 'package:args/args.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fnmap/controllers/edit_profile_controllers.dart';
import 'package:fnmap/utilities/logger.dart';
import 'package:fnmap/constants.dart';
import 'package:fnmap/utilities/ip_address_validator.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:provider/provider.dart';
import 'package:fnmap/models/nmap_xml.dart';
import 'package:fnmap/utilities/nmap_fe.dart';

enum CommandState {
  notStarted,
  inProgress,
  complete,
}

enum PackagingType {
  snap,
  flatpak,
  native,
}

PackagingType detectPackagingType() {
  if (Platform.environment.containsKey('SNAP')) {
    return PackagingType.snap;
  }
  if (Platform.environment.containsKey('FLATPAK_ID') ||
      File('/.flatpak-info').existsSync()) {
    return PackagingType.flatpak;
  }
  return PackagingType.native;
}

class CmdBool with ChangeNotifier {
  late bool _isSet;

  CmdBool(bool value) {
    _isSet = value;
  }

  bool get isSet => _isSet;

  set isSet(bool value) {
    _isSet = value;
    notifyListeners();
  }

  void call(bool value) {
    isSet = value;
  }
}

class CmdInt with ChangeNotifier {
  late int _intValue;
  late TextEditingController? _controller;

  CmdInt(int value, {TextEditingController? controller}) {
    _intValue = value;
    if (controller != null) {
      _controller = TextEditingController();
      _controller!.text = _intValue.toString();
    }
  }

  CmdInt.fromString(String value, {TextEditingController? controller}) {
    _intValue = int.tryParse(value)!;
    if (controller != null) {
      _controller = TextEditingController();
      _controller!.text = _intValue.toString();
    }
  }

  bool get hasController => _controller != null;

  int get value => _intValue;

  set value(int intValue) {
    _intValue = intValue;
    notifyListeners();
  }

  set controller(TextEditingController? controller) {
    _controller = controller;
  }

  @override
  String toString() => _intValue.toString();

  void call(int intValue) {
    value = intValue;
  }
}

class CmdEnabledInt extends CmdInt {
  CmdEnabledInt(super.value);
}

class CmdString with ChangeNotifier {
  late String? _text;
  late TextEditingController? _controller;

  CmdString(String? value, {TextEditingController? controller}) {
    _text = value;
    if (controller == null) {
      _controller = TextEditingController();
      if (_text != null) {
        _controller!.text = _text!;
      }
    } else {
      _controller!.text = _text!;
    }
  }

  bool get hasController => _controller != null;

  String? get text => _text;

  set text(String? value) {
    _text = value;
    notifyListeners();
  }

  set controller(TextEditingController? controller) {
    _controller = controller;
  }

  @override
  String toString() => _text ?? '';

  void call(String? value) {
    text = value;
  }
}

// A kind of controller to store the scroll position
// when we move between tabs - unfortunate that this is necessary
// essentially I want a reference to a double rather than a double
class NMapScrollOffset {
  late double offset;

  NMapScrollOffset(this.offset);

  @override
  String toString() => offset.toString();
}

class ProfileCommand with ChangeNotifier {
  late EditProfileControllers controllers;

  ProfileCommand({required this.controllers});

  void update() {
    notifyListeners();
  }
}

class NMapCommand with ChangeNotifier {
  late String _program;
  late String _target;
  String? tmpFile;
  late NFECommand _command;
  ProcessResult? _processResult;
  String? _stderr;
  String? _consoleOutput;
  NLog trace = NLog('NMapCommand', flag: nLogTRACE, package: kPackageName);
  NLog log = NLog('NMapCommand', package: kPackageName);
  CommandState state = CommandState.notStarted;
  Process? _process;

  NMapCommand(
      {String program = 'nmap', List<String>? arguments, String? target}) {
    _program = program;
    arguments ??= [];
    _command = NFECommand(arguments: arguments);
    _target = target ?? '127.0.0.1';
    // run();
  }

  NMapCommand.fromCommandLine(String commandLine, {String? target}) {
    List<String> arguments = commandLine.split(RegExp(r'\s'));
    if (arguments.isNotEmpty) {
      _program = arguments.first;
      if (arguments.length > 1) {
/*        List<String> cmdLine = List<String>.filled(arguments.length - 1, '');
        cmdLine.setRange(1, cmdLine.length - 1, cmdLine, 1);*/
        _command = NFECommand(arguments: arguments);
      } else {
        _command = NFECommand(arguments: []);
      }
    }
    if (target == null) {
      List<String> value =
          _command.results != null ? _command.results!.rest : [];
      if (value.isNotEmpty) {
        target = value.join(" ");
      }
    }
    if (target != null && !isValidIPAddressList(target)) {
      throw NotAValidIPAddressException('invalid target address '
          '$target');
    }
    _target = target ??
        ''; //If there is no target in command or passed thru set it to a blank string
  }

  bool get inProgress => state == CommandState.inProgress;
  set consoleOutput(String value) {
    _consoleOutput = value;
    notifyListeners();
  }

  NFECommand get command => _command;

//   String get target => _target;

  void processLine(String line) {
    _consoleOutput = '${_consoleOutput!}$line\n';
    state = CommandState.inProgress;
    notifyListeners();
  }

  void processError(String errorLine) {
    _consoleOutput = '${_consoleOutput!}$errorLine\n';
    state = CommandState.inProgress;
    notifyListeners();
    log.debug('processError: error is $errorLine');
  }

  Future<String> genTempFile({String? prefix, String? postfix}) async {
    String uniqueId = const Uuid().v4();
    String fName = prefix ?? '';
    String uniqueFn = '$fName-$uniqueId${postfix ?? ''}';
    Directory dir = await getTemporaryDirectory();
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    String tempFn = path.join(dir.path, uniqueFn);
    return tempFn;
  }

  void start(BuildContext context,
      {required Function(String msg) onError,
      bool runAsRoot = false,
      bool? privileged,
      String? rootPassword}) async {
    final bool isPrivileged = privileged ?? runAsRoot;
    _consoleOutput = '';
    state = CommandState.inProgress;
    // notifyListeners();

    List<String> cmdLine = List.from(_command.arguments);
    final pattern = RegExp(r"\s+");
    List<String> targetList = _target.split(pattern);
    for (String element in targetList) {
      if (element.isEmpty) {
        continue;
      }
      cmdLine.add(element);
    }
    trace.debug(
        'start: starting $_program with arguments $cmdLine (privileged: $isPrivileged)');
    // Create a unique file path in the tmp directory (do not pre-create it, so nmap creates it)
    tmpFile = await genTempFile(prefix: 'nmap-gui', postfix: '.xml');
    File existingFile = File(tmpFile!);
    if (!await existingFile.parent.exists()) {
      await existingFile.parent.create(recursive: true);
    }
    if (await existingFile.exists()) {
      await existingFile.delete();
    }
    cmdLine.add('-oX');
    cmdLine.add(tmpFile!);
    String executable = _program;
    if (Platform.isLinux && executable == 'nmap') {
      // Prioritize host native nmap installations to avoid snap/packaging library mismatches (e.g. libpcre)
      if (File('/usr/bin/nmap').existsSync()) {
        executable = '/usr/bin/nmap';
      } else if (File('/usr/local/bin/nmap').existsSync()) {
        executable = '/usr/local/bin/nmap';
      } else if (File('/bin/nmap').existsSync()) {
        executable = '/bin/nmap';
      }
    } else if (Platform.isMacOS && executable == 'nmap') {
      // Check Homebrew (Apple Silicon / Intel) and standard Mac locations
      if (File('/opt/homebrew/bin/nmap').existsSync()) {
        executable = '/opt/homebrew/bin/nmap';
      } else if (File('/usr/local/bin/nmap').existsSync()) {
        executable = '/usr/local/bin/nmap';
      } else if (File('/usr/bin/nmap').existsSync()) {
        executable = '/usr/bin/nmap';
      }
    }

    try {
      if (isPrivileged && (Platform.isLinux || Platform.isMacOS)) {
        final packaging = detectPackagingType();

        if (packaging == PackagingType.flatpak) {
          // Inside Flatpak, the sandbox cannot create raw sockets (PR_SET_NO_NEW_PRIVS).
          // We spawn the host's nmap via flatpak-spawn using PolicyKit (pkexec).
          try {
            ProcessResult check =
                await Process.run('flatpak-spawn', ['--host', 'which', 'nmap']);
            if (check.exitCode != 0) {
              String msg =
                  "Privileged scans in Flatpak require 'nmap' installed on the host OS.\n"
                  "Please install nmap on your host system (e.g. 'sudo apt install nmap').";
              log.error(msg);
              onError(msg);
              processLine(msg);
              state = CommandState.complete;
              _process = null;
              notifyListeners();
              return;
            }
          } catch (_) {}

          _process = await Process.start(
            'flatpak-spawn',
            ['--host', 'pkexec', 'nmap', ...cmdLine],
          );
        } else {
          // Native Linux / macOS / Classic Snap
          bool hasPkexec = false;
          if (Platform.isLinux) {
            try {
              ProcessResult check = await Process.run('which', ['pkexec']);
              hasPkexec = check.exitCode == 0;
            } catch (_) {}
          }

          if (hasPkexec) {
            // pkexec presents the desktop's native authentication modal
            _process = await Process.start('pkexec', [executable, ...cmdLine]);
          } else {
            // Fallback to sudo with supplied password or cached sudo credentials
            List<String> sudoArgs;
            if (rootPassword != null && rootPassword.isNotEmpty) {
              sudoArgs = ['-S', '-p', '', executable, ...cmdLine];
            } else {
              sudoArgs = [executable, ...cmdLine];
            }
            _process = await Process.start('sudo', sudoArgs);
            if (rootPassword != null && rootPassword.isNotEmpty) {
              _process!.stdin.writeln(rootPassword);
              await _process!.stdin.flush();
            }
          }
        }
      } else {
        _process = await Process.start(executable, cmdLine);
      }
    } catch (e) {
      String msg =
          'Error trying to start $_program, make sure $_program is installed.\n'
      'Got to https://nmap.org/download.html for downloads and installation instructions '
      'for your platform';
      log.error(msg);
      onError(msg);
      processLine(msg);
      state = CommandState.complete;
      _process = null;
      notifyListeners();
      return;
    }

    _process!.stdout
        .transform(utf8.decoder)
        .transform(const LineSplitter())
        .listen((line) => processLine(line), cancelOnError: true, onDone: () {
      log.debug('onDone<stdout> called.');
      state = CommandState.complete;
      _process = null;
      notifyListeners();

      if (!context.mounted) return;
      try {
        File xmlFile = File(tmpFile!);
        if (xmlFile.existsSync() && xmlFile.lengthSync() > 0) {
          NMapXML nMapXML = Provider.of<NMapXML>(context, listen: false);
          nMapXML.clear(notify: false);
          nMapXML.open(tmpFile!);
        } else {
          log.warning('start: output file ${tmpFile!} does not exist or is empty');
        }
      } catch (e) {
        log.warning('start: failed opening ${tmpFile!}');
      }
    });
    _process!.stderr
        .transform(utf8.decoder)
        .transform(const LineSplitter())
        .listen((line) => processLine(line), cancelOnError: true, onDone: () {
      log.debug('onDone<stderr> called.');
    });
  }

  void stop() {
    if (_process != null) {
      _process!.kill();
    }
  }

  void clear() {
    _consoleOutput = '';
    _stderr = '';
    notifyListeners();
  }

  ProcessResult? get processResult => _processResult;
  String? get stdError => _stderr;
  String? get stdOut => _consoleOutput;
  List<String>? get arguments => _command.arguments;
  String get target => _target;
  ArgResults? get results => _command.results;
  List<String> get tcpScanOptions => _command.tcpScanOptions;
  List<String> get otherScanOptions => _command.otherScanOptions;
  List<({String legacy, String flag})> get timingFlags => _command.timingFlags;
  String get program => _program;

  int? get pid {
    if (inProgress) {
      return _process!.pid;
    } else {
      return null;
    }
  }
/*
  set arguments(List<String>? argument) {
    _arguments = argument;
    notifyListeners();
  }*/

  void setArguments(List<String>? argument, {bool notify = true}) {
    argument ??= [];
    _command = NFECommand(arguments: argument);
    if (notify) {
      notifyListeners();
    }
  }

  set program(String value) {
    setProgram(value);
  }

  void setProgram(String value, {bool notify = true}) {
    _program = value;
    if (notify) {
      notifyListeners();
    }
  }

  set target(String value) {
    setTarget(value);
  }

  void setTarget(String value, {bool notify = true}) {
    if (!isValidIPAddressList(value)) {
      // throw NotAValidIPAddressException('invalid target address '
      //    '$value');
      return;
    }
    _target = value;
    if (notify) {
      notifyListeners();
    }
  }
}
