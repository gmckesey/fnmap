import 'dart:io';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:fnmap/constants.dart';

showAbout(BuildContext context, {PackageInfo? packageInfo}) async {
  if (Platform.isWindows || Platform.isLinux) {
    Widget image = Image.asset(kIconPath);
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AboutDialog(
            applicationName:
                packageInfo != null ? packageInfo.appName : kProgramName,
            applicationVersion:
                packageInfo != null ? packageInfo.version : kAppVersion,
            applicationLegalese: 'Copyright © 2023 - Kriol Technologies',
            applicationIcon: image,
          );
        });
  }
}
