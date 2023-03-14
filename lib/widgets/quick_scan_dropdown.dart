import 'package:flutter/material.dart';
import 'package:glog/glog.dart';
import 'package:nmap_gui/utilities/scan_profile.dart';
import 'package:nmap_gui/constants.dart';

class QuickScanController with ChangeNotifier {
  GLog log = GLog('QuickScanController:', properties: gLogPropALL);
  final Map<String, String> _defaultChoiceMap = {
    'Regular Scan': '',
    'Intense Scan': '-T4 -A',
    'Intense Scan plus UDP': '-sS -sU -T4 -A',
    'Intense Scan, all TCP ports': '-p 1-65535 -T4 -A',
    'Intense Scan, no ping': '-T4 -A -v -Pn',
    'Ping Scan': '-sn',
    'Quick Scan': '-T4 -F',
    'Quick Scan Plus': '-sV -T4 -O -F --version-light',
    'Quick Traceroute': '-sn --traceroute',
      'Slow Comprehensive Scan': '-sS -sU -T4 -A -v -PE -PP -PS80,443 -PA3389 '
          '-PU40125 -PY -g 53 --script "default or (discovery and safe)"',
    'Custom': '',
  };
  Map<String, String> _choiceMap = {};

  // This controller is used to pass values to/from the QuickScanDropdown
  QuickScanController({String? key, ScanProfile? profile}) {
    // If a profile is passed in create a choiceMap from it
    if (profile == null) {
      _choiceMap = _defaultChoiceMap;
    } else {
      _choiceMap.clear();
      profile!.config.sections().forEach((section) {
        if (profile!.config.hasOption(section, 'command')) {
          String? command = profile!.config.get(section, 'command');
          if (command != null) {
            _choiceMap.addAll({section: command});
            log.debug('added entry command="$command"');
          } else {
            log.warning('could not find command for section $section');
          }
        }
      });
      // Add kCustomKey at the end
      _choiceMap.addAll({kCustomKey: ''});
    }
    if (_choiceMap.isNotEmpty) {
      _map = {_choiceMap.keys.first: _choiceMap.values.first};
    }
  }
  Map<String, String>? _map;
  bool get isSet => _map != null;
  Map<String, String> get choiceMap => _choiceMap;

  Map<String, String>? get map => _map;
  String? get key => isSet ? _map!.keys!.first : null;
  String? get value => isSet ? _map!.values!.first : null;

  set map(Map<String, String>? m) {
    _map = m;
    notifyListeners();
  }
}

class QuickScanDropDown extends StatefulWidget {
  final QuickScanController controller;
  final void Function(String value)? onChanged;

  const QuickScanDropDown(
      {super.key, required this.controller, this.onChanged});

  @override
  State<QuickScanDropDown> createState() => _QuickScanDropDownState();
}

class _QuickScanDropDownState extends State<QuickScanDropDown> {
  late String dropdownValue;
  List<String> choiceList = [];

  @override
  initState() {
    super.initState();
    for (var k in widget.controller.choiceMap.keys) {
      choiceList.add(k);
    }

    dropdownValue = widget.controller.key != null
        ? widget.controller.key!
        : choiceList.first;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.controller.key != null) {
      dropdownValue = widget.controller.key!;
    }
    return SizedBox(
      width: 220,
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(4),
            borderSide: const BorderSide(width: 1, color: Colors.black45),
          ),
        ),
        value: dropdownValue,
        // dropdownColor: Colors.white,
        // icon: const Icon(Icons.arrow_downward),
        iconSize: 24,
        elevation: 2,
        style: const TextStyle(color: Colors.black54),
        focusColor: Colors.white70,
/*        underline: Container(
          height: 2,
          color: Colors.deepPurpleAccent,
        ),*/
        // This is called when the user selects an item.
        onChanged: (String? key) {
          setState(() {
            dropdownValue = key!;
            if (key! == kCustomKey) {
              // Return if value is custom
              // as we don't want to change the command line options
              // as long as the drop down value is set to 'Custom'
              return;
            }
            if (widget.controller.choiceMap.containsKey(key)) {
              widget.controller.map = {key!: widget.controller.choiceMap[key]!};
            }

            if (widget.onChanged != null) {
              widget.onChanged!(key!);
            }
          });
        },
        items: choiceList.map<DropdownMenuItem<String>>((value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value, overflow: TextOverflow.ellipsis),
          );
        }).toList(),
      ),
    );
  }
}
