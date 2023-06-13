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

  if (Platform.isWindows || Platform.isLinux) {
    Widget image = Image.asset(kIconPath);
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
