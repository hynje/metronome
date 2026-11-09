import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/metronome_controller.dart';
import '../theme.dart';
import '../utils/drag_stepper.dart';

/// BPM 조절 패널: −/+ 버튼과, 좌우로 드래그해 바꾸는 숫자.
class BpmControl extends StatefulWidget {
  const BpmControl({super.key});

  @override
  State<BpmControl> createState() => _BpmControlState();
}

class _BpmControlState extends State<BpmControl> {
  final _drag = DragStepper();

  @override
  Widget build(BuildContext context) {
    final controller = context.read<MetronomeController>();
    final bpm = context.select((MetronomeController c) => c.bpm);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.text.withValues(alpha: 0.2),
        border: Border.all(width: 2, color: AppColors.panelBorder),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: HoldRepeatButton(
              icon: Icons.remove,
              label: 'Decrease BPM',
              onStep: controller.decreaseBpm,
            ),
          ),
          Expanded(
            child: GestureDetector(
              onHorizontalDragStart: (_) => _drag.reset(),
              onHorizontalDragUpdate: (details) {
                final steps = _drag.add(details.delta.dx);
                if (steps != 0) controller.setBpm(controller.bpm + steps);
              },
              onHorizontalDragEnd: (_) => _drag.reset(),
              child: Text(
                '$bpm',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 45, color: AppColors.text),
              ),
            ),
          ),
          Expanded(
            child: HoldRepeatButton(
              icon: Icons.add,
              label: 'Increase BPM',
              onStep: controller.increaseBpm,
            ),
          ),
        ],
      ),
    );
  }
}

/// 탭하면 한 번, 길게 누르고 있으면 계속 [onStep]을 호출하는 버튼.
///
/// 처음 몇 번은 천천히, 그 뒤로는 빠르게 반복해서 큰 폭으로도 금방 바꿀 수 있다.
class HoldRepeatButton extends StatefulWidget {
  const HoldRepeatButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onStep,
  });

  final IconData icon;
  final String label;
  final VoidCallback onStep;

  /// 이만큼 반복한 뒤부터 빠르게 반복한다.
  static const slowRepeats = 8;
  static const slowInterval = Duration(milliseconds: 120);
  static const fastInterval = Duration(milliseconds: 40);

  @override
  State<HoldRepeatButton> createState() => _HoldRepeatButtonState();
}

class _HoldRepeatButtonState extends State<HoldRepeatButton> {
  Timer? _timer;
  int _repeats = 0;

  void _startRepeating() {
    _stopRepeating();
    _repeats = 0;
    _step();
  }

  void _step() {
    widget.onStep();
    _repeats++;
    _timer = Timer(
      _repeats < HoldRepeatButton.slowRepeats
          ? HoldRepeatButton.slowInterval
          : HoldRepeatButton.fastInterval,
      _step,
    );
  }

  void _stopRepeating() {
    _timer?.cancel();
    _timer = null;
  }

  @override
  void dispose() {
    _stopRepeating();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: widget.label,
      child: GestureDetector(
        onTap: widget.onStep,
        onLongPressStart: (_) => _startRepeating(),
        onLongPressEnd: (_) => _stopRepeating(),
        onLongPressCancel: _stopRepeating,
        child: Icon(widget.icon, size: 55),
      ),
    );
  }
}
