import 'dart:convert';
import 'package:xml/xml.dart';
import 'package:nmap_gui/utilities/logger.dart';
import 'package:xml2json/xml2json.dart';

class InvalidElementException implements Exception {
  String cause;
  InvalidElementException(this.cause);
}

enum NMapDeviceStatus {
  unknown,
  up,
  down,
}

enum NMapAddressType {
  unknown,
  ipv4,
  ipv6,
  mac,
}

class NMapPort {
  String? _name;
  String protocol = 'unknown';
  String state = 'unknown';
  int number = -1;
  NLog log = NLog('NMapPort');

  NMapPort({
    String? name,
    required this.protocol,
    required this.number,
    required this.state,
  }) {
    _name = name;
  }
  String get name => _name != null ? _name! : 'unknown';

  String get longName {
    if (_name == null || _name == 'unknown') {
      return '$protocol/${number.toString()}';
    } else {
      return '$_name : $protocol/${number.toString()}';
    }
  }

  @override
  String toString() {
    return 'service: $name, port: $protocol/$number';
  }

  NMapPort.fromXMLElement(XmlElement element) {
    if (element.name.local != 'port') {
      throw InvalidElementException(
          'Element with nodeType ${element.name.local} '
          'is not supported');
    }

    for (XmlAttribute attribute in element.attributes) {
      String attributeName = attribute.name.toString();
      if (attributeName == 'protocol') {
        protocol = attribute.value;
      } else if (attributeName == 'portid') {
        number = int.parse(attribute.value);
      } else {
        log.warning('fromXMLElement: unexpected attribute $attributeName '
            'for XML "port" element - ignored');
      }
    }
    Iterable<XmlElement> services = element.findElements('service');
    if (services.length == 1) {
      for (XmlAttribute attribute in services.first.attributes) {
        if (attribute.name.toString() == 'name') {
          _name = attribute.value;
        }
      }
    }
    Iterable<XmlElement> states = element.findElements('state');
    if (services.length == 1) {
      for (XmlAttribute attribute in states.first.attributes) {
        if (attribute.name.toString() == 'state') {
          state = attribute.value;
        }
      }
    }
  }
}

class NMapHostRecord {
  final List<String> _hostnames = [];
  final List<NMapPort> _ports = [];
  late String _macAddress;
  late String _vendor;
  late String _ipAddress;
  late NMapDeviceStatus _deviceStatus;
  XmlElement? _element;
  Map<String, dynamic>? _map;

  NLog trace =
      NLog('NMapHostRecord:', flag: nLogTRACE);
  NLog log = NLog('NMapHostRecord:');



  String get macAddress => _macAddress;
  String get vendor => _vendor;
  String get ipAddress => _ipAddress;
  List<String> get hostNames => _hostnames;
  List<NMapPort> get ports => _ports;
  NMapDeviceStatus get deviceStatus => _deviceStatus;
  XmlElement? get element => _element;
  Map<String, dynamic> get map => _map != null ? _map! : {};

  String get firstHostname {
    if (_hostnames.isNotEmpty) {
      return _hostnames.first;
    } else {
      return _ipAddress;
    }
  }

  NMapHostRecord() {
    _macAddress = '';
    _vendor = '';
    _ipAddress = '';
    _deviceStatus = NMapDeviceStatus.unknown;
    _map = {};
  }

  static List<NMapHostRecord> getActiveHosts(List<NMapHostRecord> hostList) {
    List<NMapHostRecord> activeHosts = [];
    for (NMapHostRecord host in hostList) {
      if (host.deviceStatus == NMapDeviceStatus.up) {
        activeHosts.add(host);
      }
    }
    return activeHosts;
  }

  NMapHostRecord.fromXMLElement(XmlElement hostElement) {
    _element = hostElement;
    Iterable<XmlElement> hostnames = hostElement.findAllElements('hostname');
    _vendor = 'N/A';
    _macAddress = 'N/A';
    _deviceStatus = NMapDeviceStatus.unknown;

    for (XmlElement hostname in hostnames) {
      final attributes = hostname.attributes;
      _parseHostnameAttributes(attributes);
    }
    Iterable<XmlElement> statuses = hostElement.findElements('status');
    for (XmlElement status in statuses) {
      final attributes = status.attributes;
      for (XmlAttribute a in attributes) {
        String name = a.name.toString();
        if (name == 'state') {
          switch (a.value) {
            case 'up':
              _deviceStatus = NMapDeviceStatus.up;
              break;
            case 'down':
              _deviceStatus = NMapDeviceStatus.down;
              break;
            default:
              log.warning('fromXMLElement: $this has unknown status '
                  'state=${a.value}');
              break;
          }
        }
      }
    }
    Iterable<XmlElement> addresses = hostElement.findAllElements('address');
    for (XmlElement address in addresses) {
      final attributes = address.attributes;
      _parseAddressAttributes(attributes);
    }
    Iterable<XmlElement> portsElements = hostElement.findAllElements('ports');
    for (XmlElement pe in portsElements) {
      Iterable<XmlElement> ports = pe.findElements('port');
      for (XmlElement port in ports) {
        NMapPort nMapPort = NMapPort.fromXMLElement(port);
        _ports.add(nMapPort);
      }
    }
    _map = _toMap();
  }

  @override
  String toString() {
    if (_hostnames.isNotEmpty) {
      return '${_hostnames.first} $_ipAddress $_macAddress $_vendor';
    } else {
      return '$_ipAddress $_macAddress $_vendor';
    }
  }

  Map<String, dynamic>? _toMap() {
    Map<String, dynamic>? map;
    String xmlString;
    Xml2Json convert = Xml2Json();

    if (_element != null) {
      xmlString = _element!.toXmlString();
      trace.debug('_toMap: host $firstHostname');
      convert.parse(xmlString);
      String jsonStr = convert.toBadgerfish();
      map = jsonDecode(jsonStr);
    }
    return map;
  }

  // Parse attributes from a hostname element
  void _parseHostnameAttributes(List<XmlAttribute> attributes) {
    String host = '';
    bool isPTR = false;
    for (XmlAttribute a in attributes) {
      if (a.name.toString() == 'name') {
        host = a.value;
      }
      if (a.name.toString() == 'type') {
        if (a.value == 'PTR') {
          isPTR = true;
        }
      }
    }
    if (isPTR) {
      _hostnames.add(host);
    }
  }

  // Parse attributes from and address attribute
  void _parseAddressAttributes(List<XmlAttribute> attributes) {
    NMapAddressType type = NMapAddressType.unknown;
    String id = '';
    for (XmlAttribute a in attributes) {
      switch (a.name.toString()) {
        case 'addrtype':
          switch (a.value) {
            case 'ipv4':
              type = NMapAddressType.ipv4;
              break;
            case 'ipv6':
              type = NMapAddressType.ipv6;
              break;
            case 'mac':
              type = NMapAddressType.mac;
              break;
            default:
              type = NMapAddressType.unknown;
              break;
          }
          break;
        case 'addr':
          id = a.value;
          break;
        case 'vendor':
          _vendor = a.value;
          break;
        default:
          break;
      }
    }
    switch (type) {
      case NMapAddressType.ipv4:
      case NMapAddressType.ipv6:
        _ipAddress = id;
        break;
      case NMapAddressType.mac:
        _macAddress = id;
        break;
      default:
        log.warning('fromXMLDoc: type $type unrecognized');
        break;
    }
  }
}
