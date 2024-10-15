import 'dart:async';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

class Metronome extends StatefulWidget {
  final double bpm;
  final int beat, note;

  const Metronome({
    super.key,
    required this.bpm, //max265
    required this.beat,
    required this.note,
  });

  @override
  State<Metronome> createState() => _MetronomeState();
}

class _MetronomeState extends State<Metronome> {
  late Timer timer;
  bool isPlaying = false;
  int presentNote = 0;

  Timer makePeriodicTimer(
    Duration duration,
    void Function(Timer timer) callback, {
    bool fireNow = false,
  }) {
    var timer = Timer.periodic(duration, callback);
    if (fireNow) {
      callback(timer);
    }
    return timer;
  }

  void onTickMetronome(Timer timer) async {
    final player = AudioPlayer();
    await player.play(AssetSource(
        'single-beep_C_major.wav')); // will immediately start playing
    setState(() {
      if (presentNote < widget.beat) {
        presentNote++;
      } else {
        presentNote = 1;
      }
    });
  }

  void onStartPressed() {
    setState(() {
      isPlaying = true;
    });
    timer = makePeriodicTimer(
        Duration(milliseconds: (60000 / widget.bpm.round()).round()),
        onTickMetronome,
        fireNow: true);
  }

  void onStopPressed() {
    timer.cancel();
    isPlaying = false;
    presentNote = 0;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            for (int i = 1; i <= widget.beat; ++i)
              IconButton(
                onPressed: () {},
                icon: (presentNote == i)
                    ? const Icon(Icons.circle_outlined)
                    : const Icon(Icons.circle),
              ),
          ],
        ),
        IconButton(
          iconSize: 80,
          onPressed: isPlaying ? onStopPressed : onStartPressed,
          icon: isPlaying
              ? const Icon(Icons.stop_circle_outlined)
              : const Icon(Icons.play_circle_outlined),
        ),
        Text('$presentNote'),
      ],
    );
  }
}
