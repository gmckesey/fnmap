import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:fnmap/models/dark_mode.dart';
import 'package:fnmap/utilities/logger.dart';
import 'package:fnmap/widgets/kriol_widgets.dart';
import 'package:fnmap/widgets/help.dart';

class KriolCheckBox extends StatefulWidget {
  final Function(bool? value) onChanged;
  final bool initialValue;
  final String? title;
  final String? help;
  final bool decoration;

  const KriolCheckBox(
      {super.key,
      required this.initialValue,
      this.title,
      this.help,
      this.decoration = true,
      required this.onChanged});

  @override
  State<KriolCheckBox> createState() => _KriolCheckBoxState();
}

class _KriolCheckBoxState extends State<KriolCheckBox> {
  NLog log = NLog('_KriolCheckBoxState:', package: kriolWidgets);

  @override
  Widget build(BuildContext context) {
    NMapDarkMode mode = Provider.of<NMapDarkMode>(context, listen: false);
    Color textColor = mode.themeData.primaryColor;
    Color labelColor = mode.themeData.secondaryHeaderColor;

    Widget checkbox = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Container(
        decoration: !widget.decoration
            ? null
            : BoxDecoration(border: Border.all(width: 2.0, color: labelColor)),
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

    if (widget.help != null) {
      return KriolHelp(help: widget.help!, child: checkbox);
    } else {
      return checkbox;
    }
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
