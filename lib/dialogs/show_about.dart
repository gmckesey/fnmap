import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fnmap/constants.dart';

showAbout(BuildContext context) async {
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
