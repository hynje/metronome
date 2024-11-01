import 'dart:async';
import 'package:flutter/material.dart';
import 'package:metronome/provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SetList extends StatefulWidget {
  const SetList({super.key});

  @override
  State<SetList> createState() => _SetListState();
}

class _SetListState extends State<SetList> {
  int isSelected = -1;
  final int _itemcount = 10;
  late SharedPreferences prefs;
  late List<String>? songList = [];
  late List<String>? bpmList = [];
  late List<String>? beatList = [];

  Future initPrefs() async {
    prefs = await SharedPreferences.getInstance();
    songList = prefs.getStringList('songList');
    if (songList == null) {
      await prefs.setStringList(
          'songList', List<String>.filled(_itemcount, 'input song name'));
    }
    return prefs;
  }

  Future initPrefsBpm() async {
    prefs = await SharedPreferences.getInstance();
    bpmList = prefs.getStringList('bpmList');
    if (bpmList == null) {
      await prefs.setStringList(
          'bpmList', List<String>.filled(_itemcount, '120'));
    }
    return prefs;
  }

  Future initPrefsBeat() async {
    prefs = await SharedPreferences.getInstance();
    beatList = prefs.getStringList('beatList');
    if (beatList == null) {
      await prefs.setStringList(
          'beatList', List<String>.filled(_itemcount, '4'));
    }
    return prefs;
  }

  Future savePrefs(String newName, int index) async {
    prefs = await SharedPreferences.getInstance();
    songList = prefs.getStringList('songList');
    songList?[index] = newName;
    prefs.setStringList('songList', songList!);
  }

  Future savePrefsBpm(double newBpm, int index) async {
    prefs = await SharedPreferences.getInstance();
    bpmList = prefs.getStringList('bpmList');
    bpmList?[index] = newBpm.toString();
    prefs.setStringList('bpmList', bpmList!);
  }

  Future savePrefsBeat(int newBeat, int index) async {
    prefs = await SharedPreferences.getInstance();
    beatList = prefs.getStringList('beatList');
    beatList?[index] = newBeat.toString();
    prefs.setStringList('beatList', beatList!);
  }

  Future<dynamic> editSongForm(
      BuildContext context, int index, AppState appState) async {
    TextEditingController controller =
        TextEditingController(text: songList![index]);
    TextEditingController controller2 =
        TextEditingController(text: bpmList![index].split('.')[0]);
    TextEditingController controller3 =
        TextEditingController(text: beatList![index]);
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color.fromARGB(255, 244, 244, 235),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: controller,
                  decoration: const InputDecoration(
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.brown),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide:
                          BorderSide(color: Color.fromARGB(255, 252, 160, 0)),
                    ),
                    labelStyle: TextStyle(color: Colors.brown),
                    labelText: 'title',
                  ),
                ),
                TextField(
                  controller: controller2,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.brown),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide:
                          BorderSide(color: Color.fromARGB(255, 252, 160, 0)),
                    ),
                    labelStyle: TextStyle(color: Colors.brown),
                    labelText: 'bpm : 40 - 265',
                  ),
                ),
                TextField(
                  controller: controller3,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.brown),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide:
                          BorderSide(color: Color.fromARGB(255, 252, 160, 0)),
                    ),
                    labelStyle: TextStyle(color: Colors.brown),
                    labelText: 'beat : 2 - 7',
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              style: TextButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 244, 244, 235),
                  foregroundColor: Colors.brown),
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text(
                'cancel',
              ),
            ),
            ElevatedButton(
              onPressed: () {
                double newBpm = double.parse(controller2.text);
                if (newBpm < 40) {
                  newBpm = 40;
                } else if (newBpm > 265) {
                  newBpm = 265;
                }
                int newBeat = int.parse(controller3.text);
                if (newBeat < 2) {
                  newBpm = 2;
                } else if (newBeat > 7) {
                  newBeat = 7;
                }
                setState(() {
                  savePrefs(controller.text, index);
                  savePrefsBpm(newBpm, index);
                  appState.setBpm(newBpm);
                  savePrefsBeat(newBeat, index);
                  appState.setBeat(newBeat);
                });
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 244, 244, 235),
                foregroundColor: const Color.fromARGB(255, 252, 160, 0),
                shadowColor: Colors.black,
                elevation: 2.0,
              ),
              child: const Text('save'),
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    initPrefs();
    initPrefsBpm();
    initPrefsBeat();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, child) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Container(
            margin: const EdgeInsets.only(top: 110, bottom: 200),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.brown.shade600),
              borderRadius: BorderRadius.circular(8),
            ),
            child: ListView.builder(
              itemCount: _itemcount,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onLongPress: () {
                    isSelected = index;
                    appState.setBpm(double.parse(bpmList![index]));
                    appState.setBeat(int.parse(beatList![index]));
                    editSongForm(context, index, appState);
                  },
                  child: ListTile(
                    textColor: (isSelected == index)
                        ? const Color.fromARGB(255, 252, 160, 0)
                        : Colors.brown,
                    iconColor: (isSelected == index)
                        ? const Color.fromARGB(255, 252, 160, 0)
                        : Colors.brown,
                    leading: Text(
                      '${index + 1}',
                      style: const TextStyle(fontSize: 18),
                    ),
                    title: FutureBuilder(
                      future: initPrefs(),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          return Text(songList![index]);
                        } else {
                          return const Text('...');
                        }
                      },
                    ),
                    subtitle: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.music_note,
                              size: 15,
                            ),
                            FutureBuilder(
                              future: initPrefsBpm(),
                              builder: (context, snapshot) {
                                if (snapshot.hasData) {
                                  return Text(
                                    ' : ${bpmList?[index].toString().split('.')[0]}',
                                  );
                                } else {
                                  return const Text('');
                                }
                              },
                            ),
                            FutureBuilder(
                              future: initPrefsBeat(),
                              builder: (context, snapshot) {
                                if (snapshot.hasData) {
                                  return Text(
                                    ' , Beat : ${beatList?[index].toString()}',
                                  );
                                } else {
                                  return const Text('');
                                }
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                    trailing: (isSelected == index) &&
                            ((double.parse(bpmList![index])) !=
                                    appState.getBpm() ||
                                (int.parse(beatList![index]) !=
                                    appState.getBeat()))
                        ? ElevatedButton(
                            onPressed: () {
                              savePrefsBpm(appState.getBpm(), index);
                              savePrefsBeat(appState.getBeat(), index);
                              setState(() {});
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  const Color.fromARGB(255, 244, 244, 235),
                              foregroundColor:
                                  const Color.fromARGB(255, 252, 160, 0),
                              shadowColor: Colors.black,
                              elevation: 1.0,
                            ),
                            child: const Text('save'),
                          )
                        : const Text(''),
                    onTap: () {
                      isSelected = index;
                      appState.setBpm(double.parse(bpmList![index]));
                      appState.setBeat(int.parse(beatList![index]));
                    },
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}
