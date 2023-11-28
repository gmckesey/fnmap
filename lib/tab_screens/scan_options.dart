import 'package:fnmap/widgets/check_textfield.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:fnmap/controllers/edit_profile_controllers.dart';
import 'package:fnmap/models/dark_mode.dart';
import 'package:fnmap/utilities/logger.dart';
import 'package:fnmap/utilities/ip_address_validator.dart';
import 'package:fnmap/widgets/help.dart';
import 'package:fnmap/widgets/dropdown_string.dart';
import 'package:fnmap/widgets/checkbox.dart';

class ScanOptions extends StatefulWidget {
  final EditScanControllers scanControllers;

  const ScanOptions({
    super.key,
    required this.scanControllers,
  });

  @override
  State<ScanOptions> createState() => _ScanOptionsState();
}

class _ScanOptionsState extends State<ScanOptions> {


  @override
  Widget build(BuildContext context) {
    NMapDarkMode mode = Provider.of<NMapDarkMode>(context, listen: true);
    // Color textColor = theme.textTheme.labelMedium != null ? mode.themeData.textTheme.labelMedium!.color! : theme.primaryColorLight;
    Color textColor = mode.themeData.primaryColorLight;
    Color focusColor = mode.themeData.focusColor;
    Color dropDownColor = mode.themeData.primaryColorLight;
    Color darkColor = mode.themeData.primaryColorDark;
    EditScanControllers scanControllers = widget.scanControllers;

    NLog log = NLog('ScanOptions:');

    return Column(children: [
      Row(
        children: [
          KriolCheckTextField(
            helpP: 'The target IP addresses or host to scan',
            iconP: Icons.edit,
            validatorP: (value) {
              if (!isValidIPAddress(value!)) {
                scanControllers.target.isValid = false;
                return ('Target field not valid IP or FQDN');
              }
              scanControllers.target.isValid = true;
              return null;
            },
            hintP: 'Targets (optional)',
            labelP: 'Targets:',
            controllerP: scanControllers.target,
            enabledP: scanControllers.target.enabled,
            onChangedP: (enabled, textValue) {
              setState(() {
                scanControllers.target.enabled = enabled!;
/*                if (textValue == null || textValue == '') {
                  scanControllers.target.text = null;
                } else if (textValue != null) {
                  scanControllers.target.text = textValue;
                }*/
              });
            },
          ),
          const SizedBox(width: 8),
          KriolHelp(
            help: 'Choose the scan technique for TCP ports\n'
                '(-sA,-sF,-sM,-sN,-sS,-sT,-sW,-sY)',
            child: Row(children: [
              Text(
                'TCP Scan option:',
                style: TextStyle(color: textColor),
              ),
              const SizedBox(width: 8),
              KriolDropdownStringField(
                  controller: scanControllers.tcpScanController,
                  textStyle: TextStyle(color: darkColor),
                  dropDownColor: dropDownColor,
                  focusColor: focusColor,
                  onChanged: (value) {
                    log.debug('onChanged: tcpScan value selected = $value');
                    scanControllers.tcpScanOption!.text = value;
                  }),
              const SizedBox(width: 8),
            ]),
          ),
          KriolHelp(
              help: 'Choose the scan technique for non tcp ports or protocols\n'
                  '(-sU,-sO,-sL,-su,-sY,-sZ)',
              child: Row(children: [
                Text(
                  'Other Scan option:',
                  style: TextStyle(color: textColor),
                ),
                const SizedBox(width: 8),
                KriolDropdownStringField(
                    width: 160,
                    controller: scanControllers.otherScanController,
                    textStyle: TextStyle(color: darkColor),
                    dropDownColor: dropDownColor,
                    focusColor: focusColor,
                    onChanged: (value) {
                      log.debug('onChanged: otherScan value selected = $value');
                      scanControllers.otherScanOption!.text = value;
                    }),
              ])),
        ],
      ),
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          children: [
            KriolHelp(
              help:
                  'Define how fast the scan should run as a tradeoff to the accuracy of the scan\n'
                  '(-Tn n>=0, n<=5)',
              child: Row(children: [
                Text(
                  'Timing Templates:',
                  style: TextStyle(color: textColor),
                ),
                const SizedBox(width: 8),
                KriolDropdownStringField(
                    width: 180,
                    controller: scanControllers.timingTemplateController,
                    textStyle: TextStyle(color: darkColor),
                    dropDownColor: dropDownColor,
                    focusColor: focusColor,
                    onChanged: (value) {
                      log.debug(
                          'KriolDropdownStringField:onChanged - timing value selected = $value');
                      scanControllers.timingScanOption!.text = value;
                    }),
              ]),
            ),
            const SizedBox(width: 8),
            KriolCheckBox(
                initialValue: scanControllers.enableAdvAgr!.isSet,
                title: 'Enable All Aggressive Options',
                help: 'Enable all advanced aggressive options (-A)',
                onChanged: (bool? value) {
                  setState(() {
                    scanControllers.enableAdvAgr!(value!);
                    log.debug(
                        'KriolCheckBox:onChanged -  aggressive option value = $value');
                  });
                }),
            const SizedBox(width: 8),
            KriolCheckBox(
                initialValue: scanControllers.osDetection!.isSet,
                title: 'Operating System Detection',
                help:
                    'Try to discover the OS running on the system(s) being scanned (-O)',
                onChanged: (bool? value) {
                  setState(() {
                    scanControllers.osDetection!(value!);
                    log.debug(
                        'KriolCheckBox:onChanged -  OS Detection value = $value');
                  });
                }),
          ],
        ),
      ),
      KriolCheckTextField(
        iconP: Icons.edit,
        hintP: 'Idle Scan',
        labelP: 'Idle Scan:',
        helpP: 'IP or host of host to spoof (-sl)',
        controllerP: scanControllers.idleScan,
        enabledP: scanControllers.idleScan.enabled,
        onChangedP: (enabled, fieldValue) {
          setState(() {
            scanControllers.idleScan.enabled = enabled!;
          });
        },
        validatorP: (v) {
          if (!scanControllers.idleScan.enabled) {
            return null;
          }
          String value = v!;
          if (!isValidIPAddress(value)) {
/*
          if (!isHostname(value) &&
              !valid.isIP(value) &&
              !valid.isFQDN(value)) {
*/
            scanControllers.idleScan.isValid = false;
            log.debug('validator: value $value is not valid');
            return 'Invalid IP or hostname';
          }
          scanControllers.idleScan.isValid = true;
          log.debug('validator: value $value is valid');
          return null;
        },
      ),
      KriolCheckTextField(
        iconP: Icons.edit,
        hintP: 'FTP Bounce Attack',
        labelP: 'FTP Bounce Attack:',
        helpP:
            'FTP server to port scan other host, use: username:password@server:port '
            '(-b)',
        controllerP: scanControllers.ftpBounce,
        enabledP: scanControllers.ftpBounce.enabled,
        validatorP: (v) {
          if (!scanControllers.ftpBounce.enabled) {
            return null;
          }
          String value = v!;
          if (!isValidIPAddress(value)) {
/*          if (!isHostname(value) &&
              !valid.isIP(value) &&
              !valid.isFQDN(value)) { */
            scanControllers.ftpBounce.isValid = false;
            return 'Invalid IP or hostname';
          }
          scanControllers.ftpBounce.isValid = true;
          return null;
        },
        onChangedP: (enabled, fieldValue) {
          setState(() {
            scanControllers.ftpBounce.enabled = enabled!;
          });
        },
      ),
      Row(
        children: [
          KriolCheckBox(
              initialValue: scanControllers.versionDetection!.isSet,
              title: 'Version Detection',
              help: 'Attempt to find version number of detected services (-sV)',
              onChanged: (bool? value) {
                setState(() {
                  scanControllers.versionDetection!(value!);
                  log.debug(
                      'Checkbox:onChanged -  Version Detection value = $value');
                });
              }),
          KriolCheckBox(
              initialValue: scanControllers.disableDNSDetection!.isSet,
              title: 'Disable DNS Resolution',
              help: 'Disable reverse DNS resolution which improves performance (-n)',
              onChanged: (bool? value) {
                setState(() {
                  scanControllers.disableDNSDetection!(value!);
                  log.debug('Checkbox:onChanged -  Disable DNS value = $value');
                });
              }),
          KriolCheckBox(
              initialValue: scanControllers.ipv6Support!.isSet,
              help: 'Enable IPv6 scanning (-6)',
              title: 'IPv6 Support',
              onChanged: (bool? value) {
                setState(() {
                  scanControllers.ipv6Support!(value!);
                  log.debug(
                      'Checkbox:onChanged -  IPv6 support value = $value');
                });
              }),
        ],
      )
    ]);
  }
}
