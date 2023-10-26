import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:fnmap/utilities/logger.dart';
import 'package:fnmap/models/dark_mode.dart';
import 'package:fnmap/widgets/kriol_widgets.dart';
import 'package:fnmap/widgets/checkbox.dart';
import 'package:fnmap/widgets/text_field.dart';
import 'package:fnmap/widgets/help.dart';
import 'package:fnmap/controllers/textfield_controller.dart';

class KriolCheckTextField extends StatefulWidget {
  final KriolTextFieldController controllerP;
  final IconData? iconP;
  final String? hintP;
  final String? labelP;
  final String? helpP;
  final bool enabledP;
  final void Function(bool?, String?)? onChangedP;
  final String? Function(String?)? validatorP;
  final void Function(String?)? onSubmittedP;
  final double width;

  const KriolCheckTextField({
    super.key,
    required this.controllerP,
    this.iconP,
    this.hintP,
    this.labelP,
    this.helpP,
    this.enabledP = true,
    this.onChangedP,
    this.validatorP,
    this.onSubmittedP,
    this.width = 200,
  });

  @override
  State<KriolCheckTextField> createState() => _KriolCheckTextFieldState();
}

class _KriolCheckTextFieldState extends State<KriolCheckTextField> {
  NLog log = NLog('_KriolCheckTextFieldState', package: kriolWidgets);
  late bool textFieldEnabled;

  @override
  void initState() {
    super.initState();
    textFieldEnabled = widget.enabledP;
  }

  @override
  Widget build(BuildContext context) {
    NMapDarkMode mode = Provider.of<NMapDarkMode>(context, listen: true);
    Color darkColor = mode.themeData.primaryColorDark;

    Widget checkBox = Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: darkColor, width: 2),
        ),
        child: Row(children: [
          KriolCheckBox(
              initialValue: textFieldEnabled,
              decoration: false,
              onChanged: (value) {
                log.debug(
                    'build[KriolCheckTextField - Checkbox [onChanged]: value set to $value');
                setState(() {
                  textFieldEnabled = value!;
                  if (!value) {
                    widget.controllerP.text = null;
                  }
                });
                if (widget.onChangedP != null) {
                  widget.onChangedP!(value, widget.controllerP.text);
                }
              }),
          KriolTextField(
            iconP: Icons.edit,
            hintP: widget.hintP,
            width: widget.width,
            labelP: widget.labelP,
            controllerP: widget.controllerP,
            validatorP: widget.validatorP,
            onSubmittedP: widget.onSubmittedP,
            enabledP: textFieldEnabled,
            onChangedP: (text) {
              log.debug(
                  'build:[KriolCheckTextField - TextField [onChanged]: text set to $text');
              if (widget.onChangedP != null) {
/*                setState(() {
                  widget.onChangedP!(textFieldEnabled, text);
                });*/
                widget.onChangedP!(textFieldEnabled, text);
              }
            },
          ),
        ]),
      ),
    );

    if (widget.helpP != null) {
      return Row(children: [KriolHelp(help: widget.helpP!, child: checkBox)]);
    } else {
      return Row(children: [checkBox]);
    }
  }
}
