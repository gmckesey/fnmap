import 'package:fnmap/utilities/logger.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:fnmap/models/dark_mode.dart';
import 'package:fnmap/controllers/textfield_controller.dart';
import 'package:fnmap/widgets/kriol_widgets.dart';

class KriolTextField extends StatelessWidget {
  final KriolTextFieldController controllerP;
  final IconData? iconP;
  final String? hintP;
  final String? labelP;
  final bool enabledP;
  final void Function(String?)? onChangedP;
  final String? Function(String?)? validatorP;
  final void Function(String?)? onSubmittedP;
  final double width;

  const KriolTextField({
    super.key,
    required this.controllerP,
    this.iconP,
    this.hintP,
    this.labelP,
    this.enabledP = true,
    this.onChangedP,
    this.validatorP,
    this.onSubmittedP,
    this.width = 200,
  });

  @override
  Widget build(BuildContext context) {
    NMapDarkMode mode = Provider.of<NMapDarkMode>(context, listen: true);
    Color disabledColor = mode.themeData.disabledColor;
    Color labelColor = mode.themeData.secondaryHeaderColor;
    NLog log = NLog('KriolTextField:', package: kriolWidgets);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: SizedBox(
        width: width,
        child: TextFormField(
          controller: controllerP.textController,
          enabled: enabledP,
          validator: validatorP,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          onFieldSubmitted: onSubmittedP,
          style: mode.themeData.textTheme.displayMedium,
          decoration: InputDecoration(
            border: const OutlineInputBorder(),
            icon: iconP != null ? Icon(iconP) : null,
            hintText: hintP,
            hintStyle:
                TextStyle(color: disabledColor, fontStyle: FontStyle.italic),
            labelText: labelP,
            labelStyle:
                TextStyle(color: labelColor, fontStyle: FontStyle.italic,
                fontSize: 12.0,
                ),
          ),
          onChanged: (value) {
            // Unfortunately I have to run the validator twice to get the behaviour that I want
            // Which is to validate before call onChanged.
            if (validatorP == null || validatorP?.call(value) == null) {
              log.debug(
                  'build(onChanged): notifying listeners of value changed to ${controllerP.text}');
              controllerP.notify();
              onChangedP?.call(value);
            } else {
              log.debug(
                  'build(onChanged): ${controllerP.text} not valid, do not notify listeners');
            }
          },
        ),
      ),
    );
  }
}
