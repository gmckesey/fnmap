import 'dart:convert';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_json_view/flutter_json_view.dart';
import 'package:fnmap/constants.dart';
import 'package:fnmap/models/host_record.dart';
import 'package:fnmap/models/dark_mode.dart';

class NMapDeviceDetails extends StatelessWidget {
  const NMapDeviceDetails({Key? key, required this.hostRecord})
      : super(key: key);
  final NMapHostRecord hostRecord;

  @override
  Widget build(BuildContext context) {
    Map<String, dynamic> map = hostRecord.map;
    ThemeData mode = Provider.of<NMapDarkMode>(context, listen: true).themeData;
    // ThemeData mode = Theme.of(context);
    Color backgroundColor = mode.dialogBackgroundColor; //mode.scaffoldBackgroundColor;
    TextStyle textStyle = kDetailsTextStyle.copyWith(
        //color: Theme.of(context).primaryColor
      color: mode.primaryColor,
    );
    TextStyle stringStyle = kDetailsTextStyle.copyWith(
        // color: Theme.of(context).focusColor
      color: mode.secondaryHeaderColor.withOpacity(0.75),
    );

    TextStyle keyStyle = kDetailsTextStyle.copyWith(
      color: mode.secondaryHeaderColor,
    );

    JsonViewTheme theme = JsonViewTheme(
      defaultTextStyle: textStyle,
      backgroundColor: backgroundColor,
      keyStyle: keyStyle,
      stringStyle: stringStyle,
    );

    return Padding(
      padding: const EdgeInsets.all(10),
      child: SingleChildScrollView(
        child: JsonView.string(jsonEncode(map), theme: theme),
      ),
    );
  }
}
