import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:path/path.dart' as path;
import 'package:fnmap/utilities/logger.dart';
import 'package:fnmap/constants.dart';

showAbout(BuildContext context) async {
  NLog log = NLog(
    'showAbout:',
    flag: nLogTRACE,
    package: kPackageName,
  );

  Color backgroundColor = Theme.of(context).scaffoldBackgroundColor;
  File? iconFile;
  String? iconPath;
  bool iconExists = false;

  if (Platform.isLinux) {
    for (String iconDirectories in iconPaths) {
      List<String> iconElements = iconDirectories.split('/');
      iconPath = '';
      for (String element in iconElements) {
        iconPath = path.join(iconPath!, element);
      }

      iconFile = File(iconPath!);
      if (await iconFile.exists()) {
        log.debug('File $iconPath found!');
        iconExists = true;
      } else {
        log.debug('File $iconPath does not exist');
        iconExists = false;
        continue;
      }

      if (iconExists) {
        log.debug('File $iconPath found!');
        Widget image = Image.file(iconFile);
        if (context.mounted) {
          log.debug('context mounted');
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
        } else {
          log.warning('context is not mounted. No dialog shown');
        }
        break;
      } else {
        log.debug('File $iconPath does not exist');
      }
    }
  } else if (Platform.isWindows) {
    Widget image = Image.asset(kWindowsIconPath);
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
  }
}
