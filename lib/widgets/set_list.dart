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
  final bpmList = List<double>.filled(10, 60);
  int isSelected = -1;
  late SharedPreferences prefs;
  late List<String>? songList = [];

  Future initPrefs() async {
    prefs = await SharedPreferences.getInstance();
    songList = prefs.getStringList('songList');
    if (songList == null) {
      await prefs.setStringList(
          'songList', List<String>.filled(10, 'input song name'));
    }
    return prefs;
  }

  Future savePrefs(String newName, int index) async {
    prefs = await SharedPreferences.getInstance();
    songList = prefs.getStringList('songList');
    songList?[index] = newName;
    prefs.setStringList('songList', songList!);
  }

  Future<dynamic> editSongName(BuildContext context, int index) async {
    TextEditingController controller = TextEditingController();
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          //title: Text('Edit SongName'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: controller,
                  decoration: InputDecoration(
                    hintText: songList![index],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('cancel'),
            ),
            ElevatedButton(
                onPressed: () {
                  setState(() {
                    savePrefs(controller.text, index);
                  });
                  Navigator.pop(context);
                },
                child: const Text('save')),
          ],
        );
      },
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
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Container(
            margin: const EdgeInsets.only(top: 110, bottom: 200),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.brown.shade600),
              borderRadius: BorderRadius.circular(8),
            ),
            child: ListView.builder(
              itemCount: bpmList.length,
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
                    subtitle: Row(
                      children: [
                        const Icon(
                          Icons.music_note,
                          size: 15,
                        ),
                        Text(' : ${bpmList[index].toString().split('.')[0]}'),
                      ],
                    ),
                    trailing:
                        (isSelected == index) ? const Icon(Icons.check) : null,
                    onTap: () {
                      isSelected = index;
                      appState.setBpm(bpmList[index]);
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
