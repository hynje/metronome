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

  Future<dynamic> editSongName(BuildContext context, int index) async {
    TextEditingController controller =
        TextEditingController(text: songList![index]);
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
                    labelText: 'Input new title',
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
                setState(() {
                  savePrefs(controller.text, index);
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
    //initPrefs();
    //initPrefsBpm();
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
                    editSongName(context, index);
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
                    subtitle: FutureBuilder(
                      future: initPrefsBpm(),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  const Icon(
                                    Icons.music_note,
                                    size: 15,
                                  ),
                                  Text(
                                    ' : ${bpmList?[index].toString().split('.')[0]}',
                                  ),
                                  Text(
                                    ' , Beat : ${beatList?[index].toString()}',
                                  ),
                                ],
                              ),
                              Transform.scale(
                                scale: 1.2,
                                child: Transform.translate(
                                  offset: const Offset(0, -10),
                                  child: GestureDetector(
                                    onTapDown: (details) {
                                      savePrefsBpm(appState.getBpm(), index);
                                      savePrefsBeat(appState.getBeat(), index);
                                      setState(() {});
                                    },
                                    child: (isSelected == index) &&
                                            ((double.parse(bpmList![index])) !=
                                                    appState.getBpm() ||
                                                (int.parse(beatList![index]) !=
                                                    appState.getBeat()))
                                        ? Container(
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              border: Border.all(
                                                  width: 0.7,
                                                  color: const Color.fromARGB(
                                                      255, 252, 160, 0)),
                                            ),
                                            child: const Text('save'),
                                          )
                                        : const Text(''),
                                  ),
                                ),
                              ),
                            ],
                          );
                        } else {
                          return const Row();
                        }
                      },
                    ),
                    trailing: (isSelected == index)
                        ? const Icon(Icons.music_note)
                        : null,
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
