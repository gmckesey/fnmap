import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_json_view/flutter_json_view.dart';
import 'package:fnmap/constants.dart';
import 'package:fnmap/models/host_record.dart';

class NMapDeviceDetails extends StatelessWidget {
  const NMapDeviceDetails({Key? key, required this.hostRecord})
      : super(key: key);
  final NMapHostRecord hostRecord;

  @override
  Widget build(BuildContext context) {
    Map<String, dynamic> map = hostRecord.map;
    Color backgroundColor = Theme.of(context).scaffoldBackgroundColor;
    TextStyle textStyle = kDetailsTextStyle.copyWith(
        color: Theme.of(context).primaryColor
    );
    TextStyle stringStyle = kDetailsTextStyle.copyWith(
        color: Theme.of(context).focusColor
    );
    JsonViewTheme theme = JsonViewTheme(
      defaultTextStyle: textStyle,
      backgroundColor: backgroundColor,
      keyStyle: kDetailsKeyStyle,
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
