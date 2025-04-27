import 'dart:io';
import 'package:provider/provider.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:fnmap/constants.dart';
import 'package:fnmap/models/dark_mode.dart';

showAbout(BuildContext context, {PackageInfo? packageInfo}) async {
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    Widget image = Image.asset(kIconPath);
    showDialog(
        context: context,
        builder: (BuildContext context) {
          NMapDarkMode mode = Provider.of<NMapDarkMode>(context, listen: false);
          return Theme(
            data: mode.themeData,
            child: AboutDialog(
              applicationName:
                  packageInfo != null ? packageInfo.appName : kProgramName,
              applicationVersion:
                  packageInfo != null ? packageInfo.version : kAppVersion,
              applicationLegalese: 'Copyright © 2025 - Kriol Technologies',
              applicationIcon: image,
              children: const [
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Padding(
                    padding: EdgeInsets.only(right: 16.0),
                    child: Text('email: krioltech@gmail.com'),
                  ),
                ]),
              ],
            ),
          );
        });
  }
}
