import 'package:flutter/material.dart';
import 'package:fnmap/widgets/formatted_text.dart' as fw_widget;

void
reportError(BuildContext context,
    {required String errorMsg, required ThemeData themeData}) {
  showDialog(
      context: context,
      builder: (BuildContext
      context) =>
          Theme(
              data: themeData,
              child: AlertDialog(
                  title: const Text(
                      'Start Error'),
                  content: fw_widget.FormattedText(errorMsg),
                  actions: <Widget>[
                    TextButton(
                        onPressed: () =>
                            Navigator.pop(
                                context,
                                'Ok'),
                        child:
                        const Text(
                            'Ok')),
                  ])));
}
