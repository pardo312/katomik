import 'package:flutter/foundation.dart';

class NavigationProvider extends ChangeNotifier {
  bool _showHomeFab = true;

  bool get showHomeFab => _showHomeFab;

  void hideHomeFab() {
    if (_showHomeFab) {
      _showHomeFab = false;
      notifyListeners();
    }
  }

  void showHomeFabIfNeeded() {
    if (!_showHomeFab) {
      _showHomeFab = true;
      notifyListeners();
    }
  }
}