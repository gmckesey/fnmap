import 'package:fnmap/widgets/check_textfield.dart';
import 'package:flutter/material.dart';
import 'package:fnmap/widgets/check_numfield.dart';
import 'package:fnmap/widgets/checkbox.dart';
import 'package:fnmap/controllers/edit_profile_controllers.dart';
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
          helpP: 'Set IPv4 time-to-live value eg. 100 (--ttl)',
          controllerP: otherScanControllers.ipV4ttl,
          enabledP: otherScanControllers.ipV4ttl.enabled,
          onChangedP: (enabled, textValue) {
            setState(() {
              otherScanControllers.ipV4ttl.enabled = enabled!;
            });
          }),
      Row(
        children: [
          KriolCheckBox(
              initialValue: otherScanControllers.fragmentIP!.isSet,
              title: 'Fragment IP packets',
              help: 'Split TCP headers over several packets (-f)',
              onChanged: (bool? value) {
                setState(() {
                  otherScanControllers.fragmentIP!.isSet = value!;
                  log.debug(
                      'KriolCheckbox:onChanged - fragment IP value = $value');
                });
              })
        ],
      ),
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: Row(
          children: [
            KriolCheckNumericField(
                initialValue: otherScanControllers.verbosityLevel!.value,
                max: 10,
                min: 0,
                title: 'Verbosity level',
                helpP:
                    'Show more information about the scan while it is running (-v)',
                enabledP: otherScanControllers.enableVerbosityLevel!.isSet,
                onChanged: (value) {
                  if (otherScanControllers.enableVerbosityLevel!.isSet) {
                    setState(() {
                      otherScanControllers.verbosityLevel!.value = value;
                      log.debug(
                          'KriolCheckNumericField:onChanged - verbosity level = $value');
                    });
                  }
                },
              onChecked: (value) {
                  setState(() {
                    otherScanControllers.enableVerbosityLevel!.isSet = value;
                  });
              },
            ),
            const SizedBox(width: 8.0),
            KriolCheckNumericField(
                initialValue: otherScanControllers.debugLevel!.value,
                max: 10,
                min: 0,
                title: 'Debug level',
                helpP: 'Show more detailed information (-d)',
                enabledP: otherScanControllers.enableDebugLevel!.isSet,
                onChanged: (value) {
                  if (otherScanControllers.enableDebugLevel!.isSet) {
                    setState(() {
                      otherScanControllers.debugLevel!.value = value;
                      log.debug(
                          'KriolCheckNumericField:onChanged - debug level = $value');
                    });
                  }
                },
              onChecked: (value) {
                  setState(() {
                    otherScanControllers.enableDebugLevel!.isSet  = value;
                  });
              },
                ),
          ],
        ),
      ),
      Row(
        children: [
          KriolCheckBox(
              initialValue: otherScanControllers.packetTrace!.isSet,
              title: 'Packet trace',
              help: 'log information about every packet sent (--packet-trace)',
              onChanged: (bool? value) {
                setState(() {
                  otherScanControllers.packetTrace!.isSet = value!;
                  log.debug(
                      'KriolCheckbox:onChanged - packet trace value = $value');
                });
              }),
          KriolCheckBox(
              initialValue: otherScanControllers.disableRandomPorts!.isSet,
              title: 'Disabling randomizing scanned ports',
              help: 'scan ports in order rather than randomly (-r)',
              onChanged: (bool? value) {
                setState(() {
                  otherScanControllers.disableRandomPorts!.isSet = value!;
                  log.debug(
                      'KriolCheckbox:onChanged - disable randomizing scanned ports = $value');
                });
              }),
          KriolCheckBox(
              initialValue: otherScanControllers.traceRoute!.isSet,
              title: 'Trace routes to target',
              help: 'Trace the network path to each packet (--traceroute)',
              onChanged: (bool? value) {
                setState(() {
                  otherScanControllers.traceRoute!.isSet = value!;
                  log.debug('KriolCheckbox:onChanged - trace route = $value');
                });
              })
        ],
      ),
      Row(
        children: [
          KriolCheckTextField(
              iconP: Icons.edit,
              hintP: 'Max retries',
              labelP: 'Max retries',
              helpP:
                  'How many probes to send to target before giving up on a response (--max-retries)',
              controllerP: otherScanControllers.maxRetries,
              enabledP: otherScanControllers.maxRetries.enabled,
              onChangedP: (enabled, textValue) {
                setState(() {
                  otherScanControllers.maxRetries.enabled = enabled!;
                });
              }),
        ],
      )
    ]);
  }
}
