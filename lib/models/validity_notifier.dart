import 'package:flutter/foundation.dart';

class ValidityNotifier extends ChangeNotifier {
  bool _isValid = true;
  bool _hasChanged = false;

  bool get isValid => _isValid;

  bool get hasChanged => _hasChanged;

  void setValidity(bool isValid) {
    _hasChanged = _isValid == isValid ? false : true;
    _isValid=isValid;
    if (_hasChanged) {
      notifyListeners();
    }
  }
}
