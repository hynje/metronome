import 'package:flutter/material.dart';

class AppState with ChangeNotifier {
  double _bpm = 120;
  //double get bpm => _bpm;

  void setBpm(double newBpm) {
    _bpm = newBpm;
    notifyListeners();
    print(_bpm);
  }

  double getBpm() {
    return _bpm;
  }
}
