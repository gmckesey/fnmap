import 'package:fnmap/widgets/check_textfield.dart';
import 'package:flutter/material.dart';
import 'package:fnmap/controllers/edit_profile_controllers.dart';
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
            helpP:
                "Give up on host if scan is not complete in an amount of time\n"
                "NOTE: Time is in seconds by default, or may be followed by a suffix of 'ms' for milliseconds,\n"
                "'s' for seconds, 'm' for minutes, or 'h' for hours.(--host-timeout)",
            controllerP: timingScanControllers.hostTimeout,
            enabledP: timingScanControllers.hostTimeout.enabled,
            onChangedP: (enabled, textValue) {
              setState(() {
                timingScanControllers.hostTimeout.enabled = enabled!;
              });
            },
          ),
          KriolCheckTextField(
            iconP: Icons.edit,
            hintP: 'Initial probe timeout',
            labelP: 'Initial RTT Timeout',
            helpP: "The estimate of the round trip time on your network.\n"
                "NOTE: Time is in seconds by default, or may be followed by a suffix of 'ms' for milliseconds,\n"
                "'s' for seconds, 'm' for minutes, or 'h' for hours.(--initial-rtt-timeout)",
            controllerP: timingScanControllers.initialRTTTimeout,
            enabledP: timingScanControllers.initialRTTTimeout.enabled,
            onChangedP: (enabled, textValue) {
              setState(() {
                timingScanControllers.initialRTTTimeout.enabled = enabled!;
              });
            },
          ),
          KriolCheckTextField(
            iconP: Icons.edit,
            hintP: 'Maximum probe timeout',
            labelP: 'Max RTT Timeout',
            helpP: "Wait no more that this time before giving up or retransmitting.\n"
                "NOTE: Time is in seconds by default, or may be followed by a suffix of 'ms' for milliseconds,\n"
                "'s' for seconds, 'm' for minutes, or 'h' for hours.(--max-rtt-timeout)",
            controllerP: timingScanControllers.maxRTTTimeout,
            enabledP: timingScanControllers.maxRTTTimeout.enabled,
            onChangedP: (enabled, textValue) {
              setState(() {
                timingScanControllers.maxRTTTimeout.enabled = enabled!;
              });
            },
          ),
          KriolCheckTextField(
            iconP: Icons.edit,
            hintP: 'Minimum probe timeout',
            labelP: 'Min RTT Timeout',
            helpP: "Wait at least this time before giving up or retransmitting.\n"
                "NOTE: Time is in seconds by default, or may be followed by a suffix of 'ms' for milliseconds,\n"
                "'s' for seconds, 'm' for minutes, or 'h' for hours.(--min-rtt-timeout)",
            controllerP: timingScanControllers.minRTTTimeout,
            enabledP: timingScanControllers.minRTTTimeout.enabled,
            onChangedP: (enabled, textValue) {
              setState(() {
                timingScanControllers.minRTTTimeout.enabled = enabled!;
              });
            },
          ),
        ],
      ),
      Column(
        children: [
          KriolCheckTextField(
            iconP: Icons.edit,
            hintP: 'Maximum hosts in Parallel',
            labelP: 'Max host group',
            helpP: 'The maximum number of hosts to scan in parallel (--max-hostgroup)',
            controllerP: timingScanControllers.maxHostGroup,
            enabledP: timingScanControllers.maxHostGroup.enabled,
            onChangedP: (enabled, textValue) {
              setState(() {
                timingScanControllers.maxHostGroup.enabled = enabled!;
              });
            },
          ),
          KriolCheckTextField(
            iconP: Icons.edit,
            hintP: 'Minimum hosts in parallel',
            labelP: 'Min host group',
            helpP: 'The minimum number of hosts to scan in parallel (--min-hostgroup)',
            controllerP: timingScanControllers.minHostGroup,
            enabledP: timingScanControllers.minHostGroup.enabled,
            onChangedP: (enabled, textValue) {
              setState(() {
                timingScanControllers.minHostGroup.enabled = enabled!;
              });
            },
          ),
          KriolCheckTextField(
            iconP: Icons.edit,
            hintP: 'Maximum outstanding probes',
            labelP: 'Max parallelism',
            helpP: 'The maximum number of probes allowed to be outstanding (-max-parallelism)',
            controllerP: timingScanControllers.maxParallel,
            enabledP: timingScanControllers.maxParallel.enabled,
            onChangedP: (enabled, textValue) {
              setState(() {
                timingScanControllers.maxParallel.enabled = enabled!;
              });
            },
          ),
          KriolCheckTextField(
            iconP: Icons.edit,
            hintP: 'Minimum outstanding probes',
            labelP: 'Min parallelism',
            helpP: 'The minimum number of probes that nmap will try to have outstanding (-min-parallelism)',
            controllerP: timingScanControllers.minParallel,
            enabledP: timingScanControllers.minParallel.enabled,
            onChangedP: (enabled, textValue) {
              setState(() {
                timingScanControllers.minParallel.enabled = enabled!;
              });
            },
          ),
        ],
      ),
      Column(
        children: [
          KriolCheckTextField(
            iconP: Icons.edit,
            hintP: 'Maximum scan delay',
            labelP: 'Max scan delay',
            helpP: "The maximum delay between successive probes.\n"
                "NOTE: Time is in seconds by default, or may be followed by a suffix of 'ms' for milliseconds,\n"
                "'s' for seconds, 'm' for minutes, or 'h' for hours.(--min-rtt-timeout)",
            controllerP: timingScanControllers.maxScanDelay,
            enabledP: timingScanControllers.maxScanDelay.enabled,
            onChangedP: (enabled, textValue) {
              setState(() {
                timingScanControllers.maxScanDelay.enabled = enabled!;
              });
            },
          ),
          KriolCheckTextField(
            iconP: Icons.edit,
            hintP: 'Minimum scan delay',
            labelP: 'Min scan delay',
            helpP: "Wait at least this time before successive probes.\n"
                "NOTE: Time is in seconds by default, or may be followed by a suffix of 'ms' for milliseconds,\n"
                "'s' for seconds, 'm' for minutes, or 'h' for hours.(--min-rtt-timeout)",
            controllerP: timingScanControllers.minScanDelay,
            enabledP: timingScanControllers.minScanDelay.enabled,
            onChangedP: (enabled, textValue) {
              setState(() {
                timingScanControllers.minScanDelay.enabled = enabled!;
              });
            },
          ),
        ],
      )
    ]);
  }
}
