import 'package:fnmap/widgets/check_textfield.dart';
import 'package:flutter/material.dart';
import 'package:fnmap/widgets/check_numfield.dart';
import 'package:fnmap/widgets/checkbox.dart';
import 'package:fnmap/models/edit_profile_controllers.dart';
import 'package:fnmap/utilities/logger.dart';

class OtherOptions extends StatefulWidget {
  final OtherScanControllers otherScanControllers;
  const OtherOptions({
    super.key,
    required this.otherScanControllers,
  });

  @override
  State<OtherOptions> createState() => _OtherOptionsState();
}

class _OtherOptionsState extends State<OtherOptions> {
  NLog log = NLog('_OtherOptionsState');
  late OtherScanControllers otherScanControllers;

  @override
  void initState() {
    super.initState();
    otherScanControllers = widget.otherScanControllers;
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      KriolCheckTextField(
        iconP: Icons.edit,
        hintP: 'Set IPv4 ttl',
        labelP: 'IPv4 ttl',
        controllerP: otherScanControllers.ipV4ttl.controller,
        enabledP: otherScanControllers.ipV4ttl.enabled!,
      ),
      Row(
        children: [
          KriolCheckBox(
              initialValue: otherScanControllers.fragmentIP!,
              title: 'Fragment IP packets',
              onChanged: (bool? value) {
                setState(() {
                  otherScanControllers.fragmentIP = value;
                  log.debug(
                      'KriolCheckbox:onChanged - fragment IP value = $value');
                });
              })
        ],
      ),
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          children: [
            KriolCheckNumericField(
                initialValue: otherScanControllers.verbosityLevel!,
                max: 10,
                min: 0,
                title: 'Verbosity level',
                enabledP: otherScanControllers.enableVerbosityLevel!,
                onChanged: (value) {
                  if (otherScanControllers.enableVerbosityLevel!) {
                    setState(() {
                      otherScanControllers.verbosityLevel = value!;
                      log.debug(
                          'KriolCheckNumericField:onChanged - verbosity level = $value');
                    });
                  }
                }),
            KriolCheckNumericField(
                initialValue: otherScanControllers.debugLevel!,
                max: 10,
                min: 0,
                title: 'Debug level',
                enabledP: otherScanControllers.enableDebugLevel!,
                onChanged: (value) {
                  if (otherScanControllers.enableDebugLevel!) {
                    setState(() {
                      otherScanControllers.debugLevel = value!;
                      log.debug(
                          'KriolCheckNumericField:onChanged - debug level = $value');
                    });
                  }
                }),
          ],
        ),
      ),
      Row(
        children: [
          KriolCheckBox(
              initialValue: otherScanControllers.packetTrace!,
              title: 'Packet trace',
              onChanged: (bool? value) {
                setState(() {
                  otherScanControllers.packetTrace = value;
                  log.debug(
                      'KriolCheckbox:onChanged - packet trace value = $value');
                });
              }),
          KriolCheckBox(
              initialValue: otherScanControllers.disableRandomPorts!,
              title: 'Disabling randomizing scanned ports',
              onChanged: (bool? value) {
                setState(() {
                  otherScanControllers.disableRandomPorts = value;
                  log.debug(
                      'KriolCheckbox:onChanged - disable radomizing scanned ports = $value');
                });
              }),
          KriolCheckBox(
              initialValue: otherScanControllers.traceRoute!,
              title: 'Trace routes to target',
              onChanged: (bool? value) {
                setState(() {
                  otherScanControllers.traceRoute = value;
                  log.debug(
                      'KriolCheckbox:onChanged - trace route = $value');
                });
              })
        ],
      ),
      Row(children: [
        KriolCheckTextField(
          iconP: Icons.edit,
          hintP: 'Max retries',
          labelP: 'Max retries',
          controllerP: otherScanControllers.maxRetries.controller,
          enabledP: otherScanControllers.maxRetries.enabled!,
        ),
      ],)
    ]);
  }
}
