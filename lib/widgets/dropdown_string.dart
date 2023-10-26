import 'package:flutter/material.dart';
import 'package:fnmap/utilities/logger.dart';

class KriolDropdownController with ChangeNotifier {
  final NLog log =
      NLog('KriolDropdownController', flag: nLogTRACE, package: 'Kriol Widgets');
  late List<String> _choices;
  late String _initialValue;
  String? _currentValue;

  KriolDropdownController(
      {required String initialValue, required List<String> choices}) {
    _choices = choices;
    _initialValue = initialValue;
  }

  String? get currentValue => _currentValue ?? _initialValue;

  set currentValue(String? value) {
    if (value != null && _choices.contains(value)) {
      _currentValue = value;
    } else {
      _currentValue = _choices.first;
    }
  }
}

class KriolDropdownStringField extends StatefulWidget {
  final KriolDropdownController controller;
  final void Function(String value)? onChanged;
  final TextStyle? textStyle;
  final Color? dropDownColor;
  final Color? focusColor;
  final double width;

  const KriolDropdownStringField({
    super.key,
    required this.controller,
    this.onChanged,
    this.textStyle,
    this.dropDownColor,
    this.focusColor,
    this.width = 130,
  });

  @override
  State<KriolDropdownStringField> createState() =>
      _KriolDropdownStringFieldState();
}

class _KriolDropdownStringFieldState
    extends State<KriolDropdownStringField> {
  final NLog log = NLog('_KriolDropdownStringFieldState',
      flag: nLogTRACE, package: "Kriol Widgets");

  @override
  void initState() {
    super.initState();
    String initialValue = widget.controller._initialValue;
    if (widget.controller._choices.contains(initialValue)) {
      widget.controller._currentValue = initialValue;
    } else {
      log.info(
          'initState: initialValue $initialValue is not in supplied choice list');
      widget.controller._currentValue = widget.controller._choices.first;
    }
  }

  @override
  Widget build(BuildContext context) {
    List<String> choices = widget.controller._choices;
    log.debug('build: value is ${widget.controller.currentValue}');
    return SizedBox(
      width: widget.width,
      height: 50,
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(4),
            borderSide: const BorderSide(width: 1, color: Colors.black45),
          ),
        ),
        iconSize: 24,
        elevation: 2,
        style: widget.textStyle,
        dropdownColor: widget.dropDownColor,
        focusColor: widget.focusColor,
        value: widget.controller.currentValue,
/*      textStyle: widget.textStyle,
        menuStyle: widget.menuStyle,*/
        items: choices.map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(
              value: value,
              child: Text(value, overflow: TextOverflow.ellipsis));
        }).toList(),
        onChanged: (String? value) {
          setState(() {
            widget.controller.currentValue = value;
            if (widget.onChanged != null) {
              widget.onChanged!(widget.controller.currentValue!);
            }
          });
        },
      ),
    );
  }
/*
  Widget buildIt(BuildContext context) {
    List<String> choices = widget.controller._choices;
    return DropdownMenu<String>(
      textStyle: widget.textStyle,
      menuStyle: widget.menuStyle,
      initialSelection: _currentValue,
      dropdownMenuEntries:
          choices.map<DropdownMenuEntry<String>>((String value) {
        return DropdownMenuEntry<String>(value: value, label: value);
      }).toList(),
      onSelected: (String? value) {
        setState(() {
          widget.controller._currentValue = value!;
          if (widget.onChanged != null) {
            widget.onChanged!(value!);
          }
        });
      },
    );
  }*/
}
