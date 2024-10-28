import 'dart:async';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:metronome/provider.dart';
import 'package:provider/provider.dart';

class Metronome extends StatefulWidget {
  const Metronome({super.key});

  @override
  State<Metronome> createState() => _MetronomeState();
}

class _MetronomeState extends State<Metronome> {
  late Timer timer;
  bool isPlaying = false;
  int presentNote = 0;
  double bpm = 120;
  int beat = 4;

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
      if (presentNote < beat) {
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
        Duration(milliseconds: (60000 / bpm.round()).round()), onTickMetronome,
        fireNow: true);
  }

  void onStopPressed() {
    timer.cancel();
    isPlaying = false;
    setState(() {
      presentNote = 0;
    });
  }

  PopupMenuItem<String> menuItem(String text) {
    return PopupMenuItem<String>(
      enabled: true,
      onTap: () {},
      value: text,
      height: 70,
      child: Center(
        child: Text(
          text,
          style: const TextStyle(color: Colors.brown),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, child) {
        beat = appState.getBeat();
        bpm = appState.getBpm();
        if (isPlaying) {
          timer.cancel();
          timer = makePeriodicTimer(
              Duration(milliseconds: (60000 / bpm.round()).round()),
              onTickMetronome,
              fireNow: false);
        }
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    for (int i = 1; i <= beat; ++i)
                      IconButton(
                        onPressed: () {},
                        icon: (presentNote == i)
                            ? const Icon(Icons.circle_outlined)
                            : const Icon(Icons.circle),
                      ),
                  ],
                ),
              ),
              Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.brown.withOpacity(0.2),
                      border: Border.all(
                        width: 2,
                        color: const Color.fromARGB(255, 178, 155, 146),
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        GestureDetector(
                          onTap: () {
                            if (bpm > 40) {
                              bpm = bpm - 1;
                            } else {
                              bpm = 40;
                            }
                            if (isPlaying) {
                              timer.cancel();
                              timer = makePeriodicTimer(
                                  Duration(
                                      milliseconds:
                                          (60000 / bpm.round()).round()),
                                  onTickMetronome,
                                  fireNow: false);
                            }
                            setState(() {
                              appState.setBpm(bpm);
                            });
                          },
                          child: const Icon(
                            Icons.remove,
                            size: 55,
                          ),
                        ),
                        GestureDetector(
                          onHorizontalDragUpdate: (details) {
                            if (details.delta.dx > 0) {
                              if (bpm < 265) {
                                bpm = bpm + 1;
                              } else {
                                bpm = 265;
                              }
                              setState(() {
                                appState.setBpm(bpm);
                              });
                            } else {
                              if (bpm > 40) {
                                bpm = bpm - 1;
                              } else {
                                bpm = 40;
                              }
                              setState(() {
                                appState.setBpm(bpm);
                              });
                            }
                            if (isPlaying) {
                              timer.cancel();
                              timer = makePeriodicTimer(
                                  Duration(
                                      milliseconds:
                                          (60000 / bpm.round()).round()),
                                  onTickMetronome,
                                  fireNow: false);
                            }
                            setState(() {
                              appState.setBpm(bpm);
                            });
                          },
                          child: Text(
                            bpm.toString().split('.')[0],
                            style: const TextStyle(
                                fontSize: 45, color: Colors.brown),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            if (bpm > 40) {
                              bpm = bpm + 1;
                            } else {
                              bpm = 265;
                            }
                            if (isPlaying) {
                              timer.cancel();
                              timer = makePeriodicTimer(
                                  Duration(
                                      milliseconds:
                                          (60000 / bpm.round()).round()),
                                  onTickMetronome,
                                  fireNow: false);
                            }
                            setState(() {
                              appState.setBpm(bpm);
                            });
                          },
                          child: const Icon(
                            Icons.add,
                            size: 55,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      Expanded(
                        flex: 1,
                        child: PopupMenuButton(
                          shape: RoundedRectangleBorder(
                            side:
                                const BorderSide(width: 1, color: Colors.brown),
                            borderRadius: BorderRadius.circular(7),
                          ),
                          shadowColor: const Color.fromARGB(255, 252, 160, 0),
                          elevation: 10,
                          color: const Color.fromARGB(255, 244, 244, 235),
                          constraints: const BoxConstraints(
                              minWidth: 50, maxWidth: 150, maxHeight: 200),
                          itemBuilder: (context) {
                            appState.setBeat(beat);
                            return [
                              menuItem('2'),
                              menuItem('3'),
                              menuItem('4'),
                              menuItem('5'),
                              menuItem('6'),
                              menuItem('7'),
                            ];
                          },
                          onSelected: (value) {
                            setState(() {
                              beat = int.parse(value);
                              appState.setBeat(beat);
                            });
                          },
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: IconButton(
                          iconSize: 80,
                          onPressed: isPlaying ? onStopPressed : onStartPressed,
                          icon: isPlaying
                              ? const Icon(Icons.stop_circle_outlined)
                              : const Icon(Icons.play_circle_outlined),
                        ),
                      ),
                      const Expanded(
                        flex: 1,
                        child: Text(''),
                      )
                    ],
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
