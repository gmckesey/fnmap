import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_json_view/flutter_json_view.dart';
// import 'package:glog/glog.dart';
import 'package:nmap_gui/constants.dart';
import 'package:nmap_gui/models/host_record.dart';

class NMapDeviceDetails extends StatefulWidget {
  const NMapDeviceDetails({Key? key, required this.hostRecord})
      : super(key: key);
  final NMapHostRecord hostRecord;

  @override
  State<NMapDeviceDetails> createState() => _NMapDeviceDetailsState();
}

class _NMapDeviceDetailsState extends State<NMapDeviceDetails> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    /*GLog log = GLog('NMapDeviceDetails:',
        flag: gLogTRACE, package: kPackageName);*/
    Map<String, dynamic> map = widget.hostRecord.map;
    JsonViewTheme theme = JsonViewTheme(
      defaultTextStyle: kDetailsTextStyle,
      backgroundColor: kDetailsBackgroundColor,
      keyStyle: kDetailsKeyStyle,
      stringStyle: kDetailsStringStyle,
    );

    return Padding(
      padding: const EdgeInsets.all(10),
      child: SingleChildScrollView(
        child: JsonView.string(jsonEncode(map), theme: theme),
      ),
    );
  }
}
