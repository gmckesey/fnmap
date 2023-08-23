import 'dart:io';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
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

// A kind of controller to store the scroll position
// when we move between tabs - unfortunate that this is necessary
// essentially I want a reference to a double rather than a double
class NMapScrollOffset {
  late double offset;

  NMapScrollOffset(this.offset);

  @override
  String toString() => offset.toString();
}

class NMapCommand with ChangeNotifier {
  late String _program;
  late String _target;
  String? tmpFile;
  late NFECommand _command;
  ProcessResult? _result;
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
    if (target != null && !isValidIPAddress(target)) {
      throw NotAValidIPAddressException('invalid target address '
          '$target');
    }
    _target = target ?? '127.0.0.1';
  }

  bool get inProgress => state == CommandState.inProgress;
  set consoleOutput(String value) {
    _consoleOutput = value;
    notifyListeners();
  }

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
    // String uniqueFn = '$fName-${uniqueId.substring(0, 16)}${postfix ?? ''}';
    String uniqueFn = '$fName-$uniqueId-${postfix ?? ''}';
    Directory dir = await getTemporaryDirectory();
    String tempFn = path.join(dir.path, uniqueFn);
    return tempFn;
  }

  void start(BuildContext context) async {
    _consoleOutput = '';
    state = CommandState.inProgress;
    // notifyListeners();

    List<String> cmdLine = List.from(_command.arguments);
    cmdLine.add(_target);
    trace.debug('start: starting $_program with arguments $cmdLine');
    // Create a unique file in the tmp directory
    tmpFile = await genTempFile(prefix: 'nmap-gui', postfix: '.xml');
    cmdLine.add('-oX');
    cmdLine.add(tmpFile!);
    _process = await Process.start(_program, cmdLine);

    _process!.stdout
        .transform(utf8.decoder)
        .transform(const LineSplitter())
        .listen((line) => processLine(line), cancelOnError: true, onDone: () {
      log.debug('onDone<stdout> called.');
      state = CommandState.complete;
      _process = null;
      notifyListeners();
      // TODO: Open could fail, so wrap in try catch
      try {
        NMapXML nMapXML = Provider.of<NMapXML>(context, listen: false);
        nMapXML.clear(notify: false);
        nMapXML.open(tmpFile!);
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

  ProcessResult? get result => _result;
  String? get stdError => _stderr;
  String? get stdOut => _consoleOutput;
  List<String>? get arguments => _command.arguments;
  String get target => _target;

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
    _program = value;
    notifyListeners();
  }

  set target(String value) {
    if (!isValidIPAddress(value)) {
      throw NotAValidIPAddressException('invalid target address '
          '$value');
    }
    _target = value;
    notifyListeners();
  }
}
