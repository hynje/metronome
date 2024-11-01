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

  String checkTempo(double presentBpm) {
    if (40 <= presentBpm && presentBpm <= 44) {
      return 'Lento';
    } else if (44 < presentBpm && presentBpm <= 49) {
      return 'Largo';
    } else if (49 < presentBpm && presentBpm <= 54) {
      return 'Larghetto';
    } else if (54 < presentBpm && presentBpm <= 64) {
      return 'Adagio';
    } else if (64 < presentBpm && presentBpm <= 68) {
      return 'Adagietto';
    } else if (68 < presentBpm && presentBpm <= 72) {
      return 'Andante moderato';
    } else if (72 < presentBpm && presentBpm <= 77) {
      return 'Andante';
    } else if (77 < presentBpm && presentBpm <= 82) {
      return 'Andantino';
    } else if (82 < presentBpm && presentBpm <= 85) {
      return 'Marcia moderato';
    } else if (85 < presentBpm && presentBpm <= 97) {
      return 'Moderato';
    } else if (97 < presentBpm && presentBpm <= 109) {
      return 'Allegretto';
    } else if (109 < presentBpm && presentBpm <= 131) {
      return 'Allegro';
    } else if (131 < presentBpm && presentBpm <= 139) {
      return 'Vivace';
    } else if (139 < presentBpm && presentBpm <= 149) {
      return 'Vivacissimo';
    } else if (149 < presentBpm && presentBpm <= 167) {
      return 'Allegrissimo';
    } else if (167 < presentBpm && presentBpm <= 177) {
      return 'Presto';
    } else {
      return 'Prestissimo';
    }
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
                      children: [
                        Expanded(
                          flex: 1,
                          child: GestureDetector(
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
                        ),
                        Expanded(
                          flex: 1,
                          child: GestureDetector(
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
                              textAlign: TextAlign.center,
                              bpm.toString().split('.')[0],
                              style: const TextStyle(
                                  fontSize: 45, color: Colors.brown),
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: GestureDetector(
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
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      Expanded(
                        flex: 1,
                        child: PopupMenuButton(
                          offset: const Offset(0, -30),
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
                      Expanded(
                        flex: 1,
                        child: Text(
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              fontStyle: FontStyle.italic,
                              color: Color.fromARGB(255, 252, 160, 0)),
                          checkTempo(appState.getBpm()),
                        ),
                      ),
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
