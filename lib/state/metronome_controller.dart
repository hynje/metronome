import 'package:flutter/foundation.dart';

import '../models/song.dart';
import '../services/click_player.dart';
import '../services/metronome_engine.dart';

/// 메트로놈 상태(BPM, 박자, 재생 여부, 현재 박)를 한 곳에서 관리한다.
class MetronomeController extends ChangeNotifier {
  MetronomeController({required ClickPlayer clickPlayer})
      : _clickPlayer = clickPlayer {
    _engine = MetronomeEngine(onTick: _onTick);
    _clickPlayer.init();
  }

  final ClickPlayer _clickPlayer;
  late final MetronomeEngine _engine;

  int _bpm = kDefaultBpm;
  int _beat = kDefaultBeat;
  int _currentBeat = 0;

  int get bpm => _bpm;
  int get beat => _beat;
  bool get isPlaying => _engine.isRunning;

  /// 지금 울린 박(1부터 시작). 정지 상태면 0.
  int get currentBeat => _currentBeat;

  void setBpm(int value) {
    final next = clampBpm(value);
    if (next == _bpm) return;
    _bpm = next;
    _engine.updateBpm(_bpm);
    notifyListeners();
  }

  void increaseBpm() => setBpm(_bpm + 1);
  void decreaseBpm() => setBpm(_bpm - 1);

  void setBeat(int value) {
    final next = clampBeat(value);
    if (next == _beat) return;
    _beat = next;
    if (_currentBeat > _beat) _currentBeat = 0;
    notifyListeners();
  }

  void applySong(Song song) {
    _bpm = clampBpm(song.bpm);
    _beat = clampBeat(song.beat);
    if (_currentBeat > _beat) _currentBeat = 0;
    _engine.updateBpm(_bpm);
    notifyListeners();
  }

  void start() {
    if (isPlaying) return;
    _currentBeat = 0;
    _engine.start(_bpm);
    notifyListeners();
  }

  void stop() {
    if (!isPlaying) return;
    _engine.stop();
    _currentBeat = 0;
    notifyListeners();
  }

  void togglePlay() => isPlaying ? stop() : start();

  void _onTick() {
    _clickPlayer.click();
    _currentBeat = _currentBeat < _beat ? _currentBeat + 1 : 1;
    notifyListeners();
  }

  @override
  void dispose() {
    _engine.stop();
    _clickPlayer.dispose();
    super.dispose();
  }
}
