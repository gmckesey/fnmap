import 'package:fnmap/widgets/check_textfield.dart';
import 'package:flutter/material.dart';
import 'package:fnmap/controllers/edit_profile_controllers.dart';

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
        helpP:
            'Send probes from fake a comma separated list of decoy addresses optionally use ME to include\n'
            'your own IP and use RND for a random address, RND:n where n is a number for n random addresses\n(-D)',
        controllerP: sourceScanControllers.decoy,
        enabledP: sourceScanControllers.decoy.enabled,
        onChangedP: (enabled, textValue) {
          setState(() {
            sourceScanControllers.decoy.enabled = enabled!;
          });
        },
      ),
      KriolCheckTextField(
        width: 300,
        iconP: Icons.edit,
        hintP: 'Source IP Address',
        labelP: 'Sets source IP address',
        helpP: 'The IP of the interface to use as the source (-S)',
        controllerP: sourceScanControllers.sourceIP,
        enabledP: sourceScanControllers.sourceIP.enabled,
        onChangedP: (enabled, textValue) {
          setState(() {
            sourceScanControllers.sourceIP.enabled = enabled!;
          });
        },
      ),
      KriolCheckTextField(
        iconP: Icons.edit,
        hintP: 'Source port',
        labelP: 'Set source port',
        helpP: 'Send probe packets from the chosen port when possible (--source-port)',
        controllerP: sourceScanControllers.sourcePort,
        enabledP: sourceScanControllers.sourcePort.enabled,
        onChangedP: (enabled, textValue) {
          setState(() {
            sourceScanControllers.sourcePort.enabled = enabled!;
          });
        },
      ),
      KriolCheckTextField(
        iconP: Icons.edit,
        hintP: 'Network Interface',
        labelP: 'Set network interface',
        helpP: 'Set the network interface to send packets out of, for example: eth0 (-e)',
        controllerP: sourceScanControllers.networkIF,
        enabledP: sourceScanControllers.networkIF.enabled,
        onChangedP: (enabled, textValue) {
          setState(() {
            sourceScanControllers.networkIF.enabled = enabled!;
          });
        },
      ),
    ]);
  }
}
