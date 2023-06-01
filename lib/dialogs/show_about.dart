import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:fnmap/utilities/logger.dart';
import 'package:fnmap/constants.dart';

showAbout(BuildContext context) async {
  NLog log = NLog(
    'showLicense:',
    flag: nLogTRACE,
    package: kPackageName,
  );

  Color backgroundColor = Theme.of(context).scaffoldBackgroundColor;
  File? gplFile;
  File? iconFile;
  bool gplExists = false;
  bool iconExists = false;
  String? gplPath;
  String? iconPath;

  if (Platform.isLinux) {
    for (gplPath in kLinuxGPLPaths) {
      gplFile = File(gplPath);
      if (await gplFile.exists()) {
        log.debug('File $gplPath found!');
        gplExists = true;
        break;
      } else {
        log.debug('File $gplPath does not exist');
      }
    }

    for (iconPath in iconPaths) {
      iconFile = File(iconPath);
      if (await iconFile.exists()) {
        log.debug('File $iconPath found!');
        iconExists = true;
        break;
      } else {
        log.debug('File $iconPath does not exist');
      }
    }
  }

  if (gplFile != null) {
    gplFile.readAsString().then((contents) {
      Widget? image = iconExists ? Image.file(iconFile!) : null;
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AboutDialog(
              applicationName: kProgramName,
              applicationVersion: kAppVersion,
              applicationLegalese: 'Copyright © 2023 - Gregory McKesey',
              applicationIcon: image,
            );
          });
    });
  }
}
