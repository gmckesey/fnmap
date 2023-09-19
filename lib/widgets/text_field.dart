import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:fnmap/models/dark_mode.dart';

class KriolTextField extends StatelessWidget {
  final TextEditingController controllerP;
  final IconData? iconP;
  final String? hintP;
  final String? labelP;
  final bool enabledP;
  final void Function(String?)? onSavedP;
  final String? Function(String?)? validatorP;
  final void Function(String?)? onSubmittedP;
  final double width;

  const KriolTextField({super.key, required this.controllerP,
    this.iconP,
    this.hintP,
    this.labelP,
    this.enabledP = true,
    this.onSavedP,
    this.validatorP,
    this.onSubmittedP,
    this.width = 200,
  });

  @override
  Widget build(BuildContext context) {
    NMapDarkMode mode = Provider.of<NMapDarkMode>(context, listen: true);
    Color textColor = mode.themeData.primaryColorLight;
    Color disabledColor = mode.themeData.disabledColor;
    Color labelColor = mode.themeData.secondaryHeaderColor;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: SizedBox(
        width: width,
        child: TextFormField(
          controller: controllerP,
          enabled: enabledP,
          style: TextStyle(color: textColor),
          decoration: InputDecoration(
            border: const OutlineInputBorder(),
            icon: iconP != null ? Icon(iconP) : null,
            hintText: hintP,
            hintStyle:
            TextStyle(color: disabledColor, fontStyle: FontStyle.italic),
            labelText: labelP,
            labelStyle: TextStyle(color: labelColor),
          ),
          onSaved: onSavedP,
          validator: validatorP,
          onFieldSubmitted: onSubmittedP,
        ),
      ),
    );
  }
}
