import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'dart:convert';
import 'package:glog/glog.dart';
import 'package:nmap_gui/utilities/ip_address_validator.dart';

class NMapCommand with ChangeNotifier {
  late String _program;
  late String _target;
  List<String>? _arguments;
  ProcessResult? _result;
  String? _stderr;
  String? _consoleOutput;
  GLog log = GLog('NMapCommand', properties: gLogPropALL);
  bool _inProgress = false;
  Process? _process;

  NMapCommand(
      {String program = 'nmap', List<String>? arguments, String? target}) {
    _program = program;
    _arguments = arguments;
    _target = target ?? '127.0.0.1';
    // run();
  }

  NMapCommand.fromCommandLine(String commandLine, {String? target}) {
    List<String> arguments = commandLine.split(' ');
    if (arguments.isNotEmpty) {
      _program = arguments.first;
      if (arguments.length > 1) {
        _arguments = List<String>.filled(arguments.length - 1, '');
        _arguments!.setRange(1, arguments.length - 1, arguments, 1);
      }
    }
    if (target != null && !isValidIPAddress(target)) {
      throw NotAValidIPAddressException('invalid target address '
          '$target');
    }
    _target = target ?? '127.0.0.1';
  }

//   String get target => _target;

  void processLine(String line) {
    _consoleOutput = '${_consoleOutput!}$line\n';
    _inProgress = true;
    notifyListeners();
  }

  void processError(String errorLine) {
    _consoleOutput = '${_consoleOutput!}$errorLine\n';
    _inProgress = true;
    notifyListeners();
    log.debug('processError: error is $errorLine');
  }

  void start() async {
    _consoleOutput = '';
    _inProgress = true;
    // notifyListeners();
    if (_arguments == null) {
      log.debug('start: starting $_program with target $_target');
      _process = await Process.start(_program, [_target]);
    } else {
      List<String> cmdLine = List.from(_arguments!);
      if (cmdLine.isNotEmpty) {
        cmdLine.removeAt(0);
      }
      cmdLine.add(_target);
      log.debug('start: starting $_program with arguments $cmdLine');
      _process = await Process.start(_program, cmdLine);
    }
    _process!.stdout
        .transform(utf8.decoder)
        .transform(const LineSplitter())
        .listen((line) => processLine(line), cancelOnError: true, onDone: () {
      log.debug('onDone<stdout> called.');
      _inProgress = false;
      _process = null;
      notifyListeners();
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

  void run() {
    if (_arguments == null) {
      Process.run(_program, []).then((result) {
        _result = result;
        _stderr = _result!.stderr;
        _consoleOutput = _result!.stdout;
        notifyListeners();
        log.debug('run: stdout is $stdOut');
        log.debug('run: stderr is $stdError');
      });
    } else {
      Process.run(_program, _arguments!).then((result) {
        _result = result;
        _stderr = _result!.stderr;
        _consoleOutput = _result!.stdout;
        notifyListeners();
        log.debug('run: exitCode is ${result.exitCode}');
        log.debug('run: stdout is $stdOut');
        log.debug('run: stderr is $stdError');
      });
    }
  }

  void clear() {
    _consoleOutput = '';
    notifyListeners();
  }

  ProcessResult? get result => _result;
  String? get stdError => _stderr;
  String? get stdOut => _consoleOutput;
  bool get inProgress => _inProgress;
  List<String>? get arguments => _arguments;

  int? get pid {
    if (_inProgress) {
      return _process!.pid;
    } else {
      return null;
    }
  }

  set arguments(List<String>? argument) {
    _arguments = argument;
      notifyListeners();
  }

  void setArguments(List<String>? argument, {bool notify = true}) {
    _arguments = argument;
    if (notify) {
      notifyListeners();
    }
  }


  set program(String value) {
    _program = value;
  }

  set target(String value) {
    if (!isValidIPAddress(value)) {
      throw NotAValidIPAddressException('invalid target address '
          '$value');
    }
    _target = value;
  }
}
