import 'package:fnmap/widgets/checkbox.dart';
import 'package:fnmap/widgets/text_field.dart';
import 'package:flutter/material.dart';
import 'package:fnmap/utilities/logger.dart';

class KriolCheckTextField extends StatefulWidget {
  final TextEditingController controllerP;
  final IconData? iconP;
  final String? hintP;
  final String? labelP;
  final bool enabledP;
  final void Function(String?)? onSavedP;
  final String? Function(String?)? validatorP;
  final void Function(String?)? onSubmittedP;
  final double width;

  const KriolCheckTextField({super.key, required this.controllerP,
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
  State<KriolCheckTextField> createState() => _KriolCheckTextFieldState();

}

class _KriolCheckTextFieldState extends State<KriolCheckTextField> {
  NLog log = NLog('_KriolCheckTextFieldState');
  late bool textFieldEnabled;

  @override
  void initState() {
    super.initState();
    textFieldEnabled = widget.enabledP;
  }

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      KriolCheckBox(initialValue: textFieldEnabled, onChanged: (value) {
        log.debug('build[KriolCheckBox[onChanged]: value set to $value');
        setState(() {
          textFieldEnabled = value!;
        });
      }),
      KriolTextField(
        iconP: Icons.edit,
        hintP: widget.hintP,
        width: widget.width,
        labelP: widget.labelP,
        controllerP: widget.controllerP,
        enabledP: textFieldEnabled,
      ),
    ]);
  }
}