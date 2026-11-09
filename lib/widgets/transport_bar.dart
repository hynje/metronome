import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/song.dart';
import '../state/metronome_controller.dart';
import '../theme.dart';

/// 박자 선택 메뉴와 재생/정지 버튼.
class TransportBar extends StatelessWidget {
  const TransportBar({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.read<MetronomeController>();
    final beat = context.select((MetronomeController c) => c.beat);
    final isPlaying = context.select((MetronomeController c) => c.isPlaying);

    return Row(
      children: [
        Expanded(
          child: PopupMenuButton<int>(
            icon: Text(
              '$beat',
              style: const TextStyle(
                fontSize: 18,
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            offset: const Offset(0, -30),
            shape: RoundedRectangleBorder(
              side: const BorderSide(width: 1, color: AppColors.text),
              borderRadius: BorderRadius.circular(8),
            ),
            shadowColor: AppColors.primary,
            elevation: 10,
            color: AppColors.background,
            constraints: const BoxConstraints(
                minWidth: 50, maxWidth: 150, maxHeight: 200),
            onSelected: controller.setBeat,
            itemBuilder: (context) => [
              for (var b = kMinBeat; b <= kMaxBeat; b++)
                PopupMenuItem<int>(
                  value: b,
                  height: 70,
                  child: Center(
                    child: Text('$b',
                        style: const TextStyle(color: AppColors.text)),
                  ),
                ),
            ],
          ),
        ),
        Expanded(
          flex: 2,
          child: IconButton(
            iconSize: 80,
            onPressed: controller.togglePlay,
            icon: Icon(isPlaying
                ? Icons.stop_circle_outlined
                : Icons.play_circle_outlined),
          ),
        ),
        const Expanded(child: SizedBox.shrink()),
      ],
    );
  }
}
