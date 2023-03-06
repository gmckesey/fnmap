import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'dart:convert';
import 'package:glog/glog.dart';

class NMapCommand with ChangeNotifier {
  late String _program;
  List<String>? _arguments;
  ProcessResult? _result;
  String? _stderr;
  String? _consoleOutput;
  GLog log = GLog('NMapCommand', properties: gLogPropALL);
  bool _inProgress = false;
  Process? _process = null;

  NMapCommand({String program = 'nmap', List<String>? arguments}) {
    _program = program;
    _arguments = arguments;
    // run();
  }

  void processLine(String line) {
    _consoleOutput = '${_consoleOutput!}$line\n';
    _inProgress = true;
    notifyListeners();
    log.debug('processLine: line is $line');
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
      _process = await Process.start(_program, []);
    } else {
      log.debug('start: starting $_program with arguments $_arguments');
      _process = await Process.start(_program, _arguments!);
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
    }
    else {
      return null;
    }
  }

  set arguments(List<String>? argument) {
    _arguments = argument;
  }
}
