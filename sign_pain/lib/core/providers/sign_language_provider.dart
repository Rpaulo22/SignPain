import 'package:flutter/material.dart';

class SignLanguageProvider extends ChangeNotifier {
  // start with text mode by default
  bool _isSignLanguageMode = false;

  bool get isSignLanguageMode => _isSignLanguageMode;

  // toggles the current mode
  void toggleMode() {
    _isSignLanguageMode = !_isSignLanguageMode;
    
    // tells every screen listening to rebuild
    notifyListeners(); 
  }
}