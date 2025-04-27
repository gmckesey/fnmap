import 'dart:collection';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:fnmap/utilities/logger.dart';
import 'package:fnmap/utilities/scan_profile.dart';
import 'package:fnmap/constants.dart';
import 'package:fnmap/models/dark_mode.dart';

class QuickScanController with ChangeNotifier {
  NLog log =
      NLog('QuickScanController:', flag: nLogTRACE, package: kPackageName);
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
  Map<String, String>? _map;

  // This controller is used to pass values to/from the QuickScanDropdown
  QuickScanController({String? key, ScanProfile? profile}) {
    // If a profile is passed in create a choiceMap from it
    if (profile == null) {
      _choiceMap = _defaultChoiceMap;
    } else {
      _choiceMap.clear();
      profile.config.sections().forEach((section) {
        if (profile.config.hasOption(section, 'command')) {
          String? command = profile.config.get(section, 'command');
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

  bool get isSet => _map != null;
  UnmodifiableMapView<String, String> get choiceMap =>
      UnmodifiableMapView(_choiceMap);

  void addEntry(key, value) {
    // Only add the entry for a new key
    if (_choiceMap.containsKey(key)) {
      log.warning('addEntry: Key [$key] already exists');
      return;
    }
    _choiceMap.addAll({key: value});
    _choiceMap.remove('Custom');
    _choiceMap.addAll({'Custom':''});
    notifyListeners();
  }

  void editEntry(key, value) {
    if (_choiceMap.containsKey(key)) {
      _choiceMap[key] = value;
      notifyListeners();
    } else {
      log.warning('editEntry: Map does not contain key [$key]');
    }
  }

  void editCurrentEntry(key, value) {
    _map = { key : value };
    editEntry(key, value);
  }

  void deleteEntry(key) {
    if (_choiceMap.containsKey(key)) {
      _choiceMap.remove(key);
      _map = { _choiceMap.keys.first: _choiceMap.values.first};
      notifyListeners();
    } else {
      log.warning('deleteEntry: Map does not contain key [$key]');
    }
  }

  Map<String, String>? get map => _map;
  String? get key => isSet ? _map!.keys.first : null;
  String? get value => isSet ? _map!.values.first : null;

  set map(Map<String, String>? m) {
    _map = m;
    notifyListeners();
  }
}

class QuickScanDropDown extends StatefulWidget {
  final QuickScanController controller;
  final void Function(String value)? onChanged;
  final double width;

  const QuickScanDropDown(
      {super.key, required this.controller, this.onChanged, this.width = 220});

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
    NMapDarkMode mode = Provider.of<NMapDarkMode>(context, listen: true);

    if (widget.controller.key != null) {
      dropdownValue = widget.controller.key!;
    }
    return SizedBox(
      width: widget.width,
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
        iconEnabledColor: mode.themeData.secondaryHeaderColor,
        iconSize: 24,
        elevation: 2,
        style: TextStyle(color: mode.themeData.primaryColorDark),
        dropdownColor: mode.themeData.canvasColor,
        focusColor: mode.themeData.focusColor,
/*        underline: Container(
          height: 2,
          color: Colors.deepPurpleAccent,
        ),*/
        // This is called when the user selects an item.
        onChanged: (String? key) {
          setState(() {
            dropdownValue = key!;
            if (key == kCustomKey) {
              // Return if value is custom
              // as we don't want to change the command line options
              // as long as the drop down value is set to 'Custom'
              return;
            }
            if (widget.controller.choiceMap.containsKey(key)) {
              widget.controller.map = {key: widget.controller.choiceMap[key]!};
            }

            if (widget.onChanged != null) {
              widget.onChanged!(key);
            }
          });
        },
        items: choiceList.map<DropdownMenuItem<String>>((value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value,
                style: mode.themeData.textTheme.labelMedium,
                overflow: TextOverflow
                    .ellipsis), // style: Theme.of(context).textTheme.bodyMedium,),
          );
        }).toList(),
      ),
    );
  }
}
