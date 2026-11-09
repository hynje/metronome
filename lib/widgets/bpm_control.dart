import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/metronome_controller.dart';
import '../theme.dart';

/// BPM 조절 패널: −/+ 버튼과, 좌우로 드래그해 바꾸는 숫자.
class BpmControl extends StatelessWidget {
  const BpmControl({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.read<MetronomeController>();
    final bpm = context.select((MetronomeController c) => c.bpm);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.text.withOpacity(0.2),
        border: Border.all(width: 2, color: AppColors.panelBorder),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: controller.decreaseBpm,
              child: const Icon(Icons.remove, size: 55),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onHorizontalDragUpdate: (details) {
                final dx = details.delta.dx;
                if (dx > 0) controller.increaseBpm();
                if (dx < 0) controller.decreaseBpm();
              },
              child: Text(
                '$bpm',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 45, color: AppColors.text),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: controller.increaseBpm,
              child: const Icon(Icons.add, size: 55),
            ),
          ),
        ],
      ),
    );
  }
}
