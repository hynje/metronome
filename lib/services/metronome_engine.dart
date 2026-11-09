import 'dart:async';

/// 현재 시각(기준점으로부터 지난 시간)을 돌려주는 함수.
typedef ElapsedClock = Duration Function();

/// 정해진 BPM으로 [onTick]을 호출하는 타이머.
///
/// 타이머 간격은 밀리초 단위로 잘리기 때문에(예: 121 BPM = 495.87ms),
/// 같은 간격을 반복하면 박마다 생기는 작은 오차가 계속 쌓인다.
/// 그래서 매 박마다 "시작 시각 + n × 간격"(마이크로초 단위)을 목표로
/// 남은 시간을 다시 계산해 한 번짜리 타이머를 건다. 콜백이 늦게 불려도
/// 다음 박에서 바로잡히므로 오차가 누적되지 않는다.
class MetronomeEngine {
  /// [clock]을 넘기지 않으면 실제 시간을 쓴다. 테스트에서는 가짜 시계를 넣는다.
  MetronomeEngine({required this.onTick, ElapsedClock? clock})
      : _now = clock ?? _realClock();

  final void Function() onTick;
  final ElapsedClock _now;

  Timer? _timer;
  Duration _interval = Duration.zero;
  Duration _startedAt = Duration.zero;
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
  }

  void _restartClock() {
    _startedAt = _now();
    _ticks = 0;
  }

  void _tick() {
    onTick();
    _scheduleNext();
  }

  void _scheduleNext() {
    _ticks++;
    final wait = _interval * _ticks - (_now() - _startedAt);
    _timer = Timer(wait.isNegative ? Duration.zero : wait, _tick);
  }

  static Duration _intervalFor(int bpm) =>
      Duration(microseconds: (Duration.microsecondsPerMinute / bpm).round());

  static ElapsedClock _realClock() {
    final stopwatch = Stopwatch()..start();
    return () => stopwatch.elapsed;
  }
}
