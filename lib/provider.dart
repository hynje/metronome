import 'package:flutter/material.dart';

class AppState with ChangeNotifier {
  double _bpm = 120;
  int _beat = 4;
  //double get bpm => _bpm;

  void setBpm(double newBpm) {
    _bpm = newBpm;
    notifyListeners();
  }

  double getBpm() {
    return _bpm;
  }

  void setBeat(int newBeat) {
    _beat = newBeat;
    notifyListeners();
  }

  int getBeat() {
    return _beat;
  }
}
