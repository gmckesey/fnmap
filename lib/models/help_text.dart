import 'package:flutter/material.dart';

class HelpText with ChangeNotifier {
  String _helpText = "";

  set text(String value) {
    _helpText = value;
    notifyListeners();
  }

  String get text => _helpText;
}