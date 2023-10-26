import 'package:flutter/material.dart';
import 'package:fnmap/utilities/logger.dart';

class KriolTextFieldController with ChangeNotifier {
  TextEditingController textController = TextEditingController();
  bool? _enabled;
  bool? isValid;
  NLog log = NLog('KriolTextFieldController', package: 'Kriol Widgets');

  set text(String? txt) {
    if (txt != null) {
      textController.text = txt;
      _enabled = true;
    } else {
      textController.text = '';
      _enabled = false;
    }
    notifyListeners();
    log.debug('value changed to enabled=$enabled text = $txt');
  }

  set enabled(bool b) {
    _enabled = b;
  }

  bool get enabled => _enabled != null ? _enabled! : false;
  String? get text => !enabled ? null : textController.text;

  notify() {
    notifyListeners();
  }
}