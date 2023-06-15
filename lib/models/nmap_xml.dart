import 'package:flutter/material.dart';
import 'package:fnmap/constants.dart';
import 'package:xml/xml.dart';
import 'dart:io';
import 'package:fnmap/utilities/logger.dart';
import 'package:fnmap/models/host_record.dart';
import 'package:fnmap/models/service_record.dart';

enum NMapDocumentState {
  uninitialized,
  loading,
  error,
  processed,
}

class NMapXML with ChangeNotifier {
  XmlDocument? _document;
  NMapDocumentState _state = NMapDocumentState.uninitialized;
  final List<NMapHostRecord> _hostRecords = [];
  List<NMapServiceRecord>? _serviceRecords;
  File? _file;
  NLog trace = NLog('NMapXML', flag: nLogTRACE, package: kPackageName);
  NLog log = NLog('NMapXML', package: kPackageName);
  String? _nMapVersion;
  String? _scanDate;
  String? _target;
  late List<String> _nMapArgs;
  String? _scanner;

  NMapXML() {
    _nMapArgs = [];
  }

  NMapXML.fromFile(String fn) {
    _nMapArgs = [];
    open(fn);
  }

  XmlDocument? get document => _document;
  NMapDocumentState get state => _state;
  bool get isProcessed => _state == NMapDocumentState.processed;
  bool get isUninitialized => _state == NMapDocumentState.uninitialized;
  bool get error => _state == NMapDocumentState.error;
  bool get isLoading => _state == NMapDocumentState.loading;
  bool get xmlDocumentExists => _document != null;
  List<NMapHostRecord> get hostRecords => _hostRecords;
  List<NMapServiceRecord> get serviceRecords =>
      _serviceRecords == null ? [] : _serviceRecords!;
  String get nMapVersion => _nMapVersion != null ? _nMapVersion! : "N/A";
  String get target => _target != null ? _target! : "N/A";
  List<String> get nMapArgs => _nMapArgs;
  String get scanDate => _scanDate != null ? _scanDate! : "N/A";
  String get scanner => _scanner != null ? _scanner! : "N/A";
  String get options {
    String value = scanner;
    for (String arg in _nMapArgs) {
      value = '$value $arg';
    }
    return value;
  }

  void open(String fName, {bool notify = true}) {
    _state = NMapDocumentState.loading;
    try {
      _file = File(fName);
      _document = XmlDocument.parse(_file!.readAsStringSync());
    } catch (e) {
      _state = NMapDocumentState.error;
      log.warning('Error $e opening file nMap output $fName');
      rethrow;
    }
    _processXML();
    _state = NMapDocumentState.processed;
    if (notify) {
      notifyListeners();
    }
  }

  void clear({bool notify = true}) {
    _state = NMapDocumentState.uninitialized;
    _document = null;
    _file = null;
    _hostRecords.clear();
    if (notify) {
      notifyListeners();
    }
  }

  void _parseScanArguments(String args) {
    List<String> argsList = args.split(RegExp(r'\s'));
    //TODO: the scanner argument is likely redundant, not sure if it is best
    /// to read it from here or the scanner attribute in the XML
    _nMapArgs.clear();
    _scanner = argsList.first;
    _target = argsList.last;
    // Do not process first and last index because we don't need the command or target
    for (int index = 1; index < argsList.length - 1; index++) {
      switch (argsList[index]) {
        case '-oX':
          // Ignore the -oX argument
          index++;
          break;
        default:
          _nMapArgs.add(argsList[index]);
          break;
      }
    }
  }

  void _parseScan() {
    final nMapRun = _document!.findElements('nmaprun');
    for (XmlElement element in nMapRun) {
      final attributes = element.attributes;
      for (XmlAttribute a in attributes) {
        switch (a.name.toString()) {
          case 'scanner':
            _scanner = a.value;
            break;
          case 'args':
            _parseScanArguments(a.value);
            break;
          case 'version':
            _nMapVersion = a.value;
            break;
          case 'startstr':
            _scanDate = a.value;
            break;
          default:
            break;
        }
      }
    }
  }

  void _processXML() {
    if (_document != null) {
      _parseScan();
      final hosts = _document!.findAllElements('host');
      for (XmlElement element in hosts) {
        NMapHostRecord record = NMapHostRecord.fromXMLElement(element);
        _hostRecords.add(record);
        trace.debug('processXML: processed host record $record');
      }
      _serviceRecords = NMapServiceRecord.generateServiceRecords(_hostRecords);
    }
  }

}
