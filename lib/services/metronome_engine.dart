import 'dart:async';

/// 정해진 BPM으로 [onTick]을 호출하는 타이머.
///
/// `Timer.periodic`은 호출마다 오차가 쌓이므로, 시작 시각 기준으로
/// 다음 박의 목표 시각을 계산해 한 번짜리 타이머를 다시 거는 방식으로
/// 오차가 누적되지 않게 한다.
class MetronomeEngine {
  MetronomeEngine({required this.onTick});

  final void Function() onTick;

  final Stopwatch _clock = Stopwatch();
  Timer? _timer;
  Duration _interval = Duration.zero;
  int _ticks = 0;

  bool get isRunning => _timer != null;

  /// 즉시 첫 박을 울리고 [bpm] 간격으로 계속 울린다.
  void start(int bpm) {
    stop();
    _interval = _intervalFor(bpm);
    _restartClock();
    _tick();
  }

  /// 재생 중이면 지금 시점부터 새 간격으로 다음 박을 잡는다.
  void updateBpm(int bpm) {
    _interval = _intervalFor(bpm);
    if (!isRunning) return;
    _timer?.cancel();
    _restartClock();
    _scheduleNext();
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
    _clock.stop();
  }

  void _restartClock() {
    _clock
      ..reset()
      ..start();
    _ticks = 0;
  }

  void _tick() {
    onTick();
    _scheduleNext();
  }

  void _scheduleNext() {
    _ticks++;
    final wait = _interval * _ticks - _clock.elapsed;
    _timer = Timer(wait.isNegative ? Duration.zero : wait, _tick);
  }

  static Duration _intervalFor(int bpm) =>
      Duration(microseconds: (Duration.microsecondsPerMinute / bpm).round());
}
