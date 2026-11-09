import 'package:flutter_test/flutter_test.dart';

import 'package:metronome/utils/drag_stepper.dart';

void main() {
  test('이동 거리를 모아 8px마다 한 단계씩 돌려준다', () {
    final d = DragStepper();
    expect(d.add(3), 0);
    expect(d.add(4), 0);
    expect(d.add(2), 1); // 누적 9px → 1단계, 1px 남음
    expect(d.add(15), 2); // 16px → 2단계
  });

  test('왼쪽으로 움직이면 음수 단계', () {
    final d = DragStepper();
    expect(d.add(-17), -2);
    expect(d.add(-7), -1); // 남은 -1px + -7px = -8px
  });

  test('방향을 바꾸면 남은 거리와 상쇄된다', () {
    final d = DragStepper();
    expect(d.add(6), 0);
    expect(d.add(-6), 0);
    expect(d.add(-8), -1);
  });

  test('reset하면 남은 거리를 버린다', () {
    final d = DragStepper()..add(7);
    d.reset();
    expect(d.add(1), 0);
  });
}
