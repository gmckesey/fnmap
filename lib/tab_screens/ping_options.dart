import 'package:fnmap/widgets/check_textfield.dart';
import 'package:flutter/material.dart';
import 'package:fnmap/widgets/checkbox.dart';
import 'package:fnmap/controllers/edit_profile_controllers.dart';
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

  @override
  void initState() {
    super.initState();
    pingControllers = widget.pingControllers;
  }
  // TODO: Add validation to form fields and potentially adjust widget sizing
  @override
  Widget build(BuildContext context) {
    return Column(children: [
      const SizedBox(height: 8),
      Row(children: [
        KriolCheckBox(
          initialValue: pingControllers.pingBeforeScan!.isSet,
          title: 'Don\'t ping before scan',
          help: 'Don\'t check if targets are up before scanning',
          onChanged: (value) {
            setState(() {
              pingControllers.pingBeforeScan!(value!);
              log.debug(
                  'KriolCheckBox:onChanged - Ping Before Scan value = $value');
            });
          },
        ),
        const SizedBox(width: 8),
        KriolCheckBox(
          initialValue: pingControllers.vICMPPing!.isSet,
          title: 'ICMP Ping',
          help:
              'Send a ping (ICMP echo) to targets to determine if they are up (-PE)',
          onChanged: (value) {
            setState(() {
              pingControllers.vICMPPing!(value!);
              log.debug('KriolCheckBox:onChanged - ICMP Ping = $value');
            });
          },
        ),
        const SizedBox(width: 8),
        KriolCheckBox(
          initialValue: pingControllers.vICMPTimeStamp!.isSet,
          title: 'ICMP Timestamp Request',
          help:
              'Send an ICMP timestamp request to targets to determine if they are up (-PP)',
          onChanged: (value) {
            setState(() {
              pingControllers.vICMPTimeStamp!(value!);
              log.debug('KriolCheckBox:onChanged - ICMP Timestamp = $value');
            });
          },
        ),
        const SizedBox(width: 8),
        KriolCheckBox(
          initialValue: pingControllers.vICMPNetmask!.isSet,
          title: 'ICMP Netmask Request',
          help:
              'Send an ICMP netmask request to targets to determine if they are up (-PP)',
          onChanged: (value) {
            setState(() {
              pingControllers.vICMPNetmask!(value!);
              log.debug('KriolCheckBox:onChanged - ICMP Netmask = $value');
            });
          },
        ),
      ]),
      const SizedBox(
        height: 8,
      ),
      Row(
        children: [
          KriolCheckBox(
              initialValue: pingControllers.arpPing!.isSet,
              title: 'Enable ARP Ping',
              help:
                  'Use nmap optimized arp for target checking on local network (-PR)',
              onChanged: (bool? value) {
                setState(() {
                  pingControllers.arpPing!(value!);
                  log.debug(
                      'KriolCheckBox:onChanged -  enable arp ping = $value');
                });
              }),
          const SizedBox(width: 8),
          KriolCheckBox(
              initialValue: pingControllers.noArpPing!.isSet,
              title: 'Disable ARP Ping',
              help:
                  'Do not use arp to or IPv6 neighbor discovery for host discovery on local networks.\n'
                  'Useful if routers use proxy-arp (--disable-arp-ping)',
              onChanged: (bool? value) {
                setState(() {
                  pingControllers.noArpPing!(value!);
                  log.debug(
                      'KriolCheckBox:onChanged -  disable arp ping = $value');
                });
              }),
          const SizedBox(width: 8),
          KriolCheckBox(
              initialValue: pingControllers.noHostDiscovery!.isSet,
              title: 'Skip host discovery',
              help:
                  'Do not attempt to discover hosts using ping before scanning (-Pn)',
              onChanged: (bool? value) {
                setState(() {
                  pingControllers.noHostDiscovery!(value!);
                  log.debug(
                      'KriolCheckBox:onChanged -  skip host discovery = $value');
                });
              }),
        ],
      ),
      const SizedBox(
        height: 8,
      ),
      Row(
        children: [
          KriolCheckTextField(
            iconP: Icons.edit,
            hintP: 'ACK Ping Ports',
            labelP: 'ACK TCP Ports',
            helpP:
                'Send ACK probes from comma separated list of ports to see if targets are up (-PA)',
            controllerP: pingControllers.ackPing,
            enabledP: pingControllers.ackPing.enabled,
            onChangedP: (enabled, textValue) {
              setState(() {
                pingControllers.ackPing.enabled = enabled!;
              });
            },
          ),
          const SizedBox(width: 8),
          KriolCheckTextField(
            iconP: Icons.edit,
            hintP: 'SYN Ping Ports',
            labelP: 'SYN TCP Ports',
            helpP:
                'Send SYN probes from comma separated list of ports to see if targets are up (-PS)',
            controllerP: pingControllers.synPing,
            enabledP: pingControllers.synPing.enabled,
            onChangedP: (enabled, textValue) {
              setState(() {
                pingControllers.synPing.enabled = enabled!;
              });
            },
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
            helpP:
                'Send UDP probes from comma separated list of ports to see if targets are up (-PU)',
            controllerP: pingControllers.udpPing,
            enabledP: pingControllers.udpPing.enabled,
            onChangedP: (enabled, textValue) {
              setState(() {
                pingControllers.udpPing.enabled = enabled!;
              });
            },
          ),
          //   TextOption(controllerP: controllerP, enabledP: enabledP, titleP: titleP)
          const SizedBox(width: 8),
          KriolCheckTextField(
            iconP: Icons.edit,
            hintP: 'IP Protocols',
            labelP: 'IP Protocols',
            helpP:
                'Send raw IP protocol probes from comma separated list of ports to see if targets are up (-PO)',
            controllerP: pingControllers.ipProto,
            enabledP: pingControllers.ipProto.enabled,
            onChangedP: (enabled, textValue) {
              setState(() {
                pingControllers.ipProto.enabled = enabled!;
              });
            },
          ),
          //   TextOption(controllerP: controllerP, enabledP: enabledP, titleP: titleP)
        ],
      ),
      Row(children: [
        KriolCheckTextField(
          iconP: Icons.edit,
          hintP: 'TCP ports',
          labelP: 'SCTP Init',
          helpP:
              'Send SCTP INIT chunk packets from comma separated list of ports to see if targets are up (-PY)',
          controllerP: pingControllers.sctpInitPing,
          enabledP: pingControllers.sctpInitPing.enabled,
          onChangedP: (enabled, textValue) {
            setState(() {
              pingControllers.sctpInitPing.enabled = enabled!;
            });
          },
        ),
      ])
    ]);
  }
}
