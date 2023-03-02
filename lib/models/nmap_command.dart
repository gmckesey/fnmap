import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'dart:convert';
import 'package:glog/glog.dart';

class NMapCommand with ChangeNotifier {
  late String _program;
  List<String>? _arguments;
  ProcessResult? _result;
  String? _stderr;
  String? _stdout;
  GLog log = GLog('NMapCommand', properties: gLogPropALL);
  bool _inProgress = false;

  NMapCommand({String program = 'nmap', List<String>? arguments}) {
    _program = program;
    _arguments = arguments;
    // run();
  }

  void processLine(String line) {
    _stdout = '${_stdout!}$line\n';
    _inProgress = true;
    notifyListeners();
    log.debug('processLine: line is $line');
  }

  void start() async {
    Process process;
    _stdout = '';
    _inProgress = true;
    // notifyListeners();
    if (_arguments == null) {
      process = await Process.start(_program, []);
    } else {
      log.debug('start: starting $_program with arguments $_arguments');
      process = await Process.start(_program, _arguments!);
    }
    process.stdout
        .transform(utf8.decoder)
        .transform(const LineSplitter())
        .listen((line) => processLine(line), cancelOnError: true, onDone: () {
      _inProgress = false;
      notifyListeners();
    });
  }

  void run() {
    if (_arguments == null) {
      Process.run(_program, []).then((result) {
        _result = result;
        _stderr = _result!.stderr;
        _stdout = _result!.stdout;
        notifyListeners();
        log.debug('run: stdout is $stdOut');
        log.debug('run: stderr is $stdError');
      });
    } else {
      Process.run(_program, _arguments!).then((result) {
        _result = result;
        _stderr = _result!.stderr;
        _stdout = _result!.stdout;
        notifyListeners();
        log.debug('run: exitCode is ${result.exitCode}');
        log.debug('run: stdout is $stdOut');
        log.debug('run: stderr is $stdError');
      });
    }
  }

  void clear() {
    _stdout = '';
    notifyListeners();
  }

  ProcessResult? get result => _result;
  String? get stdError => _stderr;
  String? get stdOut => _stdout;
  bool get inProgress => _inProgress;

  set arguments(List<String> argument) {
    _arguments = argument;
  }
}
