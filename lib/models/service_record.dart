import 'dart:developer';

import 'host_record.dart';

class NMapServiceRecord {
  final NMapPort port;
  final List<NMapHostRecord> _hosts = [];

  NMapServiceRecord({required this.port});

  List<NMapHostRecord> get hosts => _hosts;

  static List <NMapServiceRecord> generateServiceRecords(List<NMapHostRecord> hostRecords) {
    Map<String, NMapServiceRecord> portMap = {};

    for (NMapHostRecord host in hostRecords) {
      for (NMapPort port in host.ports) {
        if (!portMap.containsKey('${port.protocol}/${port.number}')) {
          portMap.addAll({'${port.protocol}/${port.number}' : NMapServiceRecord(port: port)});
        }
        portMap['${port.protocol}/${port.number}']!._hosts.add(host);
      }
    }
    return portMap.values.toList();
  }
}