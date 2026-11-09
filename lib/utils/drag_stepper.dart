/// 드래그 이동 거리를 모아서 일정 거리마다 한 단계씩 바꿔 준다.
///
/// 드래그 이벤트가 오는 빈도는 기기와 손 속도에 따라 다르므로,
/// 이벤트 횟수가 아니라 실제 이동 거리를 기준으로 단계를 센다.
class DragStepper {
  DragStepper({this.pixelsPerStep = 8});

  /// 한 단계를 바꾸는 데 필요한 이동 거리(논리 픽셀).
  final double pixelsPerStep;

  double _accumulated = 0;

  /// [dx]만큼 움직였을 때 바뀌어야 할 단계 수를 돌려준다.
  /// 오른쪽이면 양수, 왼쪽이면 음수. 남은 거리는 다음 호출로 넘어간다.
  int add(double dx) {
    _accumulated += dx;
    final steps = (_accumulated / pixelsPerStep).truncate();
    _accumulated -= steps * pixelsPerStep;
    return steps;
  }

  void reset() => _accumulated = 0;
}
