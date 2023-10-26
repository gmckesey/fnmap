import 'package:fnmap/widgets/checkbox.dart';
import 'package:flutter/material.dart';
import 'package:fnmap/widgets/check_textfield.dart';
import 'package:fnmap/controllers/edit_profile_controllers.dart';
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
            helpP: 'A comma separated list of IPs or FQDNs (--exclude)',
            controllerP: targetScanControllers.exclude,
            enabledP: targetScanControllers.exclude.enabled,
            onChangedP: (enabled, textValue) {
              setState(() {
                targetScanControllers.exclude.enabled = enabled!;
              });
            }),
        KriolCheckTextField(
            iconP: Icons.edit,
            hintP: 'Excluded File',
            labelP: 'Excluded File',
            helpP: 'The filename of a file containing excluded IPs or FQDNs\n'
            'newline, space or tab delimited (--excludefile)',
            controllerP: targetScanControllers.excludeFile,
            enabledP: targetScanControllers.excludeFile.enabled,
            onChangedP: (enabled, textValue) {
              setState(() {
                targetScanControllers.excludeFile.enabled = enabled!;
              });
            }),
      ]),
      Row(children: [
        KriolCheckTextField(
            iconP: Icons.edit,
            hintP: 'Target list File',
            labelP: 'Target list File',
            helpP: 'The filename of a file containing the hosts to be scanned IPs, FQDNs\n'
                'or CIDRs can be used.  Entries are newline, space or tab delimited (-iL)',
            controllerP: targetScanControllers.targetFile,
            enabledP: targetScanControllers.targetFile.enabled,
            onChangedP: (enabled, textValue) {
              setState(() {
                targetScanControllers.targetFile.enabled = enabled!;
              });
            }),
        KriolCheckTextField(
            iconP: Icons.edit,
            hintP: 'Random Hosts',
            labelP: 'Scan Random Hosts',
            helpP: 'The number or random targets to scan, use 0 for a never ending scan (-iR)',
            width: 300,
            controllerP: targetScanControllers.randomHost,
            enabledP: targetScanControllers.randomHost.enabled,
            onChangedP: (enabled, textValue) {
              setState(() {
                targetScanControllers.randomHost.enabled = enabled!;
              });
            }),
      ]),
      KriolCheckTextField(
        iconP: Icons.edit,
        hintP: 'Ports to Scan',
        labelP: 'ports',
        helpP: 'Specify ports to scan eg. 1-1024,8000,8008,8080 (-p)',
        controllerP: targetScanControllers.ports,
        enabledP: targetScanControllers.ports.enabled,
        onChangedP: (enabled, textValue) {
          setState(() {
            targetScanControllers.ports.enabled = enabled!;
          });
        },
      ),
      Row(
        children: [
          KriolCheckBox(
              initialValue: targetScanControllers.fastScan!.isSet,
              title: 'Fast scan',
              help: 'Only scan ports from the nmap-services (or nmap-protocols) files (-F)',
              onChanged: (bool? value) {
                setState(() {
                  targetScanControllers.fastScan!(value!);
                  log.debug(
                      'KriolCheckbox:onChanged - fast scan value = $value');
                });
              }),
        ],
      )
    ]);
  }
}
