import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinbox/flutter_spinbox.dart';
import 'package:fnmap/widgets/kriol_widgets.dart';
import 'package:fnmap/widgets/checkbox.dart';
import 'package:fnmap/widgets/help.dart';
import 'package:fnmap/utilities/logger.dart';
import 'package:fnmap/models/dark_mode.dart';

class KriolCheckNumericField extends StatefulWidget {
  final int initialValue;
  final int max;
  final int min;
  final String? helpP;
  final bool enabledP;
  final void Function(int value) onChanged;
  final void Function(bool value) onChecked;
  final double width;
  final String title;

  const KriolCheckNumericField({
    super.key,
    required this.initialValue,
    required this.max,
    required this.min,
    this.helpP,
    this.enabledP = true,
    required this.title,
    required this.onChanged,
    required this.onChecked,
    this.width = 200,
  }) : assert(max >= initialValue && min <= initialValue);

  @override
  State<KriolCheckNumericField> createState() => _KriolCheckNumericFieldState();
}

class _KriolCheckNumericFieldState extends State<KriolCheckNumericField> {
  NLog log = NLog('_KriolCheckTextFieldState', package: kriolWidgets);
  late bool enabled;
  late int picked;

  @override
  void initState() {
    super.initState();
    enabled = widget.enabledP;
    picked = widget.initialValue;
  }

  @override
  Widget build(BuildContext context) {
    NMapDarkMode mode = Provider.of<NMapDarkMode>(context, listen: true);
    Color textColor = mode.themeData.primaryColorLight;
    Color disabledColor = Colors.red; //mode.themeData.disabledColor;
    Color darkColor = mode.themeData.primaryColorDark;
    Color labelColor = Colors.green; //mode.themeData.secondaryHeaderColor;

    Widget checkField = Container(
      decoration: BoxDecoration(
        border: Border.all(color: darkColor, width: 2),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(children: [
          KriolCheckBox(
              initialValue: enabled,
              decoration: false,
              onChanged: (value) {
                log.debug('build[KriolCheckBox[onChanged]: value set to $value');
                setState(() {
                  enabled = value!;
                  if (!value) {
                    picked = 0;
                  }
                  log.debug('KriolCheckBox:onChanged - textFieldEnabled = $value');
                });
                widget.onChecked(value!);
              }),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: SizedBox(
              width: 150,
              child: SpinBox(
                min: widget.min.toDouble(),
                max: widget.max.toDouble(),
                value: picked.toDouble(),
                enabled: enabled,
                textStyle: enabled
                    ? TextStyle(color: textColor)
                    : TextStyle(color: disabledColor, fontStyle: FontStyle.italic),
                decoration: InputDecoration(
                    labelText: widget.title,
                    labelStyle: enabled
                        ? TextStyle(color: labelColor)
                        : TextStyle(
                            color: disabledColor, fontStyle: FontStyle.italic)),
                onChanged: (value) {
                  setState(() {
                    picked = value.toInt();
                  });
                  widget.onChanged(value.toInt());
                },
              ),
            ),
          )
        ]),
      ),
    );
    if (widget.helpP != null) {
      return Row(children: [KriolHelp(help: widget.helpP!, child: checkField)]);
    } else {
      return Row(children: [checkField]);
    }
  }
}
