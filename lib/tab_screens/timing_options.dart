import 'package:fnmap/widgets/check_textfield.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:fnmap/widgets/text_field.dart';
import 'package:fnmap/widgets/dropdown_string.dart';
import 'package:fnmap/widgets/checkbox.dart';
import 'package:fnmap/models/edit_profile_controllers.dart';
import 'package:fnmap/models/dark_mode.dart';
import 'package:fnmap/utilities/logger.dart';

class TimingOptions extends StatefulWidget {
  final TimingScanControllers timingScanControllers;
  const TimingOptions({
    super.key,
    required this.timingScanControllers,
  });

  @override
  State<TimingOptions> createState() => _TimingOptionsState();
}

class _TimingOptionsState extends State<TimingOptions> {
  NLog log = NLog('_OtherOptionsState');
  late TimingScanControllers timingScanControllers;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    timingScanControllers = widget.timingScanControllers;
  }

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Column(
        children: [
          KriolCheckTextField(
            iconP: Icons.edit,
            hintP: 'Max time to scan a target',
            labelP: 'Host timeout',
            controllerP: timingScanControllers.hostTimeout.controller,
            enabledP: timingScanControllers.hostTimeout.enabled!,
          ),
          KriolCheckTextField(
            iconP: Icons.edit,
            hintP: 'Initial probe timeout',
            labelP: 'Initial RTT Timeout',
            controllerP: timingScanControllers.initialRTTTimeout.controller,
            enabledP: timingScanControllers.initialRTTTimeout.enabled!,
          ),
          KriolCheckTextField(
            iconP: Icons.edit,
            hintP: 'Maximum probe timeout',
            labelP: 'Max RTT Timeout',
            controllerP: timingScanControllers.maxRTTTimeout.controller,
            enabledP: timingScanControllers.maxRTTTimeout.enabled!,
          ),
          KriolCheckTextField(
            iconP: Icons.edit,
            hintP: 'Minimum probe timeout',
            labelP: 'Min RTT Timeout',
            controllerP: timingScanControllers.minRTTTimeout.controller,
            enabledP: timingScanControllers.minRTTTimeout.enabled!,
          ),
        ],
      ),
      Column(
        children: [
          KriolCheckTextField(
            iconP: Icons.edit,
            hintP: 'Maximum hosts in Parallel',
            labelP: 'Max host group',
            controllerP: timingScanControllers.maxHostGroup.controller,
            enabledP: timingScanControllers.maxHostGroup.enabled!,
          ),
          KriolCheckTextField(
            iconP: Icons.edit,
            hintP: 'Minimum hosts in parallel',
            labelP: 'Min host group',
            controllerP: timingScanControllers.minHostGroup.controller,
            enabledP: timingScanControllers.minHostGroup.enabled!,
          ),
          KriolCheckTextField(
            iconP: Icons.edit,
            hintP: 'Maximum outstanding probes',
            labelP: 'Max parallelism',
            controllerP: timingScanControllers.maxParallel.controller,
            enabledP: timingScanControllers.maxParallel.enabled!,
          ),
          KriolCheckTextField(
            iconP: Icons.edit,
            hintP: 'Minimum outstanding probes',
            labelP: 'Min parallelism',
            controllerP: timingScanControllers.minParallel.controller,
            enabledP: timingScanControllers.minParallel.enabled!,
          ),
        ],
      ),
      Column(
        children: [
          KriolCheckTextField(
            iconP: Icons.edit,
            hintP: 'Maximum scan delay',
            labelP: 'Max scan delay',
            controllerP: timingScanControllers.maxScanDelay.controller,
            enabledP: timingScanControllers.maxScanDelay.enabled!,
          ),
          KriolCheckTextField(
            iconP: Icons.edit,
            hintP: 'Minimum scan delay',
            labelP: 'Min scan delay',
            controllerP: timingScanControllers.minScanDelay.controller,
            enabledP: timingScanControllers.minScanDelay.enabled!,
          ),
        ],
      )
    ]);
  }
}
