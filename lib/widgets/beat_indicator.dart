import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/metronome_controller.dart';

/// 박자 수만큼 점을 그리고, 지금 울린 박을 빈 원으로 표시한다.
class BeatIndicator extends StatelessWidget {
  const BeatIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    final beat = context.select((MetronomeController c) => c.beat);
    final current = context.select((MetronomeController c) => c.currentBeat);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        for (var i = 1; i <= beat; i++)
          SizedBox.square(
            dimension: 48,
            child: Icon(i == current ? Icons.circle_outlined : Icons.circle),
          ),
      ],
    );
  }
}
