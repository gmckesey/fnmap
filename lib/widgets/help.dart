import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:fnmap/models/help_text.dart';

class KriolHelp extends StatelessWidget {
  final String help;
  final Widget child;
  const KriolHelp({super.key, required this.child, required this.help});

  @override
  Widget build(BuildContext context) {
    HelpText helpText = Provider.of<HelpText>(context, listen: false);

    return MouseRegion(
      onEnter: (_) {
        helpText.text = help;
      },
      onExit: (_) {
        helpText.text = '';
      },
      child: child,
    );
  }
}
