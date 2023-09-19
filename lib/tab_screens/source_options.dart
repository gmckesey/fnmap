import 'package:fnmap/widgets/check_textfield.dart';
import 'package:provider/provider.dart';
import 'package:args/args.dart';
import 'package:flutter/material.dart';
import 'package:fnmap/widgets/text_field.dart';
import 'package:fnmap/widgets/dropdown_string.dart';
import 'package:fnmap/widgets/checkbox.dart';
import 'package:fnmap/models/edit_profile_controllers.dart';
import 'package:fnmap/models/dark_mode.dart';
import 'package:fnmap/models/nmap_command.dart';
import 'package:fnmap/utilities/logger.dart';

class SourceOptions extends StatefulWidget {
  final SourceScanControllers sourceScanControllers;
  const SourceOptions({
    super.key,
    required this.sourceScanControllers,
  });

  @override
  State<SourceOptions> createState() => _SourceOptionsState();
}

class _SourceOptionsState extends State<SourceOptions> {
  late SourceScanControllers sourceScanControllers;
  @override
  void initState() {
    super.initState();
    NMapCommand nMapCommand = Provider.of<NMapCommand>(context, listen: false);
    ArgResults results = nMapCommand.results;
    sourceScanControllers = widget.sourceScanControllers;
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      KriolCheckTextField(
        width: 300,
        iconP: Icons.edit,
        hintP: 'Decoys',
        labelP: 'Use decoys to hide identity',
        controllerP: sourceScanControllers.decoy.controller,
        enabledP: sourceScanControllers.decoy.enabled!,
      ),
      KriolCheckTextField(
        width: 300,
        iconP: Icons.edit,
        hintP: 'Source IP Address',
        labelP: 'Sets source IP address',
        controllerP: sourceScanControllers.sourceIP.controller,
        enabledP: sourceScanControllers.sourceIP.enabled!,
      ),
      KriolCheckTextField(
        iconP: Icons.edit,
        hintP: 'Source port',
        labelP: 'Set source port',
        controllerP: sourceScanControllers.sourcePort.controller,
        enabledP: sourceScanControllers.sourcePort.enabled!,
      ),
      KriolCheckTextField(
        iconP: Icons.edit,
        hintP: 'Network Interface',
        labelP: 'Set network interface',
        controllerP: sourceScanControllers.networkIF.controller,
        enabledP: sourceScanControllers.networkIF.enabled!,
      ),
    ]);
  }
}
