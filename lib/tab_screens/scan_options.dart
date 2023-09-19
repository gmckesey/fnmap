import 'package:fnmap/widgets/check_textfield.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:fnmap/widgets/text_field.dart';
import 'package:fnmap/widgets/dropdown_string.dart';
import 'package:fnmap/widgets/checkbox.dart';
import 'package:fnmap/models/edit_profile_controllers.dart';
import 'package:fnmap/models/dark_mode.dart';
import 'package:fnmap/utilities/logger.dart';

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
    Color textColor = mode.themeData.primaryColorLight;
    Color focusColor = mode.themeData.focusColor;
    Color dropDownColor = mode.themeData.primaryColorLight;
    Color darkColor = mode.themeData.primaryColorDark;
    EditScanControllers scanControllers = widget.scanControllers;

    NLog log = NLog('ScanOptions:');

    return Column(children: [
      Row(
        children: [
          KriolTextField(
            iconP: Icons.edit,
            hintP: 'Targets (optional)',
            labelP: 'Targets:',
            controllerP: scanControllers.targetController,
          ),
          const SizedBox(width: 8),
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
              }),
          const SizedBox(width: 8),
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
              }),
        ],
      ),
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          children: [
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
                }),
            const SizedBox(width: 8),
            KriolCheckBox(
                initialValue: scanControllers.enableAdvAgr!,
                title: 'Enable All Aggressive Options',
                onChanged: (bool? value) {
                  setState(() {
                    scanControllers.ipv6Support = value!;
                    log.debug(
                        'KriolCheckBox:onChanged -  aggressive option value = $value');
                  });
                }),
            const SizedBox(width: 8),
            KriolCheckBox(
                initialValue: scanControllers.osDetection!,
                title: 'Operating System Detection',
                onChanged: (bool? value) {
                  setState(() {
                    scanControllers.osDetection = value!;
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
        controllerP: scanControllers.idleScan.controller,
        enabledP: scanControllers.idleScan.enabled!,
      ),
      KriolCheckTextField(
        iconP: Icons.edit,
        hintP: 'FTP Bounce Attack',
        labelP: 'FTP Bounce Attack:',
        controllerP: scanControllers.ftpBounce.controller,
        enabledP: scanControllers.ftpBounce.enabled!,
      ),
      Row(
        children: [
          KriolCheckBox(
              initialValue: scanControllers.versionDetection!,
              title: 'Version Detection',
              onChanged: (bool? value) {
                setState(() {
                  scanControllers.versionDetection = value!;
                  log.debug(
                      'Checkbox:onChanged -  Version Detection value = $value');
                });
              }),
          KriolCheckBox(
              initialValue: scanControllers.disableDNSDetection!,
              title: 'Disable DNS Resolution',
              onChanged: (bool? value) {
                setState(() {
                  scanControllers.ipv6Support = value!;
                  log.debug('Checkbox:onChanged -  Disable DNS value = $value');
                });
              }),
          KriolCheckBox(
              initialValue: scanControllers.ipv6Support!,
              title: 'IPv6 Support',
              onChanged: (bool? value) {
                setState(() {
                  scanControllers.ipv6Support = value!;
                  log.debug(
                      'Checkbox:onChanged -  IPv6 support value = $value');
                });
              }),
        ],
      )
    ]);
  }
}
