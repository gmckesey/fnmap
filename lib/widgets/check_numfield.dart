import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:flutter_spinbox/flutter_spinbox.dart';
import 'package:fnmap/widgets/checkbox.dart';
import 'package:fnmap/utilities/logger.dart';
import 'package:fnmap/models/dark_mode.dart';

class KriolCheckNumericField extends StatefulWidget {
  final int initialValue;
  final int max;
  final int min;
  final bool enabledP;
  final void Function(int value) onChanged;
  final double width;
  final String title;

  const KriolCheckNumericField({
    super.key,
    required this.initialValue,
    required this.max,
    required this.min,
    this.enabledP = true,
    required this.title,
    required this.onChanged,
    this.width = 200,
  }) : assert(max >= initialValue && min <= initialValue);

  @override
  State<KriolCheckNumericField> createState() => _KriolCheckNumericFieldState();
}

class _KriolCheckNumericFieldState extends State<KriolCheckNumericField> {
  NLog log = NLog('_KriolCheckTextFieldState');
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
    Color disabledColor = mode.themeData.disabledColor;
    Color labelColor = mode.themeData.secondaryHeaderColor;

    return Row(children: [
      KriolCheckBox(
          initialValue: enabled,
          onChanged: (value) {
            log.debug('build[KriolCheckBox[onChanged]: value set to $value');
            setState(() {
              enabled = value!;
              if (!value!) {
                picked = 0;
              }
              log.debug('KriolCheckBox:onChanged - textFieldEnabled = $value');
            });
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
                    ? TextStyle(color: textColor)
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
    ]);
  }
}
