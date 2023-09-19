import 'dart:math';

import 'package:args/args.dart';
import 'package:fnmap/widgets/check_textfield.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:fnmap/widgets/text_field.dart';
import 'package:fnmap/widgets/dropdown_string.dart';
import 'package:fnmap/widgets/checkbox.dart';
import 'package:fnmap/models/edit_profile_controllers.dart';
import 'package:fnmap/models/dark_mode.dart';
import 'package:fnmap/models/nmap_command.dart';
import 'package:fnmap/utilities/logger.dart';

class PingOptions extends StatefulWidget {
  final PingScanControllers pingControllers;
  const PingOptions({
    super.key,
    required this.pingControllers,
  });

  @override
  State<PingOptions> createState() => _PingOptionsState();
}

class _PingOptionsState extends State<PingOptions> {
  NLog log = NLog('_PingOptionsState:');
  late PingScanControllers pingControllers;

  @override void initState() {
    super.initState();
    pingControllers = widget.pingControllers;
  }

  @override
  Widget build(BuildContext context) {

    return Column(children: [
      const SizedBox(height: 8),
      Row(children: [
        KriolCheckBox(
          initialValue: pingControllers.pingBeforeScan!,
          title: 'Don\'t ping before scan',
          onChanged: (value) {
            setState(() {
              pingControllers.pingBeforeScan = value!;
              log.debug(
                  'KriolCheckBox:onChanged - Ping Before Scan value = $value');
            });
          },
        ),
        const SizedBox(width: 8),
        KriolCheckBox(
          initialValue: pingControllers.ICMPPing!,
          title: 'ICMP Ping',
          onChanged: (value) {
            setState(() {
              pingControllers.ICMPPing = value!;
              log.debug(
                  'KriolCheckBox:onChanged - ICMP Ping = $value');
            });
          },
        ),
        const SizedBox(width: 8),
        KriolCheckBox(
          initialValue: pingControllers.ICMPTimeStamp!,
          title: 'ICMP Timestamp Request',
          onChanged: (value) {
            setState(() {
              pingControllers.ICMPTimeStamp = value!;
              log.debug(
                  'KriolCheckBox:onChanged - ICMP Timestamp = $value');
            });
          },
        ),
        const SizedBox(width: 8),
        KriolCheckBox(
          initialValue: pingControllers.ICMPNetmask!,
          title: 'ICMP Netmask Request',
          onChanged: (value) {
            setState(() {
              pingControllers.ICMPNetmask = value!;
              log.debug(
                  'KriolCheckBox:onChanged - ICMP Netmask = $value');
            });
          },
        ),
      ]),
      const SizedBox(height: 8,),
      Row(
        children: [
          KriolCheckTextField(
            iconP: Icons.edit,
            hintP: 'ACK Ping Ports',
            labelP: 'ACK TCP Ports',
            controllerP: pingControllers.ackPing.controller,
            enabledP: pingControllers.ackPing.enabled!,
          ),
          const SizedBox(width: 8),
          KriolCheckTextField(
            iconP: Icons.edit,
            hintP: 'SYN Ping Ports',
            labelP: 'SYN TCP Ports',
            controllerP: pingControllers.synPing.controller,
            enabledP: pingControllers.synPing.enabled!,
          ),
          //   TextOption(controllerP: controllerP, enabledP: enabledP, titleP: titleP)
        ],
      ),
      Row(
        children: [
          KriolCheckTextField(
            iconP: Icons.edit,
            hintP: 'UDP Ping Ports',
            labelP: 'UDP Ping Ports',
            controllerP: pingControllers.udpPing.controller,
            enabledP: pingControllers.udpPing.enabled!,
          ),
          //   TextOption(controllerP: controllerP, enabledP: enabledP, titleP: titleP)
        ],
      ),
      Row(
        children: [
          KriolCheckTextField(
            iconP: Icons.edit,
            hintP: 'IP Protocols',
            labelP: 'IP Protocols',
            controllerP: pingControllers.ipProto.controller,
            enabledP: pingControllers.ipProto.enabled!,
          ),
          //   TextOption(controllerP: controllerP, enabledP: enabledP, titleP: titleP)
        ],
      ),
    ]);
  }
}
