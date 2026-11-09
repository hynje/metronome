import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:metronome/services/metronome_engine.dart';

void main() {
  /// 가짜 시간 위에서 엔진을 돌리고, 박이 울린 시각(ms)을 기록한다.
  ///
  /// [workPerTick]은 박마다 걸리는 처리 시간(소리 재생, 화면 갱신 등)을 흉내 낸다.
  List<int> run(
    void Function(MetronomeEngine engine, FakeAsync async) scenario, {
    Duration workPerTick = Duration.zero,
  }) {
    final ticks = <int>[];
    fakeAsync((async) {
      final engine = MetronomeEngine(
        clock: () => async.elapsed,
        onTick: () {
          ticks.add(async.elapsed.inMilliseconds);
          async.elapseBlocking(workPerTick);
        },
      );
      scenario(engine, async);
      engine.stop();
    });
    return ticks;
  }

  test('시작하면 바로 첫 박이 울리고 BPM 간격으로 이어진다', () {
    final ticks = run((engine, async) {
      engine.start(120);
      async.elapse(const Duration(milliseconds: 1999));
    });
    expect(ticks, [0, 500, 1000, 1500]);
  });

  test('121 BPM처럼 간격이 ms로 나누어떨어지지 않아도 오차가 쌓이지 않는다', () {
    final ticks = run((engine, async) {
      engine.start(121);
      async.elapse(const Duration(minutes: 1, milliseconds: 1));
    });
    // 0초의 첫 박 + 1분 동안 121박 = 122번. 간격을 마이크로초로 반올림해서
    // 1분에 28µs 정도만 어긋나므로, 마지막 박은 60초(ms 단위) 정각이어야 한다.
    expect(ticks, hasLength(122));
    expect(ticks.last, 60000);
  });

  test('박마다 처리 시간이 걸려도 오차가 쌓이지 않는다', () {
    // "처리가 끝난 뒤 500ms 후"로 다음 박을 잡으면 0, 530, 1060 ...으로 밀린다.
    final ticks = run(
      (engine, async) {
        engine.start(120);
        async.elapse(const Duration(seconds: 5));
      },
      workPerTick: const Duration(milliseconds: 30),
    );
    expect(ticks, [for (var i = 0; i <= 10; i++) i * 500]);
  });

  test('재생 중 BPM을 바꾸면 그 시점부터 새 간격이 적용된다', () {
    final ticks = run((engine, async) {
      engine.start(120);
      async.elapse(const Duration(milliseconds: 700));
      engine.updateBpm(60);
      async.elapse(const Duration(milliseconds: 2400));
    });
    expect(ticks, [0, 500, 1700, 2700]);
  });

  test('정지하면 더 이상 울리지 않는다', () {
    final ticks = run((engine, async) {
      engine.start(120);
      async.elapse(const Duration(milliseconds: 600));
      engine.stop();
      expect(engine.isRunning, isFalse);
      async.elapse(const Duration(seconds: 3));
    });
    expect(ticks, [0, 500]);
  });

  test('정지 상태에서 BPM을 바꿔도 울리지 않는다', () {
    final ticks = run((engine, async) {
      engine.updateBpm(200);
      async.elapse(const Duration(seconds: 1));
    });
    expect(ticks, isEmpty);
  });
}
