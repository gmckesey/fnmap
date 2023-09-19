import 'package:args/args.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:fnmap/widgets/check_textfield.dart';
import 'package:fnmap/models/edit_profile_controllers.dart';
import 'package:fnmap/models/nmap_command.dart';
import 'package:fnmap/utilities/logger.dart';

class TargetOptions extends StatefulWidget {
  final TargetScanControllers targetScanControllers;
  const TargetOptions({
    super.key,
    required this.targetScanControllers,
  });

  @override
  State<TargetOptions> createState() => _TargetOptionsState();
}

class _TargetOptionsState extends State<TargetOptions> {
  NLog log = NLog('_TargetOptionsState:');
  late TargetScanControllers targetScanControllers;

  @override
  void initState() {
    super.initState();

    NMapCommand nMapCommand = Provider.of<NMapCommand>(context, listen: false);
    targetScanControllers = widget.targetScanControllers;
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Row(children: [
        KriolCheckTextField(
            iconP: Icons.edit,
            hintP: 'Excluded hosts',
            labelP: 'Excluded hosts',
            controllerP: targetScanControllers.exclude.controller,
            enabledP: targetScanControllers.exclude.enabled!),
        KriolCheckTextField(
          iconP: Icons.edit,
          hintP: 'Excluded File',
          labelP: 'Excluded File',
          controllerP: targetScanControllers.excludeFile.controller,
          enabledP: targetScanControllers.excludeFile.enabled!,
        ),
      ]),
      Row(children: [
        KriolCheckTextField(
          iconP: Icons.edit,
          hintP: 'Target list File',
          labelP: 'Target list File',
          controllerP: targetScanControllers.targetFile.controller,
          enabledP: targetScanControllers.targetFile.enabled!,
        ),
        KriolCheckTextField(
          iconP: Icons.edit,
          hintP: 'Random Hosts',
          labelP: 'Scan Random Hosts',
          width: 300,
          controllerP: targetScanControllers.randomHost.controller,
          enabledP: targetScanControllers.randomHost.enabled!,
        ),
      ]),
      KriolCheckTextField(
        iconP: Icons.edit,
        hintP: 'Ports to Scan',
        labelP: 'ports',
        controllerP: targetScanControllers.ports.controller,
        enabledP: targetScanControllers.ports.enabled!,
      ),
    ]);
  }
}
