import 'package:flutter/foundation.dart';

import '../models/song.dart';
import '../services/click_player.dart';
import '../services/metronome_engine.dart';

/// 메트로놈 상태(BPM, 박자, 재생 여부, 현재 박)를 한 곳에서 관리한다.
class MetronomeController extends ChangeNotifier {
  MetronomeController({required ClickPlayer clickPlayer})
      : _clickPlayer = clickPlayer {
    _engine = MetronomeEngine(onTick: _onTick);
    _ready = _initAudio();
  }

  final ClickPlayer _clickPlayer;
  late final MetronomeEngine _engine;

  /// 클릭 소리 준비가 끝나면(성공이든 실패든) 완료되는 Future.
  late Future<void> _ready;
  bool _audioFailed = false;

  /// 재생 버튼을 눌렀지만 소리 준비를 기다리는 중인지.
  bool _startPending = false;
  bool _disposed = false;

  int _bpm = kDefaultBpm;
  int _beat = kDefaultBeat;
  int _currentBeat = 0;

  int get bpm => _bpm;
  int get beat => _beat;
  bool get isPlaying => _engine.isRunning;

  /// 클릭 소리를 불러오지 못했으면 true. 이때도 박 표시는 동작한다.
  bool get audioFailed => _audioFailed;

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

  /// 소리 준비가 끝날 때까지 기다린 뒤 재생한다.
  /// 기다리는 동안 [stop]이 불리면 재생하지 않는다.
  Future<void> start() async {
    if (isPlaying || _startPending) return;
    _startPending = true;
    await _ready;
    if (!_startPending) return;
    _startPending = false;
    _currentBeat = 0;
    _engine.start(_bpm);
    notifyListeners();
  }

  void stop() {
    _startPending = false;
    if (!isPlaying) return;
    _engine.stop();
    _currentBeat = 0;
    notifyListeners();
  }

  void togglePlay() => (isPlaying || _startPending) ? stop() : start();

  /// 소리 불러오기에 실패했을 때 다시 시도한다.
  Future<void> retryAudio() {
    if (!_audioFailed) return _ready;
    return _ready = _initAudio();
  }

  Future<void> _initAudio() async {
    try {
      await _clickPlayer.init();
      _audioFailed = false;
    } catch (error, stack) {
      _audioFailed = true;
      FlutterError.reportError(FlutterErrorDetails(
        exception: error,
        stack: stack,
        library: 'metronome',
        context: ErrorDescription('while loading the click sound'),
      ));
    }
    if (!_disposed) notifyListeners();
  }

  void _onTick() {
    _clickPlayer.click();
    _currentBeat = _currentBeat < _beat ? _currentBeat + 1 : 1;
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _startPending = false;
    _engine.stop();
    _clickPlayer.dispose();
    super.dispose();
  }
}
