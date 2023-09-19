import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:fnmap/models/dark_mode.dart';
import 'package:fnmap/utilities/logger.dart';

class KriolCheckBox extends StatefulWidget {
  final Function(bool? value) onChanged;
  final bool initialValue;
  final String? title;

  const KriolCheckBox(
      {super.key,
        required this.initialValue,
        this.title,
        required this.onChanged});

  @override
  State<KriolCheckBox> createState() => _KriolCheckBoxState();
}

class _KriolCheckBoxState extends State<KriolCheckBox> {
  NLog log = NLog('_KriolCheckBoxState:');

  @override
  Widget build(BuildContext context) {
    NMapDarkMode mode = Provider.of<NMapDarkMode>(context, listen: false);
    Color textColor = mode.themeData.primaryColorLight;
    Color labelColor = mode.themeData.secondaryHeaderColor;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Container(
        decoration:
        BoxDecoration(border: Border.all(width: 2.0, color: labelColor)),
        child: Row(children: <Widget>[
          Checkbox(
            value: widget.initialValue,
            checkColor: Colors.white,
            fillColor: MaterialStateProperty.resolveWith(_getColor),
            onChanged: widget.onChanged,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(
              widget.title ?? '',
              style: TextStyle(color: textColor),
            ),
          ),
        ]),
      ),
    );
  }

  Color _getColor(Set<MaterialState> states) {
    const Set<MaterialState> interactiveStates = <MaterialState>{
      MaterialState.pressed,
      MaterialState.hovered,
      MaterialState.focused,
    };
    if (states.any(interactiveStates.contains)) {
      return Colors.blue;
    }
    return Colors.red;
  }
}